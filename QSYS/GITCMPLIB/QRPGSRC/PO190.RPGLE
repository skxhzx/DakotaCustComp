     F*----------------------------------------------------------------
     F*   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  PO190     PO display - qty ordered <> qty received.
     F*  13 November, 2006
     F*  Randy Haselhorst
     F*
     F*  This is a copy of PO120.
     F*
     F*  Revisions
     F*
416 AF*    11/26/01  MLB  4.16
     F*      - Added support to program for Super P/O's.
     F*      - Revised program to combine support for Mfr nbr order.
     F*      - Major modifications, code cleaned up, new code not id.
416aAF*    12/04/01  MLB  4.16a
     F*      - Revised ZZWDW3 to load hold fields from subfile into
     F*        DSUKEY fields when record is selected.
416bAF*    12/20/01  MLB  4.16b
     F*      - Revised ZZOPT to unlock PORCV if record found.
416cAF*    12/21/01  MLB  4.16c
     F*      - Revised ZZWDW to not display position to window for
     F*        items or mfg# when only one record in subfile.
     F*        If no items/mfg# are loaded into position to subfile,
     F*        send message and don't display window.
416dAF*    12/27/01  MLB  4.16d
     F*      - Revision to above modification.  If the item/mfg# is
     F*        found on only one p/o in the Super P/O, then position
     F*        to the item and do not display the window.  If the item/
     F*        mfg# not found, then display the window if values found
     F*        that are greater than the value keyed in.
416eAF*    05/23/02  RH   4.16e
    AF*      - PORCV file changed, initialize POREDT and PORETI.
416fAF*    10/31/02  HNK  4.16f
    AF*      - Get putaway method from DEPTDSG file.  Use opposite
     F*        method if record found in this file.
     F*
417 AF*    03/25/03  MLB  4.17
     F*      - Enh: Added new option #14 Rcv exceptions.  This will
     F*        allow users to log receiving exceptions for shorts/outs
     F*        damages etc.
417aAF*    04/03/03  RH   4.17a
     F*      - Enh: Allow multiple items for one UPC code.
     F*        Display window to select or mark for exception.
417bAF*    04/15/03  MLB  4.17b
     F*      - Enh: Extended length of W1UPC to 50 characters and
     F*        renamed field W1UPCD.
417cAF*    05/21/03  RH   4.17c
     F*      - Enh: Only create one exception per item for multiple UPC
417dAF*    05/21/03  RH   4.17d
     F*      - Enh: Write UPC code to EXFDIS & EXTDIS using data struct
417eAF*    05/23/03  MLB  4.17e
     F*      - Enh: Create new option array ZOPT6 for DSPSFL6 subfile.
417fAF*    06/02/03  RH   4.17f
     F*      - FIX: Process 'X' options first, then '1' for select on
     F*        window 6 (multiple UPC codes). Was not creating
     F*        exception when X and 1 were entered at the same time.
417gAF*    06/05/03  RH   4.17g
     F*      - FIX: Allow selection of UPC on window.  Was loosing key
     F*        $KPO when UPC item was not on PO.
417hAF*    06/09/03  RH   4.17h
     F*      - FIX: Right adjust UPC code after CVTBAR even if invalid.
417iAF*    07/07/03  RH   4.17i
     F*      - FIX: Set OPTSLT, was not selecting when 1 UPC was found.
417jAF*    08/21/03  MLB  4.17j
     F*      - Fix: Set OPTSLT. Was not selecting when 1 UPC was found
     F*        when processing Super P/O's.
417kAF*    04/20/04  RH   4.17k
     F*      - ENH: Add F7 for Subtotal to PO120 for normal PO.
     F*             Add DSPFSC7 for window4
417lAF*    04/26/04  RH   4.17l
     F*      - ENH: Add F8 for item subtotal to PO120 for Super PO
     F*             Add DSPFSC8 for window4
     F*      - ENH: Change F7 to F8 for item subtotal for normal PO.
417mAF*    05/04/04  RH   4.17m
     F*      - Fix: Set W1UPC = blanks if UPC was not found for item on
     F*             PO or selected from window.
417nAF*    05/12/04  RH   4.17n
     F*      - FIX: Chain to DSPSFL2 not DSPSFL before update.
417oAF*    08/18/04  MLB  4.17o
     F*      - Fix: Revise routine ZZWDW to setof *IN21. This indicator
     F*        is used to flag SFLNXTCHG on subfile records. It was not
     F*        being reset between windows.
500 AF*    01/18/05  RH   5.00
     F*      - Fix: Add code to ZZCMD that was missed in 417 update.
500aAF*    12/27/04  RH   5.00a
     F*      - Enh: Add $CMD to allow *SPRECV directed put away to
     F*        pick slot with no license.
500bAF*    12/29/04  RH   5.00b
     F*      - Enh: Disable option 7 Quick receive. Option doesn't work
     F*        Removed from option display and option table at bottom.
500cAF*    12/30/04  DAS  5.00c
     F*      - Enh: For *SPRECV, displaying 1=StuffIt Rcv.
500dAF*    03/21/05  RH   5.00d
     F*      - Missed 417m change in V4.17 update, line 4325
500eAF*    04/01/05  RH   5.00e
     F*      - Add F11 to view un-checked lines only.
500fAF*    09/07/05  MLB  5.00f
     F*      - Fix: Revised ZZCHEK to remove requirement that item
     F*        types: A,B,S or C, parent item must have a pick slot.
500gAF*    10/23/05  JCJ  5.00g
     F*      - Add HACCP edits with PO170.
510 AF*    09/21/06  JCJ  5.10
     F*      - Enh: Revised program to add support for Client id
510aAF*    11/13/06  RAH  5.10a
     F*      - Enh: Created PO190 from PO120.  View only and limit
     F*             selection if qty ordered is not equal to qty rcvd.
510aAF*    10/24/07  LMC  5.10b
     F*      - Fix: When rolling back, only increment P if qty diff
700aA*    11/03/16  LMC  7.00a
     *      - Enh: UPC file has a database change. Recompile only.
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Packer's
     F*
PCK AF*    08/27/06  JCJ  PCK
     F*      - Add option 10 to option line / option list
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  20        POSITION CURSOR
     F*  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  40        Condition heading for Super P/O.
     F*  41        Condition heading for Super P/O window.
     F*  79        CHAIN INDICATOR
     F*  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     fpo190fm   cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(dspsfl:recno)
     f                                     sfile(dspsfl1:recno)
     f                                     sfile(dspsfl2:recno)
     f                                     sfile(dspsfl3:recno)
     f                                     sfile(dspsfl4:recno4)
     f                                     sfile(dspsfl5:recno4)
     f                                     sfile(dspsfl6:recno4)
     f                                     sfile(dspsfl7:recno4)
     f                                     sfile(dspsfl8:recno4)
     f                                     sfile(msgrec:msgk)
     f                                     sfile(msgrec4:msgk4)
510adf*workopt   uf a e           k disk
510aafworkopt   if   e           k disk
     fitemdef   if   e           k disk
     fitemdsc   if   e           k disk
     fitemlnk   if   e           k disk
417a fitemmsc   if   e           k disk
     foptions   if   e           k disk
     foptiond   if   e           k disk
     fpiritem   if   e           k disk
     fpodtl     if   e           k disk
     fpodtl1    if   e           k disk
     f                                     rename(pdrec:record)
     fpodtl2    if   e           k disk
     f                                     rename(pdrec:record2)
     fpodtl3    if   e           k disk
     f                                     rename(pdjrec:ptouch)
510adf*pohdr     uf   e           k disk
510adf*porcv     uf a e           k disk
510aafpohdr     if   e           k disk
510aafporcv     if   e           k disk
     fpospo3    if   e           k disk
     fpo120a    if   e           k disk    usropn
     fpo120b    if   e           k disk    usropn
     fpo120c    if   e           k disk    usropn
     f                                     infds(ocinf)
     fpo120d    if   e           k disk    usropn
     f                                     infds(odinf)
     fslot3     if   e           k disk
     fupc       if   e           k disk
     fwarehs    if   e           k disk
416FAfdeptdsg   if   e           k disk
417aAfpospo     if   e           k disk
417cAfitmexcp2  if   e           k disk
     f                                     rename(exrec:xrec2)
510adf*itmexcp   o  a e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d a2              s              1    dim(2)
     d a10             s              1    dim(10)
     d a75             s              1    dim(75)
     d a80             s              1    dim(80)
     d fkey            s             50    dim(10)
     d ukey            s             50    dim(10)
     d optlst          s              2    dim(24)
     d cmdlst          s              2    dim(24)
     d zopt            s              2    dim(20) ctdata perrcd(20)
417eMd zopt4           s              2    dim(1) ctdata perrcd(1)
417eDD*                   ZOPT4   2   2  2
417ADD*                   ZOPT4   1   1  2
417eAd zopt6           s              2    dim(2) ctdata perrcd(2)
     d optln           s             75    dim(4) ctdata perrcd(1)
PCK Ad optlnp          s             75    dim(4) ctdata perrcd(1)
500cAd optlns          s             75    dim(1) ctdata perrcd(1)
500eMd cmdln           s             79    dim(9) ctdata perrcd(1)
500eDD*                   CMDLN   1   5 79
     d ovr             s             80    dim(4) ctdata perrcd(1)
     d qry1            s             80    dim(5) ctdata perrcd(1)
     d qry2            s             80    dim(5) ctdata perrcd(1)
     d qry3            s             80    dim(6) ctdata perrcd(1)
     d qry4            s             80    dim(6) ctdata perrcd(1)
     d cls1            s             80    dim(2) ctdata perrcd(1)
510 AD*----------------------------------------------------------------
510 AD*  Customer id
510 AD*
     d @getcl          c                   const('GETCLIENT')
510 AD*
510 A /COPY QCOPYSRC,Id#PACKERS
     D*----------------------------------------------------------------
     D*  Partial key redefinition
     D*
     d $prtky          ds
     d  $len50                 1     50
     d  $kwhse                 1      3  0
     d  $whsea                 1      3
     d  $kpo                   4     12
     d  $kspo                 13     21
     d  $spo                  47     50
     D*----------------------------------------------------------------
     D*  Data structure for FKEY and UKEY
     D*
     d                 ds
     d  dsfkey                 1     50
     d  dsukey                 1     50
     d  pdwhse                 1      3  0 inz(0)
     d  pdpo                   4     12
     d  pdseq                 13     17  0 inz(0)
     d  pditem                18     32
     d  pdvitm                33     47
     D*----------------------------------------------------------------
     D*  Redefinition data structures
     D*
     d $aerm           ds
     d  xaerm                  1     60
     d  $amsg                  1      4
     d $cerm           ds
     d  xcerm                  1     60
     d  $cmsg                  1      4
     D*----------------------------------------------------------------
     D*  *PICK  -  Picking options
     D*----------------------------------------------------------------
     D*
     D* Fields
     D*
     D*    OPNXTP  -  Next pallet number.
     D*    OPBPCK  -  Bulk pick definition.
     D*    OPPCUB  -  Maximum cube for PIR.
     D*    OPFPAL  -  Pallets on fixed fork lift.
     D*    OPFCUB  -  Maximum cube per fixed pallet.
     D*    OPFSTP  -  Maximum stops per fixed pallet.
     D*    OPINCL  -  Include PIR in fixed cube.
     D*    OPSRCH  -  Number of previous pallets to search for space.
     D*    OPFBLD  -  Fixed pallet building method.
     D*                1 = By piece without concern for splitting stop.
     D*                2 = By stop without splitting stop between plts.
     D*    OPPBRK  -  Break pallets by aisle (Y,N).
     D*    OPMPUT  -  Manual Put away (Y,N).
     D*
     D* Data structure
     D*
     d opddta          ds
     d  opnxtp                 1      7  0 inz(0)
     d  oppcub                10     14  2 inz(0)
     d  opfpal                15     15  0 inz(0)
     d  opfcub                16     20  2 inz(0)
     d  opincl                22     22
     d  opsrch                23     24  0 inz(0)
     d  opfstp                25     26  0 inz(0)
     d  opfbld                27     27  0 inz(0)
     d  opbpck                28     30  0 inz(0)
     d  oppbrk                31     33
     d  opmput                34     34
     d  opdend               117    117
     D*
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     d $lparm          ds
     d  $lcmd                  1      8
     d  $lprg                  9     18
     d  $luky                 19     68
     d  $lrtn                 69     76
     d  $lerm                 77    136
     d  $lmsg                 77     80
     D*
     D*   Redefine key
     D*
     d  $lwhse                19     21  0
     d  $lpo                  22     30
     d  $lseq                 31     35  0
     d  $litem                36     50
     D*
     d  $litm                 22     36
     d  $lxflg                37     37
     D*----------------------------------------------------------------
     D* Data structure
     D*
     d opdata          ds
     d  opstyp                 1      1
     d  opwhdp                 2      6
     d  opum1                  7      8
     d  opdum                  9     23
     d  opcum                 24     43
     d  opcdiv                44     52  2
     d  opcaut                53     53
     d  opcwrn                54     54
     d  opcrng                55     57  1
     d  opwum                 58     72
     d  opxdsc                73     73
     d  optend               117    117
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     d @cvtdt          c                   const('CVTDTE')
     d @chgpg          c                   const('PO122')
     d @delpg          c                   const('PO124')
     d @prtpg          c                   const('NONE')
     d @lstpg          c                   const('UI316')
     D*----------------------------------------------------------------
     D*  Window Titles.
     D*
     d titl01          c                   const('Select Purchase Orde-
     d                                     r')
     d titl02          c                   const('Display Purchase Ord-
     d                                     er totals')
     d titl03          c                   const('Position To Item Num-
     d                                     ber')
     d titl04          c                   const('Position To Manufact-
     d                                     urer number')
     d titl05          c                   const('Select item for UPC -
     d                                                ')
     d hdr01           c                   const('Item Number')
     d hdr02           c                   const('Mfr Number')
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
     D*
     d  $pwhse                19     21  0
     d  $ppo                  22     30
     d  $pseq                 31     35  0
     d  $pitem                36     50
     d  $pvitm                51     65
417dAD*----------------------------------------------------------------
417dAD*  Redefinition data structures
417dAD*
417dAd                 ds
417dAd  dsupc                  1     20
417dAd  dsfdis                 1     12
417dAd  dstdis                13     24
     D*----------------------------------------------------------------
     d $cvtdt          ds
417a D*                                       1   8 $CVDOP
417a D*                                       9  140$CVDD6
417a D*                                      15  220$CVDD8
417a d  $cvcmd                 1      8
417a d  $cvprg                 9     18
417a d  $cvd6i                19     24
417a d  $cvd8i                25     32
417a d  $cvd6o                33     38  0
417a d  $cvd8o                39     46  0
417a d  $cvsto                47     64
417a d  $cvrtn                65     72
417a d  $cverm                73    132
417a d  $cvmsg                73     76
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     d $mdt            ds
     d  errmsg                 1     50
     d  errcl1                 1     10
     d  errcl2                11     16
416cAD*
416cAd  erp2tp                 1      4
416cAd  erspo                  5     13
416cAd  erp2vl                14     28
416cAD*
     d                 ds
     d  $ec                    1      2p 0
     D*----------------------------------------------------------------
     D*  Error Message(s)
     D*
     d err01           c                   const('1=Select can only be-
     d                                      used once.')
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
     d  rowin                370    370
     d  colin                371    371
     D*----------------------------------------------------------------
     D*  Query file INFDS data structure
     D*
     d ocinf           ds
     d  totrcc               316    319b 0
     d odinf           ds
     d  totrcd               316    319b 0
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
     c                   parm                    $cmd              8
     c                   parm                    $prtky           50
     c                   parm                    $rtncd            8
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c                   move      *on           *in97
     c                   move      *blanks       $rtncd
     c                   call      'BFCADR'
     c                   parm                    $rtn              8
     c     $rtn          ifeq      '*EXPIRED'
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $rtncd
     c                   else
     c                   exsr      zzinz2
     c                   end
     C*
     c     nxtscr        downe     'EOJ'
     c                   exsr      dspscr
     c     nxtscr        caseq     '01 '         sc1
     c     nxtscr        caseq     '02 '         sc2
     c                   endcs
     c                   enddo
     C*
     C*   Do some clean up before leaving.
     C*
     c                   exsr      zsclr
     c                   exsr      clrsch
     C*
     c     $rtncd        ifeq      '*EXIT   '
     c     $rtncd        oreq      '*CANCEL '
     C*
     C*    If processing a Super P/O, update Super P/O status on exit.
     c     $spo          ifeq      '*YES'
     c                   exsr      zzuhdr
     c                   endif
     c                   seton                                        lr
     c                   endif
     c                   return
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
     c                   setoff                                       klki
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
     c                   select
     c     nxtscr        wheneq    '01 '
     c                   select
     C*
     C*    Single line display and NOT a Super P/O.
     c     uxflag        wheneq    *off
     c     $spo          andeq     '*NO '
     C*
     c                   select
     c     view          wheneq    '*POITEM '
     C*
     c                   exsr      sfldsp
     c                   read      postnrec                               50
     c                   read      scanrec                                50
     C*
     c     view          wheneq    '*POMFR  '
     c                   exsr      sflds2
     c                   read      postnrc2                               50
     c                   read      scanrec2                               50
     c                   endsl
     C*
     c                   other
     C*
     c                   select
     c     view          wheneq    '*POITEM '
     c                   exsr      sflds1
     c                   read      postnrec                               50
     c                   read      scanrec                                50
     C*
     c     view          wheneq    '*POMFR  '
     c                   exsr      sflds3
     c                   read      postnrc2                               50
     c                   read      scanrec2                               50
     c                   endsl
     C*
     c                   endsl
     C*
     c     nxtscr        wheneq    '02 '
     c                   exsr      deldsp
     C*
     c                   endsl
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
     c                   select
     c     uxflag        wheneq    *off
     c     $spo          andeq     '*NO '
     c                   select
     c     view          wheneq    '*POITEM '
     c                   read      dspsfc                                 50
     C*
     c     view          wheneq    '*POMFR  '
     c                   read      dspsfc2                                50
     C*
     c                   endsl
     C*
     c                   other
     C*
     c                   select
     c     view          wheneq    '*POITEM '
     c                   read      dspsfc1                                50
     C*
     c     view          wheneq    '*POMFR  '
     c                   read      dspsfc3                                50
     C*
     c                   endsl
     c                   endsl
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
     C*
     C*    If this is a Super P/O, then condition heading on TITLE fmt.
     c     $spo          ifeq      '*YES'
     c                   move      *on           *in40
     c                   else
     c                   move      *off          *in40
     c                   endif
     C*
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
510 AC*
510 AC* Get client id.
510 AC*
510 Ac                   call      @getcl
510 Ac                   parm                    client           10
510 AC*
     C*  Initialize special keys
     C*
     c                   z-add     0             enter             5 0
     c                   z-add     2             comand            5 0
     c                   z-add     01122         rollup            5 0
     c                   z-add     01123         rolldn            5 0
     c                   z-add     01124         clear             5 0
     c                   z-add     01125         help              5 0
     C*
     C*  Initialize message handling
     C*
     c                   exsr      zmimsg
     c                   exsr      zmims4
     C*
     C*  Initialize subfile (DSPSFL) record
     C*
     c                   z-add     1             recno
     c                   write     dspsfl                               79
     c                   write     dspsfl1                              79
     c                   write     dspsfl2                              79
     c                   write     dspsfl3                              79
     c                   z-add     1             recno4
     c                   write     dspsfl4                              79
     c                   write     dspsfl5                              79
417k c                   write     dspsfl7                              79
417l c                   write     dspsfl8                              79
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
510aDc*                  delete    wkorec
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
500e C*
500e C*  TEST FOR CMD11 - Un-touched or ALL
500e C*
500e c     *inkk         ifeq      *on
500e c     noxflg        ifeq      *on
500e c                   move      *off          noxflg
500e c                   else
500e c                   move      *on           noxflg
500e c                   endif
500e c     view          ifeq      '*POITEM '
500e c                   select
500e c     $spo          wheneq    '*NO '
500e c     noxflg        ifeq      *off
500e c                   move      cmdln(1)      cmdln1
500e c                   else
500e c                   move      cmdln(6)      cmdln1
500e c                   endif
500e c     $spo          wheneq    '*YES'
500e c     noxflg        ifeq      *off
500e c                   move      cmdln(3)      cmdln1
500e c                   else
500e c                   move      cmdln(8)      cmdln1
500e c                   endif
500e c                   endsl
500e c                   endif
500e C*
500e c     view          ifeq      '*POMFR  '
500e c                   select
500e c     $spo          wheneq    '*NO '
500e c     noxflg        ifeq      *off
500e c                   move      cmdln(2)      cmdln1
500e c                   else
500e c                   move      cmdln(7)      cmdln1
500e c                   endif
500e c     $spo          wheneq    '*YES'
500e c     noxflg        ifeq      *off
500e c                   move      cmdln(4)      cmdln1
500e c                   else
500e c                   move      cmdln(9)      cmdln1
500e c                   endif
500e c                   endsl
500e c                   endif
500e C*
500e c                   move      '*REFRESH'    pagcmd
500e c                   move      *loval        fkey
500e c                   move      *loval        ukey
500e c                   exsr      pag01
500e c                   endif
     C*
     C*
     C*  TEST FOR CMD9 - Change view.
     C*
     c     *inki         ifeq      *on
     C*
     c                   select
     c     view          wheneq    '*POITEM '
     C*    Process file override for OPNQRYF
     c                   move      '*POMFR  '    ovrtyp
     c     $spo          ifeq      '*YES'
     c                   exsr      zzovr
     C*
     C*    Process OPNQRYF.
     c                   exsr      zzqry
     c                   exsr      zzopn
     c                   endif
     C*
     c                   move      '*POMFR  '    view
     c                   select
     c     $spo          wheneq    '*NO '
500e c     noxflg        ifeq      *off
     c                   move      cmdln(2)      cmdln1
500e c                   else
500e c                   move      cmdln(7)      cmdln1
500e c                   endif
     c     $spo          wheneq    '*YES'
500e c     noxflg        ifeq      *off
     c                   move      cmdln(4)      cmdln1
500e c                   else
500e c                   move      cmdln(9)      cmdln1
500e c                   endif
     c                   endsl
     c                   move      '*REFRESH'    pagcmd
     c                   move      *loval        fkey
     c                   move      *loval        ukey
     c                   exsr      pag01
     C*
     c     view          wheneq    '*POMFR  '
     C*    Process file override for OPNQRYF
     c                   move      '*POITEM '    ovrtyp
     c     $spo          ifeq      '*YES'
     c                   exsr      zzovr
     C*
     C*    Process OPNQRYF.
     c                   exsr      zzqry
     c                   exsr      zzopn
     c                   endif
     C*
     c                   move      '*POITEM '    view
     c                   select
     c     $spo          wheneq    '*NO '
500e c     noxflg        ifeq      *off
     c                   move      cmdln(1)      cmdln1
500e c                   else
500e c                   move      cmdln(6)      cmdln1
500e c                   endif
     c     $spo          wheneq    '*YES'
500e c     noxflg        ifeq      *off
     c                   move      cmdln(3)      cmdln1
500e c                   else
500e c                   move      cmdln(8)      cmdln1
500e c                   endif
     c                   endsl
     c                   move      '*REFRESH'    pagcmd
     c                   move      *loval        fkey
     c                   move      *loval        ukey
     c                   exsr      pag01
     C*
     c                   endsl
     C*
     c                   endif
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
     c     uxflag        ifeq      *off
     c     $spo          andeq     '*NO '
     c                   select
     c     view          wheneq    '*POITEM '
     C*
     c     1             do        10            x
     c     x             chain     dspsfl                             79
     c     *in79         ifeq      *off
     c                   move      '  '          option
     c                   update    dspsfl
     c                   endif
     c                   enddo
     C*
     c     view          wheneq    '*POMFR  '
     C*
     c     1             do        10            x
     c     x             chain     dspsfl2                            79
     c     *in79         ifeq      *off
     c                   move      '  '          option
     c                   update    dspsfl2
     c                   endif
     c                   enddo
     C*
     c                   endsl
     C*
     c                   else
     C*
     c                   select
     c     view          wheneq    '*POITEM '
     C*
     c     1             do        05            x
     c     x             chain     dspsfl1                            79
     c     *in79         ifeq      '0'
     c                   move      '  '          option
     c                   update    dspsfl1
     c                   endif
     c                   enddo
     C*
     c     view          wheneq    '*POMFR  '
     C*
     c     1             do        05            x
     c     x             chain     dspsfl3                            79
     c     *in79         ifeq      '0'
     c                   move      '  '          option
     c                   update    dspsfl3
     c                   endif
     c                   enddo
     C*
     c                   endsl
     c                   endif
     C*
     c                   move      '*REFRESH'    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   endif
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
     c                   move      '*REFRESH'    pagcmd
     c                   exsr      pag01
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
     C*R                   SUB  10        ROW#
     c                   sub       prcrec        row#
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
     c                   z-add     prcrec        nr                2 0
     c                   add       1             nr
     C*R         RECNO     IFLT 11
     c     recno         iflt      nr
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
     c     uxflag        ifeq      '0'
     c                   select
     c     view          wheneq    '*POITEM '
     c                   write     dspsfl
     c     view          wheneq    '*POMFR  '
     c                   write     dspsfl2
     c                   endsl
     c                   else
     c                   select
     c     view          wheneq    '*POITEM '
     c                   write     dspsfl1
     c     view          wheneq    '*POMFR  '
     c                   write     dspsfl3
     c                   endsl
     c                   endif
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
     c     uxflag        ifeq      '0'
     c                   select
     c     view          wheneq    '*POITEM '
     c                   write     dspsfc
     c     view          wheneq    '*POMFR  '
     c                   write     dspsfl2
     c                   endsl
     c                   else
     c                   select
     c     view          wheneq    '*POITEM '
     c                   write     dspsfc1
     c     view          wheneq    '*POITEM '
     c                   write     dspsfc1
     c                   endsl
     c                   endif
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
     c     error         cabeq     *on           ent01e
     c     repos         ifeq      *on
     c                   move      dsfkey        $pofky
     c                   move      '*POSTN2 '    $pocmd
     c                   exsr      fgtway
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   goto      ent01e
     c                   end
     C*
     C*  CHECK IF UPC CODE WAS ENTERED.
     C*
417bDC*R         W1UPC     IFNE *BLANKS
417bMc     w1upcd        ifne      *blanks
     c                   exsr      zzchk1
     c     error         cabeq     *on           ent01e
417h c     optslt        cabeq     *off          ent01e
     c                   move      dsukey        $puky
     c                   exsr      zzchek
     c     error         cabeq     *on           ent01e
     c                   exsr      zzrcv
     c                   move      *on           refrsh
     c                   endif
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
510aDc*                  delete    wkorec
     c                   else
     c                   move      *on           wkoerr
510aDc*                  update    wkorec
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
     c                   move      $pouky        dsukey
     c                   exsr      zzfget
     c     *in79         ifeq      *on
     c                   move      '*NOTFND '    $portn
     c                   move      *blanks       $pouky
     c                   move      *blanks       $pofky
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
     c                   move      *blanks       $pofky
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
     c                   move      *blanks       $pofky
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
     c                   move      $pofky        dsfkey
     c                   select
     c     view          wheneq    '*POITEM '
     c     $spo          andeq     '*NO '
     c     fileky        setll     record
     C*
     c     view          wheneq    '*POMFR  '
     c     $spo          andeq     '*NO '
     c     filky2        setll     record2
     C*
     c     view          wheneq    '*POITEM '
     c     $spo          andeq     '*YES'
     c     filky3        setll     oqreca
     C*
     c     view          wheneq    '*POMFR  '
     c     $spo          andeq     '*YES'
     c     filky4        setll     oqrecb
     C*
     c                   endsl
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
510aDc*                  delete    wkorec
     c                   end
     c     cancel        ifeq      *on
     c                   move      *on           stop
     c     error         ifeq      *on
     c                   move      *on           wkoerr
510aDc*                  update    wkorec
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
     c                   move      *blanks       savpo
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
     c                   goto      endfac
     c                   end
     C*
     C*  RECORD READ - STOP AFTER 10 GOOD RECORDS
     C*  OR EXTENDED DESCRIPTION- STOP AFTER 5 GOOD RECORDS
     C*
     c                   add       1             p
     c                   exsr      sfladd
     C*R         P         IFGE 10
     c     p             ifge      prcrec
     c                   move      *on           stop
     c     forceb        ifeq      *on
     c                   move      *on           bot
     c                   move      'Bottom '     moreln
     c                   else
     c                   move      'More...'     moreln
     c                   end
     c                   end
     c     endfac        tag
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
     C*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     C*
     C*R         DSPLYD    ADD  10        GOBACK  20
     c     dsplyd        add       prcrec        goback            2 0
     c     bot           ifeq      *on
     C*R         GOBACK    IFEQ 10
     c     goback        ifeq      prcrec
     c                   move      *on           forceb
     c                   end
     c                   move      '*BOTTOM '    $pocmd
     c                   exsr      fgtway
     c                   add       1             goback
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
     C*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     C*
510bAc                   if        pdqor1 <> pdqrc1
     c                   add       1             p
510bAc                   endif
     c     p             ifge      goback
     c                   move      *on           stop
     c                   end
     c     endbk         tag
     c                   end
     C*
     C* IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
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
     C*  OR EXTENDED DESCRIPTION- STOP AFTER 5 GOOD RECORDS
     C*
     c     wkoopt        ifeq      ' 4'
     c                   add       1             p
     c                   exsr      deladd
     C*R         P         IFGE 10
     c     p             ifge      prcrec
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
     C*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     C*
     C*R         DSPLYD    ADD  10        GOBACK  20
     c     dsplyd        add       prcrec        goback            2 0
     c     bot           ifeq      *on
     c     wkoprt        setgt     workopt
     c                   add       1             goback
     c                   end
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     c                   z-add     0             p
     c                   move      *off          top
     c                   move      *off          bot
     c                   move      *off          stop
     C*
     C*  READ FILE
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
     C*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     C*
     c     wkoopt        ifeq      ' 4'
     c                   add       1             p
     c     p             ifge      goback
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
     c                   movel     'N'           woyes
     c     nomore        doueq     *on
     c                   move      *off          *in21
     c     uxflag        ifeq      '0'
     c                   select
     c     view          wheneq    '*POITEM '
     c                   readc     dspsfl                                 79
     c     view          wheneq    '*POMFR  '
     c                   readc     dspsfl2                                79
     c                   endsl
     c                   else
     c                   select
     c     view          wheneq    '*POITEM '
     c                   readc     dspsfl1                                79
     c     view          wheneq    '*POMFR  '
     c                   readc     dspsfl3                                79
     c                   endsl
     c                   endif
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
510aDc*                  delete    wkorec
     c                   else
     c                   move      option        wkoopt
     c                   move      *in21         wkoerr
510aDc*                  update    wkorec
     c                   end
     c                   else
     c     option        ifne      *blanks
     c                   move      #user         wkousr
     c                   move      #prog         wkopgm
     c                   move      fkey(y)       wkokyf
     c                   move      ukey(y)       wkokyu
     c                   move      option        wkoopt
     c                   move      *in21         wkoerr
510aDc*                  write     wkorec
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
     C*
     C*    Single line descriptions in use and not a Super P/O.
     c     uxflag        ifeq      *off
     c     $spo          andeq     '*NO '
     C*
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
     C*
     c                   select
     c     view          wheneq    '*POITEM '
510aAc                   if        woqor <> woqrc
     c                   write     dspsfl
510aAc                   else
510aAc                   eval      recno = recno - 1
510aAc                   eval      p = p - 1
510aAc                   endif
     C*
     c     view          wheneq    '*POMFR  '
510aAc                   if        woqor2 <> woqrc2
     c                   write     dspsfl2
510aAc                   else
510aAc                   eval      recno = recno - 1
510aAc                   eval      p = p - 1
510aAc                   endif
     C*
     c                   endsl
     c                   endif
     c                   endif
     C*
     C*  Use extended description or this is a Super P/O.
     C*
     c     uxflag        ifeq      *on
     c     recno         iflt      6
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
     C*
     c                   select
     c     view          wheneq    '*POITEM '
510aAc                   if        woqor <> woqrc
     c                   write     dspsfl1
510aAc                   else
510aAc                   eval      recno = recno - 1
510aAc                   eval      p = p - 1
510aAc                   endif
     C*
     c     view          wheneq    '*POMFR  '
510aAc                   if        woqor2 <> woqrc2
     c                   write     dspsfl3
510aAc                   else
510aAc                   eval      recno = recno - 1
510aAc                   eval      p = p - 1
510aAc                   endif
     C*
     c                   endsl
     c                   endif
     c                   endif
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLAD4   Add record to Window subfile 4
     C*
     c     sflad4        begsr
     C*
     c                   z-add     pdseq         hseq
     c                   move      pditem        hitem
     c                   move      pdvitm        hvitm
     c                   add       1             recno4
     c                   write     dspsfl4
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLAD5   Add record to Window subfile 5
     C*
     c     sflad5        begsr
     C*
     c                   add       1             recno4
     c                   write     dspsfl5
     C*
     c                   endsr
417a C*----------------------------------------------------------------
417a C*
417a C*  SFLAD6   Add record to Window subfile 6
417a C*
417a c     sflad6        begsr
417a C*
417a c                   add       1             recno4
417a c                   write     dspsfl6
417a C*
417a c                   endsr
417k C*----------------------------------------------------------------
417k C*
417k C*  SFLAD7   Add record to Window subfile 7
417k C*
417k c     sflad7        begsr
417k C*
417k c                   add       1             recno4
417k c                   write     dspsfl7
417k C*
417k c                   endsr
417l C*----------------------------------------------------------------
417l C*
417l C*  SFLAD8   Add record to Window subfile 8
417l C*
417l c     sflad8        begsr
417l C*
417l c                   add       1             recno4
417l c                   write     dspsfl8
417l C*
417l c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLCLR   Clear display subfile
     C*
     c     sflclr        begsr
     C*
     C*  CLEAR DISPLAY SUBFILE
     C*
     c                   move      *off          *in01
     c                   select
     c     uxflag        wheneq    *off
     c     $spo          andeq     '*NO '
     c                   select
     c     view          wheneq    '*POITEM '
     c                   write     dspsfc
     C*
     c     view          wheneq    '*POMFR  '
     c                   write     dspsfc2
     C*
     c                   endsl
     C*
     c                   other
     C*
     c                   select
     c     view          wheneq    '*POITEM '
     c                   write     dspsfc1
     C*
     c     view          wheneq    '*POMFR  '
     c                   write     dspsfc3
     C*
     c                   endsl
     c                   endsl
     C*
     c                   z-add     0             recno             4 0
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLDSP   Display subfile , Item seq - Single line description.
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
     c                   write     scanrec
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
     C*  SFLDS1   Display subfile 1 , Item Seq - Extended description.
     C*
     c     sflds1        begsr
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
     c                   write     scanrec
     C*
     C*  GET ANY EXISTING VALUES FOR THE OPTIONS
     C*
     c                   exsr      sflop1
     C*
     C*  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     C*
     c     error         ifne      '1'
     c     1             chain     dspsfl1                            79
     c     *in79         ifeq      '0'
     c                   move      '1'           *in20
     c                   update    dspsfl1
     c                   end
     c                   end
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     c                   move      '1'           *in01
     c                   z-add     1             recno
     c                   write     dspsfc1
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLDS2   Display subfile 2 - Mfr# Seq - Single line desc.
     C*
     c     sflds2        begsr
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
     c                   write     postnrc2
     c                   write     scanrec2
     C*
     C*  GET ANY EXISTING VALUES FOR THE OPTIONS
     C*
     c                   exsr      sflop2
     C*
     C*  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     C*
     c     error         ifne      *on
417nDC*R         1         CHAINDSPSFL               79
417nMc     1             chain     dspsfl2                            79
     c     *in79         ifeq      *off
     c                   move      *on           *in20
     c                   update    dspsfl2
     c                   endif
     c                   endif
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     c                   move      *on           *in01
     c                   z-add     1             recno
     c                   write     dspsfc2
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLDS3   Display subfile 3 , Mfr# Seq. Extended description
     C*
     c     sflds3        begsr
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
     c                   write     postnrc2
     c                   write     scanrec2
     C*
     C*  GET ANY EXISTING VALUES FOR THE OPTIONS
     C*
     c                   exsr      sflop3
     C*
     C*  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     C*
     c     error         ifne      *on
     c     1             chain     dspsfl3                            79
     c     *in79         ifeq      *off
     c                   move      *on           *in20
     c                   update    dspsfl3
     c                   endif
     c                   endif
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     c                   move      *on           *in01
     c                   z-add     1             recno
     c                   write     dspsfc3
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLOPT   Initialize options for subfile
     C*
     c     sflopt        begsr
     c     1             do        prcrec        x                 3 0
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
     c                   endif
     c                   update    dspsfl
     c                   endif
     c                   enddo
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLOP1   Initialize options for subfile 1, extended description
     C*
     c     sflop1        begsr
     c     1             do        05            x                 3 0
     c     x             chain     dspsfl1                            79
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
     c                   endif
     c                   update    dspsfl1
     c                   endif
     c                   enddo
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLOP2   Initialize options for subfile 2 - Single line Mfr seq.
     C*
     c     sflop2        begsr
     c     1             do        prcrec        x                 3 0
     c     x             chain     dspsfl2                            79
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
     c                   endif
     c                   update    dspsfl2
     c                   endif
     c                   enddo
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLOP3   Initialize options for subfile 3, ext. desc. Mfr# Seq.
     C*
     c     sflop3        begsr
     c     1             do        05            x                 3 0
     c     x             chain     dspsfl3                            79
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
     c                   endif
     c                   update    dspsfl3
     c                   endif
     c                   enddo
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
     C*    ZMCMS4  Clear message record subfile in WINDOW4
     C*
     c     zmcms4        begsr
     c                   move      *off          *in97
     c                   write     msgctl4
     c                   move      *zeros        msgk4             4 0
     c                   move      '*CLEAR '     #msgid
     c                   move      '*NULL  '     #msgtp
     c                   exsr      zmpms4
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
     C*    ZMDMS4  Display message record subfile in WINDOW4
     C*
     c     zmdms4        begsr
     c                   write     msgclr4
     c                   move      *on           *in97
     c     msgk4         ifgt      0
     c                   write     msgctl4
     c                   z-add     *zero         msgk4
     c                   endif
     c                   endsr
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     c     zmimsg        begsr
     c                   move      #prog         #pgmq            10
     c                   exsr      zmcmsg
     c                   endsr
     C*
     C*    ZMIMS4  Initialization necessary for message subfile in WINDOW4
     C*
     c     zmims4        begsr
     c                   move      #prog         #pgmq            10
     c                   exsr      zmcms4
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
     C*    ZMPMS4  Add message record to subfile in WINDOW4
     C*
     c     zmpms4        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   endif
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm      #prog         #pgmq
     c                   parm                    #msgk
     c     #msgid        ifne      '*CLEAR '
     c                   add       1             msgk4
     c                   write     msgrec4
     c                   endif
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
     C*    ZMQMS4  Add message record to subfile from pgm queue in WINDOW4
     C*
     c     zmqms4        begsr
     c                   add       1             msgk4
     c                   write     msgrec4
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
416cAC*----------------------------------------------------------------
416cAC*    PO13236  Position to x not found on Super P/O.
416cAC*
416cAc     zm3236        begsr
416cAc                   move      'PO13236'     #msgid
416cAc                   move      '*DIAG  '     #msgtp
416cAc                   movea     errmsg        $md(1)
416cAc                   exsr      zmpmsg
416cAc                   endsr
     C*----------------------------------------------------------------
     C*    PO20027  Item not on PO.
     C*
     c     zm027         begsr
     c                   move      'PO20027'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*    PO20029  UPC not on file.
     C*
     c     zm029         begsr
     c                   move      'PO20029'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*    IT12001  Item does not have a link record.
     C*
     c     zm1201        begsr
     c                   move      'IT12001'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*    IT12212  Item does not have a Piritem record.
     C*
     c     zm2212        begsr
     c                   move      'IT12212'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*    IT12002  Item does not have a pick slot.
     C*
     c     zm1202        begsr
     c                   move      'IT12002'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
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
     C*
     c     z40105        begsr
     c                   move      'PIR0105'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpms4
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
     C*    Error message for WINDOW4.
     c     z40108        begsr
     c                   move      'PIR0108'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movel     option        errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpms4
     c                   endsr
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
     C*
     C*  ZZCMD    Process non-standard function keys
     C*
     c     zzcmd         begsr
     C*
     C*  TEST FOR CMD07 - Sub totals.
     C*
     c     *inkg         ifeq      *on
     C*
     c                   move      '*SUBTOTL'    ovrtyp
     c                   exsr      zzwdw
     C*
     c                   goto      endcm1
     c                   endif
500 AC*
500 AC*  TEST FOR CMD08 - Item Sub totals.
500 AC*
500 Ac     *inkh         ifeq      *on
500 AC*
500 Ac                   move      '*SUBITTL'    ovrtyp
500 Ac                   exsr      zzwdw
500 AC*
500 Ac                   goto      endcm1
500 Ac                   endif
     C*
     C*  TEST FOR CMD23 - More options
     C*
     c     *inkx         ifeq      *on
     c     viewo         ifeq      maxvwo
     c                   z-add     1             viewo
     c                   else
     c                   add       1             viewo
     c                   endif
     c     viewo         mult      2             v                 2 0
PCK Ac                   select
PCK Ac     client        wheneq    packers
PCK Ac                   move      optlnp(v)     optln2
PCK Ac                   sub       1             v
PCK Ac                   move      optlnp(v)     optln1
PCK Ac                   other
     c                   move      optln(v)      optln2
     c                   sub       1             v
     c                   move      optln(v)      optln1
PCK Ac                   endsl
500cAc     $cmd          ifeq      '*SPRECV'
500cAc     v             andeq     1
500cAc                   move      optlns(v)     optln1
500cAc                   endif
     c                   goto      endcm1
     c                   end
     C*
     C*  TEST FOR CMD24 - More Keys
     C*
     c     *inky         ifeq      *on
     c                   add       1             k
     c     k             ifgt      2
     c                   z-add     1             k
     c                   endif
     C*
     c                   select
     c     k             wheneq    1
     c                   select
     c     view          wheneq    '*POITEM '
500e c     $spo          andeq     '*YES'
     c                   movel     cmdln(3)      cmdln1
     c     view          wheneq    '*POMFR  '
500e c     $spo          andeq     '*YES'
     c                   movel     cmdln(4)      cmdln1
500e c     view          wheneq    '*POITEM '
500e c     $spo          andeq     '*NO '
500e c                   movel     cmdln(1)      cmdln1
500e c     view          wheneq    '*POMFR  '
500e c     $spo          andeq     '*NO '
500e c                   movel     cmdln(2)      cmdln1
     c                   endsl
     c     k             wheneq    2
     c                   movel     cmdln(5)      cmdln1
     c                   endsl
     C*
     c                   goto      endcm1
     c                   endif
     C*
     c     endcm1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     c     zzchk1        begsr
     c                   move      *off          error
     C*
     c                   move      *off          noupc             1
417m c                   move      *off          upcok             1
     C*
     C*  UPC not entered.
     C*
417bDC*R         W1UPC     IFEQ *BLANKS
417bMc     w1upcd        ifeq      *blanks
     c                   move      *on           noupc
     c                   move      *blanks       woupc            20
     c                   endif
     C*
     C*  UPC code not on file.
     C*
417bDC*R         W1UPC     IFNE *BLANKS
417bMc     w1upcd        ifne      *blanks
417bDC*R                   MOVE W1UPC     WOUPC
417bAC*
     C*  Extract UPC code from entered string.
     C*
     c                   move      '*UPC    '    $cbcmd
     c                   movel(p)  w1upcd        $cbbar
     C*
     c                   call      'CVTBAR'
     c                   parm                    $cbcmd            8
     c                   parm                    $cbbar          100
     c                   parm                    $cbcod            3 0
     c                   parm                    $cbdec            1 0
     c                   parm                    $cbdsc           30
     c                   parm                    $cbpos            3 0
     c                   parm                    $cbtyp            1 0
     c                   parm                    $cbv1            11 3
     c                   parm                    $cbv2            50
     c                   parm                    $cbrtn            8
     c                   parm                    $cberm           60
     C*
     c                   select
417hMC**         $CBRTN    WHEQ '*OK'
417hAc     $cbrtn        whenne    '*INVALID'
     C*
     C*   Right adjust UPC code for file.
     C*
     c                   movel     *blanks       $cstr
417bDC*R                   MOVELW1UPC     $CSTR
     c                   movel     $cbv2         $cstr
     c                   call      'ADJUST'
     c                   parm      '*RIGHT  '    $ccmd             8
     c                   parm                    $cstr            30
     c                   move      $cstr         w1upc
417a C*   Check if mulitple items exist for one UPC code.
417a C*    UPCCTR = 0, error, upc code not found.
417a C*    UPCCTR = 1, only one upc found, process for item.
417a C*    UPCCTR > 1, multiple upc found, need to select item.
417a c                   z-add     0             upcctr            3 0
417a c     upckey        setll     upc
417a c     forevr        doweq     forevr
417a c     upckey        reade     upc                                    79
     C*
417a c     *in79         ifeq      *on
417a c                   leave
417a c                   else
417a c                   add       1             upcctr
417a c                   endif
     C*
417a c                   enddo
     C*
417aDC**         UPCKEY    CHAINUPC                  79
417aDC**         *IN79     IFEQ *ON
417a c     upcctr        ifeq      0
     c                   move      *on           error
     c                   move      *on           *in29
     c                   move      *on           *in09
     c                   exsr      zm029
     c                   move      *on           noupc
     c                   endif
     C*   Multiple items exist for UPC
417m c     upcctr        ifeq      1
417m c                   move      *on           upcok
417m c                   endif
417a c     upcctr        ifgt      1
417a c                   move      '*UPCSLCT'    ovrtyp
417a c                   exsr      zzwdw
417a c                   endif
417bAC*
417bAC*    If extract of UPC comes back invalid, treat UPC as if not
417bAC*    on file.
     c                   other
     c                   move      *on           error
     c                   move      *on           *in29
     c                   move      *on           *in09
     c                   exsr      zm029
     C*    Log barcode conversion error.
     c                   movel     $cberm        errmsg
     c                   exsr      zm0105
     c                   move      *on           noupc
     c                   endsl
     C*
     C*   Verify Item exists on PO.
     C*
     c     noupc         ifeq      *off
     c                   select
     C*    Single P/O being processed.
     c     $spo          wheneq    '*NO '
     C*
     c                   move      upitem        woitm#           15
     c     podky1        setll     podtl1                             79
     c     podky1        reade     podtl1                                 79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   move      *on           *in27
     c                   move      *on           *in07
417m c                   move      *off          upcok
     c                   exsr      zm027
417i c                   else
417i c                   move      *on           optslt
417m c                   move      *on           upcok
     c                   endif
     C*
     C*    Super P/O being processed.
     c     $spo          wheneq    '*YES'
     c                   move      upitem        ptinp1
     c                   move      upitem        pditem
     c                   move      '*SLCTITM'    ovrtyp
     c                   exsr      zzwdw
     c                   move      *blanks       ptinp1
     c                   select
     C*    UPC not found on any P/O.
     c     repos         wheneq    *off
     c                   move      *on           error
     c                   move      *on           *in27
     c                   move      *on           *in07
417m c                   move      *off          upcok
     c                   exsr      zm027
416aAC*    UPC found and selected for one p/o.
416aAc     repos         wheneq    *on
416aAc                   z-add     hseq          pdseq
416aAc                   move      hitem         pditem
416aAc                   move      hvitm         pdvitm
417jAc                   move      *on           optslt
417m c                   move      *on           upcok
     c                   endsl
     C*
     c                   endsl
     C*
     C*    Clear position to save fields when working with UPC.
     c                   move      *blanks       svp2po
     c                   move      *blanks       svp2vl
     C*
     c                   endif
     C*
     c                   endif
     C*
     c     endck1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHEK   Screen 1 EXTRA error checking.
     C*
     c     zzchek        begsr
500gAC*
500gAC*   Do HACCP Checks
500gAC*
500gAc     wkoopt        ifeq      ' 1'
500gAc                   move      '*DTLCHK '    $pcmd
500gAc                   call      'PO170'
500gAc                   parm                    $parms
500gAc     $prtn         ifeq      '*PGMQ   '
500gAc                   move      *on           error
500gAc                   move      $pmsg         #msgk
500gAc                   exsr      zmqmsg
500gAc                   goto      endchk
500gAc                   endif
500gAc                   endif
     c     itkey2        chain     piritem                            79
     c     *in79         ifeq      *on
     c                   move      *blanks       ittype
     c                   move      *on           error
     c                   exsr      zm2212
     c                   endif
     C*  Item link record must exist.
     c     ittype        ifeq      'A'
     c     ittype        oreq      'B'
     c     ittype        oreq      'C'
     c     ittype        oreq      'S'
     c     ilkey         chain     itemlnk                            79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm1201
     c                   endif
     c                   endif
     C*  Fixed item - Pick slot must exist
     c     itstyp        ifeq      'F'
     c                   select
     c     ittype        wheneq    ' '
     c                   move      $pitem        bsitem           15
     c                   move      'A '          bsstat            2
     c                   move      'Y'           bspick            1
     c     slkey3        setll     slot3
     c     forevr        doweq     forevr
     c     slkey3        reade     slot3                                  79
     C*
     c     *in79         ifeq      *off
     c     slpick        andeq     'Y'
     c                   goto      endchk
     c                   endif
     C*
     c     *in79         ifeq      *on
     C*R                   MOVE *ON       ERROR
     C*R                   EXSR ZM1202
     c                   goto      endchk
     c                   endif
     C*
     c                   enddo
     C*
     c     ittype        wheneq    'A'
     c     ittype        oreq      'B'
     c     ittype        oreq      'C'
     c     ittype        oreq      'S'
     c     ilkey         chain     itemlnk                            79
     c     *in79         ifeq      *off
     c                   move      ilitm2        bsitem           15
     c                   endif
     c                   move      'A '          bsstat            2
     c                   move      'Y'           bspick            1
     c     slkey3        setll     slot3
     c     forevr        doweq     forevr
     c     slkey3        reade     slot3                                  79
     C*
     c     *in79         ifeq      *off
     c     slpick        andeq     'Y'
     c                   goto      endchk
     c                   endif
     C*
     c     *in79         ifeq      *on
500fDC*                    MOVE *ON       ERROR
500fDC*                    EXSR ZM1202
     c                   goto      endchk
     c                   endif
     C*
     c                   enddo
     C*
     c                   endsl
     c                   endif
     c     endchk        endsr
     C*----------------------------------------------------------------
     C*
416fAC*  ZZDESG   Check dept-designation file fro putaway method.
416fAC*
416fAc     zzdesg        begsr
     c     itkey2        chain     piritem                            79
     c     *in79         ifeq      *on
     c                   goto      enddsg
     c                   endif
     C*
     c     ddkeyp        setll     deptdsg
     c                   move      *off          puttyp            1
     c     forevr        doweq     forevr
     c     ddkeyp        reade     deptdsg                                79
     c     *in79         ifeq      *on
     c                   leave
     c                   endif
     c     dddesg        ifeq      itdesg
     c                   move      *on           puttyp
     c                   leave
     c                   endif
     c                   enddo
416fAc     enddsg        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGET   Get record with unique key.
     C*
     c     zzfget        begsr
     C*
     C*    Code to use when file key and unique key are the same.
     C*
     c     filuky        chain     record                             79
     C*
     C*    Code to use when file key and unique key are different.
     C*
     C*R         FILUKY    CHAINRECORDU              79
     C*
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
     C*R                   READ RECORD                   79
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     c                   select
     c     view          wheneq    '*POITEM '
     c     $spo          andeq     '*NO '
     c     partky        reade     record                                 79
     C*
     c     view          wheneq    '*POMFR  '
     c     $spo          andeq     '*NO '
     c     partky        reade     record2                                79
     C*
     c     view          wheneq    '*POITEM '
     c     $spo          andeq     '*YES'
     c     prtky2        reade     oqreca                                 79
     c     *in79         ifeq      *off
     c     pdkey         chain     podtl                              77
     c                   endif
     C*
     c     view          wheneq    '*POMFR  '
     c     $spo          andeq     '*YES'
     c     prtky2        reade     oqrecb                                 79
     c     *in79         ifeq      *off
     c     pdkey         chain     podtl                              77
     c                   endif
     C*
     c                   endsl
     C*
500e C**   See if we only want untouched lines.
500e c     noxflg        ifeq      *on
500e c     *in79         andeq     *off
500e c     detlky        chain     podtl3                             84
500e c     *in84         cabeq     *off          try1
500e c                   endif
     C*
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
     C*R                   READPRECORD                   79
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     c                   select
     c     view          wheneq    '*POITEM '
     c     $spo          andeq     '*NO '
     c     partky        readpe    record                                 79
     C*
     c     view          wheneq    '*POMFR  '
     c     $spo          andeq     '*NO '
     c     partky        readpe    record2                                79
     C*
     c     view          wheneq    '*POITEM '
     c     $spo          andeq     '*YES'
     c     prtky2        readpe    oqreca                                 79
     c     *in79         ifeq      *off
     c     pdkey         chain     podtl                              77
     c                   endif
     C*
     c     view          wheneq    '*POMFR  '
     c     $spo          andeq     '*YES'
     c     prtky2        readpe    oqrecb                                 79
     c     *in79         ifeq      *off
     c     pdkey         chain     podtl                              77
     c                   endif
     C*
     c                   endsl
     C*
500e C**   See if we only want untouched lines.
500e c     noxflg        ifeq      *on
500e c     *in79         andeq     *off
500e c     detlky        chain     podtl3                             84
500e c     *in84         cabeq     *off          try2
500e c                   endif
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFILL   Fill display line with values that need
     C*           to be converted.
     C*
     c     zzfill        begsr
     C*
     c                   select
     c     view          wheneq    '*POMFR  '
     c                   move      pdvitm        womfr
     c                   endsl
     C*
     c     uxflag        ifeq      '1'
     c     itkey         chain     itemdsc                            79
     c     *in79         ifeq      *on
     c                   move      *blanks       wodsc1
     c                   move      *blanks       wodsc2
     c                   else
     c                   movel     ixdsc1        wodsc1
     c                   movel     ixdsc2        wodsc2
     c                   endif
     C*  GET PACK DESCRIPTION
     c     itkey         chain     piritem                            79
     c     *in79         ifeq      *off
     c                   movel     itpdsc        wopdsc
     c                   else
     c                   move      *blanks       wopdsc
     c                   endif
     C*
     C*    If no extended description found for the item,
     C*    Load description from item.
     c     *in79         ifeq      *off
     c     wodsc1        andeq     *blanks
     c     wodsc2        andeq     *blanks
     c                   movel     itdesc        wodsc1
     c                   endif
     C*
     C*  GET TIE HI, PREFERRED OR 1ST RECORD.
     c                   move      *off          done              1
     c                   z-add     0             wotie
     c                   z-add     0             wohi
     c                   z-add     0             svtie             4 0
     c                   z-add     0             svhi              2 0
     c     partk2        setll     itemdef
     c     done          doueq     *on
     c     partk2        reade     idrec                                  79
     c     *in79         ifeq      *on
     c                   move      *on           done
     c                   else
     c     svtie         ifeq      0
     c     svhi          andeq     0
     c                   z-add     idtie         svtie
     c                   z-add     idhigh        svhi
     c                   endif
     c     idpref        ifeq      'Y'
     c                   z-add     idtie         wotie
     c                   z-add     idhigh        wohi
     c                   move      *on           done
     c                   endif
     c                   endif
     c                   enddo
     c     wotie         ifeq      0
     c     wohi          andeq     0
     c                   z-add     svtie         wotie
     c                   z-add     svhi          wohi
     c                   endif
     C*
     C*    When processing a Super P/O, load the individual P/O number
     C*    in the subfile everytime the individual p/o changes.
     c     $spo          ifeq      '*YES'
     c     savpo         ifne      pdpo
     c                   move      'PO:'         wopotx
     c                   move      pdpo          wopo#
     c                   move      pdpo          savpo
     C*
     c                   else
     c                   move      *blanks       wopotx
     c                   move      *blanks       wopo#
     c                   endif
     c                   endif
     C*
     c                   else
     C*
     C*    Single line display.
     C*
     c     itkey         chain     piritem                            79
     c     *in79         ifeq      *off
     c                   movel     itdesc        wodsc
     c                   else
     c                   move      *blanks       wodsc
     c                   end
     c                   endif
     C*
     C*   Convert quantity to string.
     C*
     c                   move      '*QTY2STR'    $ccmd
     c                   move      '#PROG   '    $cprg
     c                   z-add     pdqor1        $cqty1
     c                   z-add     pdqor2        $cqty2
     c                   z-add     pdqor3        $cqty3
     c                   exsr      zzcvqy
     C*
     c                   select
     C*    Single line display.
     c     uxflag        wheneq    *off
     c                   select
     C*    Item display.
     c     view          wheneq    '*POITEM '
     c                   movel     $cqstr        woqor
     C*    Mfr display.
     c     view          wheneq    '*POMFR  '
     c                   movel     $cqstr        woqor2
     c                   endsl
     C*
     C*    Extended line display.
     c     uxflag        wheneq    *on
     c                   select
     C*    Item display.
     c     view          wheneq    '*POITEM '
     c                   movel     $cqstr        woqor
     C*    Mfr display.
     c     view          wheneq    '*POMFR  '
     c                   movel     $cqstr        woqor2
     c                   endsl
     c                   endsl
     C*
     c                   move      '*QTY2STR'    $ccmd
     c                   move      '#PROG   '    $cprg
     c                   z-add     pdqrc1        $cqty1
     c                   z-add     pdqrc2        $cqty2
     c                   z-add     pdqrc3        $cqty3
     c                   exsr      zzcvqy
     C*
     c                   select
     C*    Single line display.
     c     uxflag        wheneq    *off
     c                   select
     C*    Item display.
     c     view          wheneq    '*POITEM '
     c                   movel     $cqstr        woqrc
     C*    Mfr display.
     c     view          wheneq    '*POMFR  '
     c                   movel     $cqstr        woqrc2
     c                   endsl
     C*
     C*    Extended line display.
     c     uxflag        wheneq    *on
     c                   select
     C*    Item display.
     c     view          wheneq    '*POITEM '
     c                   movel     $cqstr        woqrc
     C*    Mfr display.
     c     view          wheneq    '*POMFR  '
     c                   movel     $cqstr        woqrc2
     c                   endsl
     c                   endsl
     C*
     C**   See if line has been touched.  Flag accordingly.
     c     detlky        chain     podtl3                             84
     c     *in84         ifeq      *on
     c                   movel     *blanks       touch
     c                   else
     c                   movel     'X'           touch
     c                   endif
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL4   Fill window subfile with values to be converted.
     C*
     c     zzfil4        begsr
     C*
     c                   move      pdpo          wopo4
     C*
     c                   select
     C*    User selected P/O sub-totals.
     c     ovrtyp        wheneq    '*SUBTOTL'
     c     svpo          andeq     pdpo
     C*
     c                   add       pdqor1        tqyor1
     c                   add       pdqor2        tqyor1
     c                   add       pdqor3        tqyor1
     C*
     c                   add       pdqrc1        tqyrc1
     c                   add       pdqrc2        tqyrc1
     c                   add       pdqrc3        tqyrc1
     C*
     C*    User selected sub-totals - P/O changed - convert quantities.
     c     ovrtyp        wheneq    '*SUBTOTL'
     c     svpo          andne     pdpo
     C*
     C*    End of file - replace low values with last po read.
     c     svpo          ifeq      *loval
     c                   move      pdpo          svpo
     c                   move      pdpo          wopo4
     c                   else
     c                   move      svpo          wopo4
     c                   endif
     C*
510adc*    phky2         chain(n)  pohdr                              77
510aac     phky2         chain     pohdr                              77
     c     *in77         ifeq      *on
     c                   move      *zeros        phven
     c                   endif
     C*
     c                   z-add     phven         woven
     C*
     C*   Convert Total quantity ordered to string.
     c                   move      '*QTY2STR'    $ccmd
     c                   move      '#PROG   '    $cprg
     c                   z-add     tqyor1        $cqty1
     c                   move      *zeros        $cqty2
     c                   move      *zeros        $cqty3
     c                   exsr      zzcvqy
     c                   movel     $cqstr        woqor
     C*
     C*   Convert Total quantity received to string.
     c                   move      '*QTY2STR'    $ccmd
     c                   move      '#PROG   '    $cprg
     c                   z-add     tqyrc1        $cqty1
     c                   move      *zeros        $cqty2
     c                   move      *zeros        $cqty3
     c                   exsr      zzcvqy
     c                   movel     $cqstr        woqrc
     C*
     c                   other
     C*
510adc*    phkey         chain(n)  pohdr                              77
510aac     phkey         chain     pohdr                              77
     c     *in77         ifeq      *on
     c                   move      *zeros        phven
     c                   endif
     C*
     c                   z-add     phven         woven
     C*
     C*   Convert quantity ordered to string.
     c                   move      '*QTY2STR'    $ccmd
     c                   move      '#PROG   '    $cprg
     c                   z-add     pdqor1        $cqty1
     c                   z-add     pdqor2        $cqty2
     c                   z-add     pdqor3        $cqty3
     c                   exsr      zzcvqy
     c                   movel     $cqstr        woqor
     C*
     C*   Convert quantity received to string.
     c                   move      '*QTY2STR'    $ccmd
     c                   move      '#PROG   '    $cprg
     c                   z-add     pdqrc1        $cqty1
     c                   z-add     pdqrc2        $cqty2
     c                   z-add     pdqrc3        $cqty3
     c                   exsr      zzcvqy
     c                   movel     $cqstr        woqrc
     C*
     c                   endsl
     C*
     c     endfl4        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL5   Fill window subfile with values to be converted.
     C*
     c     zzfil5        begsr
     C*
     c                   move      pdpo          w5po
     c                   z-add     pdseq         hseq
     C*
     c                   select
     C*    When position to item is selected, item number is loaded on
     C*    on first line of subfile record.
     c     ovrtyp        wheneq    '*POS2ITM'
     c                   move      pditem        w5val1
     c                   move      pdvitm        w5val2
     C*
     C*    When position to Mfr# is selected, Manufacturer is loaded on
     C*    on first line of subfile record.
     c     ovrtyp        wheneq    '*POS2MFR'
     c                   move      pdvitm        w5val1
     c                   move      pditem        w5val2
     C*
     c                   endsl
     C*
     C*    Extended item description in use.
     c     uxflag        ifeq      '1'
     c     itkey         chain     itemdsc                            79
     c     *in79         ifeq      *on
     c                   move      *blanks       w5desc
     c                   else
     c                   movel     ixdsc1        w5desc
     c                   endif
     c                   endif
     C*
     C*    Get pack description.
     c     itkey         chain     piritem                            79
     c     *in79         ifeq      *off
     c                   movel     itpdsc        w5pdsc
     c                   else
     c                   move      *blanks       w5pdsc
     c                   endif
     C*
     C*    If no extended description found for the item,
     C*    Load description from item.
     c     *in79         ifeq      *off
     c     w5desc        andeq     *blanks
     c                   movel(p)  itdesc        w5desc
     c                   endif
     C*
     c     endfl5        endsr
     C*----------------------------------------------------------------
417a C*
417a C*  ZZFIL6   Fill window subfile with values to be converted.
417a C*
417a c     zzfil6        begsr
417a C*
417a c                   movel     'Mfr:'        w6txt2
417a C*
417a C*    Extended item description in use.
417a c     uxflag        ifeq      '1'
417A c     i6key         chain     itemdsc                            79
417a c     *in79         ifeq      *on
417a c                   move      *blanks       w6desc
417a c                   else
417a c                   movel     ixdsc1        w6desc
417a c                   endif
417a c                   endif
417a C*
417a C*    Get pack description.
417A c     i6key         chain     piritem                            79
417a c     *in79         ifeq      *off
417a c                   movel     itpdsc        w6pdsc
417a c                   else
417a c                   move      *blanks       w6pdsc
417a c                   endif
417a C*
417a C*    If no extended description found for the item,
417a C*    Load description from item.
417a c     *in79         ifeq      *off
417A C***        W6DESC    ANDEQ*BLANKS
417a c                   movel(p)  itdesc        w6desc
417a c                   endif
417a C*
417a C*    Get brand.
417A c     i6key         chain     itemmsc                            79
417a c     *in79         ifeq      *off
417a c                   movel     imbrnd        w6brnd
417a c                   else
417a c                   move      *blanks       w6brnd
417a c                   endif
417a C*
417a C*    Get pick slot.
417a c                   move      pditem        bsitem           15
417a c                   move      'A '          bsstat            2
417a c                   move      'Y'           bspick            1
417a c     slkey3        setll     slot3
417a c     forevr        doweq     forevr
417a c     slkey3        reade     slot3                                  79
417a C*
417a c                   move      *blanks       w6pslt
417a c     *in79         ifeq      *off
417a c     slpick        andeq     'Y'
417a c                   move      sldisp        w6pslt
417a c                   endif
417a c                   leave
417a c                   enddo
     C*
417a C*
417a c     endfl6        endsr
417k C*----------------------------------------------------------------
417k C*
417k C*  ZZFIL7   Fill window subfile with values to be converted.
417k C*
417k c     zzfil7        begsr
417k C*
417k c                   move      pdpo          wopo4
417k C*
417k c                   select
417k C*    User selected item sub-totals.
417k c     ovrtyp        wheneq    '*SUBITTL'
417k C*
417k c                   add       pdqor1        tqyor1
417k c                   add       pdqor2        tqyor1
417k c                   add       pdqor3        tqyor1
417k C*
417k c                   add       pdqrc1        tqyrc1
417k c                   add       pdqrc2        tqyrc1
417k c                   add       pdqrc3        tqyrc1
417k C*
417k C*
417k C***        PHKY2     CHAINPOHDR               N77
417k C***        *IN77     IFEQ *ON
417k C***                  MOVE *ZEROS    PHVEN
417k C***                  ENDIF
417k C*
417k C****                 Z-ADDPHVEN     WOVEN
417k C*
417k c     uxflag        ifeq      '1'
417k c     itkey         chain     itemdsc                            79
417k c     *in79         ifeq      *on
417k c                   move      *blanks       w7desc
417k c                   else
417k c                   movel     ixdsc1        w7desc
417k c                   endif
417k c                   endif
417k c     itkey         chain     piritem                            79
417k C*    If no extended description found for the item,
417k C*    Load description from item.
417k c     *in79         ifeq      *off
417k c     w7desc        andeq     *blanks
417k c                   movel     itdesc        w7desc
417k c                   endif
417k C*
417k c                   move      pditem        woitm
417k c                   z-add     pdseq         woseq
417k C*
417k C*   Convert Total quantity ordered to string.
417k c                   move      '*QTY2STR'    $ccmd
417k c                   move      '#PROG   '    $cprg
417k c                   z-add     tqyor1        $cqty1
417k c                   move      *zeros        $cqty2
417k c                   move      *zeros        $cqty3
417k c                   exsr      zzcvqy
417k c                   movel     $cqstr        woqor
417k C*
417k C*   Convert Total quantity received to string.
417k c                   move      '*QTY2STR'    $ccmd
417k c                   move      '#PROG   '    $cprg
417k c                   z-add     tqyrc1        $cqty1
417k c                   move      *zeros        $cqty2
417k c                   move      *zeros        $cqty3
417k c                   exsr      zzcvqy
417k c                   movel     $cqstr        woqrc
417k C*
417k c                   endsl
417k C*
417k c     endfl7        endsr
417l C*----------------------------------------------------------------
417l C*
417l C*  ZZFIL8   Fill window subfile with values to be converted.
417l C*
417l c     zzfil8        begsr
417l C*
417l c                   move      pdpo          w8po
417l C*
417l c                   select
417l C*    User selected item sub-totals.
417l c     ovrtyp        wheneq    '*SUBITTL'
417l C*
417l c                   add       pdqor1        tqyor1
417l c                   add       pdqor2        tqyor1
417l c                   add       pdqor3        tqyor1
417l C*
417l c                   add       pdqrc1        tqyrc1
417l c                   add       pdqrc2        tqyrc1
417l c                   add       pdqrc3        tqyrc1
417l C*
417l c     uxflag        ifeq      '1'
417l c     itkey         chain     itemdsc                            79
417l c     *in79         ifeq      *on
417l c                   move      *blanks       w8desc
417l c                   else
417l c                   movel     ixdsc1        w8desc
417l c                   endif
417l c                   endif
417l c     itkey         chain     piritem                            79
417l C*    If no extended description found for the item,
417l C*    Load description from item.
417l c     *in79         ifeq      *off
417l c     w8desc        andeq     *blanks
417l c                   movel     itdesc        w8desc
417l c                   endif
417l C*
417l c                   move      pditem        woitm
417l c                   z-add     pdseq         woseq
417l C*
417l C*   Convert Total quantity ordered to string.
417l c                   move      '*QTY2STR'    $ccmd
417l c                   move      '#PROG   '    $cprg
417l c                   z-add     tqyor1        $cqty1
417l c                   move      *zeros        $cqty2
417l c                   move      *zeros        $cqty3
417l c                   exsr      zzcvqy
417l c                   movel     $cqstr        woqor8
417l C*
417l C*   Convert Total quantity received to string.
417l c                   move      '*QTY2STR'    $ccmd
417l c                   move      '#PROG   '    $cprg
417l c                   z-add     tqyrc1        $cqty1
417l c                   move      *zeros        $cqty2
417l c                   move      *zeros        $cqty3
417l c                   exsr      zzcvqy
417l c                   movel     $cqstr        woqrc8
417l C*
417l c                   endsl
417l C*
417l c     endfl8        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
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
     C*  Define full key for PODTL3 file.
     C*
     c     detlky        klist
     c                   kfld                    pdwhse
     c                   kfld                    pdpo
     c                   kfld                    pdseq
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
     C*
     C*     USERCODE
     C*
     c     uskey         klist
     c                   kfld                    #user
     C*
     C*  Define unique file key.
     C*
     c     filuky        klist
     c                   kfld                    $kwhse
     c                   kfld                    $kpo
     c                   kfld                    pditem
     C*
     C*  Define full key for main file.
     C*
     c     fileky        klist
     c                   kfld                    $kwhse
     c                   kfld                    $kpo
     c                   kfld                    pditem
     C*
     c     filky2        klist
     c                   kfld                    $kwhse
     c                   kfld                    $kpo
     c                   kfld                    pdvitm
     C*
     c     filky3        klist
     c                   kfld                    $kwhse
     c                   kfld                    $kspo
     c                   kfld                    pdpo
     c                   kfld                    pditem
     C*
     c     filky4        klist
     c                   kfld                    $kwhse
     c                   kfld                    $kspo
     c                   kfld                    pdpo
     c                   kfld                    pdvitm
     C*
     C*  Define partial key for main file (if needed).
     C*
     c     partky        klist
     c                   kfld                    $kwhse
     c                   kfld                    $kpo
     C*
     C*  Define partial key for Super P/O file (if needed).
     C*
     c     prtky2        klist
     c                   kfld                    $kwhse
     c                   kfld                    $kspo
     C*
     c     prtky3        klist
     c                   kfld                    $kwhse
     c                   kfld                    $kspo
     c                   kfld                    pditem
     C*
     c     prtky4        klist
     c                   kfld                    $kwhse
     c                   kfld                    $kspo
     c                   kfld                    pdvitm
     C*
     C*  Define key for PIRITEM file.
     C*
     c     itkey         klist
     c                   kfld                    $kwhse
     c                   kfld                    pditem
     C*
417A C*  Define key for PIRITEM file.
417A C*
417A c     i6key         klist
417A c                   kfld                    $kwhse
417A c                   kfld                    w6val1
     C*
     C*  Define key for PODTL file.
     C*
     c     pdkey         klist
     c                   kfld                    pdwhse
     c                   kfld                    pdpo
     c                   kfld                    pdseq
     c                   kfld                    pditem
     C*
     C*  Define key for POHDR file.
     C*
     c     phkey         klist
     c                   kfld                    pdwhse
     c                   kfld                    pdpo
     c     phky2         klist
     c                   kfld                    pdwhse
     c                   kfld                    svpo
     C*
     c     itkey2        klist
     c                   kfld                    $kwhse
     c                   kfld                    $pitem
     C*
     c     slkey3        klist
     c                   kfld                    $kwhse
     c                   kfld                    bsitem
     c                   kfld                    bsstat
     c                   kfld                    bspick
     C*
     C*  Define key for OPTIOND.
     C*
     c     *like         define    opdcod        kycode
     c     opkey2        klist
     c                   kfld                    kycode
     c                   kfld                    $pwhse
     c                   kfld                    itwhdp
     c                   move      '*PICK   '    kycode
     C*
     C*
     C*  Define key for UPC file.
     C*
417bAc     *like         define    upupc         w1upc
     c     upckey        klist
     c                   kfld                    $kwhse
     c                   kfld                    w1upc
     C*
417c C*  Define key for ITMEXCP2 file
     C*
417cAc     *like         define    exitem        kyitem
417cAc     *like         define    extask        kytask
417cAc     *like         define    exerid        kyerid
417cAc     *like         define    exesta        kyesta
417c c     ix2key        klist
417c c                   kfld                    $kwhse
417c c                   kfld                    kyitem
417c c                   kfld                    kytask
417c c                   kfld                    kyerid
417c c                   kfld                    kyesta
     C*
     C*  Define key for PODTL1 file.
     C*
     c     podky1        klist
     c                   kfld                    $kwhse
     c                   kfld                    $kpo
     c                   kfld                    woitm#
     C*
     C*     OPTIONS
     C*
     c     opkey         klist
     c                   kfld                    $kwhse
     c                   kfld                    ocode
     C*
     C*  Define partial key for item tie/high definition file.
     C*
     c     partk2        klist
     c                   kfld                    $kwhse
     c                   kfld                    pditem
     C*
     C*  ITEMLNK file.
     C*
     c     ilkey         klist
     c                   kfld                    $kwhse
     c                   kfld                    pditem
     C*
 16fAc     ddkeyp        klist
416fAc                   kfld                    $kwhse
416fAc                   kfld                    itwhdp
     C*
     C*  Setup option and command display lines.
     C*
     c                   z-add     1             viewo             1 0
     c                   z-add     2             maxvwo            1 0
PCK Ac                   select
PCK Ac     client        wheneq    packers
PCK Ac                   move      optlnp(1)     optln1
PCK Ac                   move      optlnp(2)     optln2
PCK Ac                   other
     c                   move      optln(1)      optln1
     c                   move      optln(2)      optln2
PCK Ac                   endsl
500cAc     $cmd          ifeq      '*SPRECV'
500cAc                   move      optlns(1)     optln1
500cAc                   endif
     c                   select
     c     $spo          wheneq    '*NO '
     c                   move      cmdln(1)      cmdln1
     c     $spo          wheneq    '*YES'
     c                   move      cmdln(3)      cmdln1
     c                   endsl
     c                   move      '*POITEM '    view              8
     C*
     c                   move      *off          forevr            1
     c                   move      #prog         $pprg
     c                   move      #prog         $lprg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Extra program initialization. Called from main line.
     C*
     c     zzinz2        begsr
     C*
     C*   Initialize working variables.
     C*
     c     *like         define    pdpo          savpo
     c     *like         define    pdpo          svpo
     c     *like         define    pdpo          svp2po
     c     *like         define    pditem        svp2vl
     c                   move      *blanks       savpo
     c                   move      *zeros        ttlrcd           11 0
     c                   move      *zeros        nrslct            3 0
     c                   move      *zeros        n                 3 0
     c                   move      *zeros        k                 3 0
     c                   move      *zeros        tqyor1            7 0
     c                   move      *zeros        tqyrc1            7 0
     c                   z-add     1             k
     c                   move      *zeros        recno4            5 0
     c                   move      *off          optslt            1
     c                   move      *off          open1             1
     c                   move      *off          open2             1
     c                   move      *off          first             1
416FAc                   move      *blanks       svmput            1
500eAc                   move      *off          noxflg            1
     C*
     C*   Get warehouse description.
     C*
     c     $kwhse        chain     warehs                             79
     c     *in79         ifeq      *on
     c                   move      *blanks       whdesc
     c                   end
417a C*
417a C*  Convert today's date into century format.
417a C*
417a c                   move      '*CURCMD '    $cvcmd
417a c                   call      @cvtdt
417a c                   parm                    $cvtdt
417a c                   z-add     $cvd8o        today             8 0
     C*
     C*   Load P/O for display.
     C*
     c                   move      *blanks       ovrtyp            8
     c                   select
     c     $spo          wheneq    '*YES'
     c                   move      $kspo         wopo
     C*
     C*    Process file override for OPNQRYF
     c                   move      '*POITEM '    ovrtyp
     c                   exsr      zzovr
     C*
     C*    Process OPNQRYF.
     c                   exsr      zzqry
     c                   exsr      zzopn
     C*
     c                   other
     c                   move      $kpo          wopo
     c                   endsl
     C*
     c                   exsr      zzxopt
     c                   exsr      zztrcv
     c                   exsr      clrsch
     c                   exsr      scr01i
     C*
     C*    Get User's employee number to be written to PORCV file
     C*    if any records are flagged as touched.
     C*
     c                   movel     #user         $code            10
     c                   z-add     *zeros        $whse             3 0
     c                   z-add     *zeros        $emp#             5 0
     c                   movel     *blanks       $fnam            15
     c                   movel     *blanks       $init             1
     c                   movel     *blanks       $lnam            20
     c                   movel     *blanks       $whdp             5
     c                   movel     *blanks       $styp             1
     c                   movel     *blanks       $shft             6
     c                   movel     *blanks       $crew             6
     c                   movel     *blanks       $nhrs            31
     c                   movel     *blanks       $rtn              8
     c                   call      'GETUSER'
     c                   parm                    $code
     c                   parm                    $whse
     c                   parm                    $emp#
     c                   parm                    $fnam
     c                   parm                    $init
     c                   parm                    $lnam
     c                   parm                    $whdp
     c                   parm                    $styp
     c                   parm                    $shft
     c                   parm                    $crew
     c                   parm                    $nhrs
     c                   parm                    $rtn
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCVQY   Convert quantity to string or string to quantity.
     C*
     c     zzcvqy        begsr
     c                   call      'CVTQTY'
     c                   parm                    $ccmd             8
     c                   parm                    $cprg            10
     c                   parm                    $cqty1            7 0
     c                   parm                    $cqty2            7 0
     c                   parm                    $cqty3            7 0
     c                   parm                    $cum1             2
     c                   parm                    $cum2             2
     c                   parm                    $cum3             2
     c                   parm                    $cqstr           10
     c                   parm                    $custr           17
     c                   parm                    $crtn             8
     c                   parm                    $cerm
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYF   Create key for file being used
     C*
     c     zzkeyf        begsr
     c                   move      dsfkey        $pofky
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYU   Create unique key for file
     C*             (to be used in delete and change programs)
     C*
     c     zzkeyu        begsr
     c                   move      dsukey        $pouky
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZOPT    Process non-standard options.
     C*              Note: Error handling is done in routine OPTNS2.
     C*
     c     zzopt         begsr
     C*
     C*   Work with tie/high
     C*
     c     wkoopt        ifeq      ' 8'
     c                   z-add     pdwhse        $swhse            3 0
     c                   call      'IT141'
     c                   parm                    $swhse
     c                   parm                    $pitem
     c                   endif
     C*
     C*   Transactions.
     C*
     c     wkoopt        ifeq      ' 9'
     c                   exsr      zzputo
     c                   move      opmput        $lmput            1
     c                   move      $puky         $luky
     c                   move      *blanks       $lrtn
     c                   call      'PO140'
     c                   parm                    $luky
     c                   parm                    $lrtn
     c                   parm                    $lmput
     c                   exsr      zztrcv
     c                   endif
PCK AC*
PCK AC*   UCI Weight listing
PCK AC*
PCK Ac     wkoopt        ifeq      '10'
PCK Ac                   z-add     $kwhse        $lwhse
PCK Ac                   move      $kpo          $lpo
PCK Ac                   call      @lstpg
PCK Ac                   parm                    $lparm
PCK Ac                   endif
     C*
     C*   Receive item
     C*
     c     wkoopt        ifeq      ' 1'
     c                   exsr      zzchek
     c     error         cabeq     *on           endopt
     C*
     c                   select
     C*    No positioning used. Check if item/Mfr# on multiple p/o's.
     C*    If found on multiple p/o's, display pop-up window.
     C*    Note: This is ONLY for Super P/O's.
     c     svp2po        wheneq    *blanks
     c     svp2vl        andeq     *blanks
     c     $spo          andeq     '*YES'
     C*
     C*    Position to used, but different P/O selected.
     c     svp2po        orgt      *blanks
     c     svp2po        andne     $ppo
     C*
     C*    Position to used, but different Item selected.
     c     svp2vl        orgt      *blanks
     c     svp2vl        andne     $pitem
     C*
     C*    Super P/O being processed.
     c                   move      $pitem        ptinp1
     c                   move      $pitem        pditem
     c                   move      '*SLCTITM'    ovrtyp
     C*
     c                   exsr      zzwdw
     c                   move      *blanks       ptinp1
     c                   move      *blanks       w1mfr
     c                   select
     C*    New P/O selected. Go to Receiving.
     c     repos         wheneq    *on
     c                   move      wopo4         $ppo
     c                   z-add     hseq          $pseq
     c                   move      hitem         $pitem
     c                   move      hvitm         $pvitm
     c                   exsr      zzrcv
     c                   move      *blanks       svp2po
     c                   move      *blanks       svp2vl
     c                   move      *off          repos
     c                   endsl
     C*
     C*    User used Position to and has selected same item.
     c     svp2po        wheneq    $ppo
     c     svp2vl        andeq     $pitem
     C*
     C*    User processing Single P/O.
     c     $spo          oreq      '*NO '
     C*
     c                   move      *blanks       svp2po
     c                   move      *blanks       svp2vl
     C*
     c                   exsr      zzrcv
     c                   endsl
     c                   endif
     C*
     C*   Quick Receive item
     C*
     c     wkoopt        ifeq      ' 7'
     c                   exsr      zzchek
     c     error         cabeq     *on           endopt
     C*
     c                   select
     C*    No positioning used. Check if item/Mfr# on multiple p/o's.
     C*    If found on multiple p/o's, display pop-up window.
     C*    Note: This is ONLY for Super P/O's.
     c     svp2po        wheneq    *blanks
     c     svp2vl        andeq     *blanks
     c     $spo          andeq     '*YES'
     C*
     C*    Position to used, but different P/O selected.
     c     svp2po        orgt      *blanks
     c     svp2po        andne     $ppo
     C*
     C*    Position to used, but different Item selected.
     c     svp2vl        orgt      *blanks
     c     svp2vl        andne     $pitem
     C*
     C*    Super P/O being processed.
     c                   select
     c     view          wheneq    '*POITEM '
     c     view          oreq      '*POMFR  '
     c                   move      $pitem        ptinp1
     c                   move      $pitem        pditem
     c                   move      '*SLCTITM'    ovrtyp
     c                   endsl
     c                   exsr      zzwdw
     c                   move      *blanks       ptinp1
     c                   move      *blanks       w1mfr
     c                   select
     C*    New P/O selected. Go to Receiving.
     c     repos         wheneq    *on
     c                   move      wopo4         $ppo
     c                   z-add     hseq          $pseq
     c                   move      hitem         $pitem
     c                   move      hvitm         $pvitm
     c                   exsr      zzrcv
     c                   move      *blanks       svp2po
     c                   move      *blanks       svp2vl
     c                   move      *off          repos
     c                   endsl
     C*
     C*    User used Position to and has selected same item.
     c     svp2po        wheneq    $ppo
     c     svp2vl        andeq     $pitem
     C*
     C*    User processing Single P/O.
     c     $spo          oreq      '*NO '
     C*
     c                   move      *blanks       svp2po
     c                   move      *blanks       svp2vl
     C*
     c                   exsr      zzrcv
     c                   endsl
     c                   endif
     C*
     C*   Enter HACCP information.
     C*
     c     wkoopt        ifeq      '11'
     c                   move      '*ITEM   '    $pcmd
     c                   call      'PO170'
     c                   parm                    $parms
500gAc     $prtn         ifeq      '*PGMQ   '
500gAc                   move      *on           error
500gAc                   move      $pmsg         #msgk
500gAc                   exsr      zmqmsg
500gAc                   endif
     c                   endif
     C*
     C*   Work with slots
     C*
     c     wkoopt        ifeq      '12'
     c                   z-add     $kwhse        $lwhse
     c                   move      pditem        $litm
     c                   call      'IT130'
     c                   parm                    $luky
     c                   parm                    $lrtn
     c                   endif
     C*
     C*   Display Directed Putaway Receiving log.
     C*
     c     wkoopt        ifeq      '99'
     c                   z-add     $kwhse        $lwhse
     c                   move      $kpo          $lpo
     c                   move      pditem        $litem
     c                   call      'PO135'
     c                   parm                    $lparm
     c                   parm                    $lrtn
     c                   endif
     C*
     C*   Display PORCV entries.
     C*
     c     wkoopt        ifeq      '13'
     c                   move      $puky         $luky
     c                   move      *blanks       $lrtn
     c                   call      'PO138'
     c                   parm                    $luky
     c                   parm                    $lrtn
     c                   endif
417 AC*
417 AC*   Maintain Receiving Exceptions.
417 AC*
417 Ac     wkoopt        ifeq      '14'
417 Ac                   move      '*CHANGE '    $lcmd
417 Ac                   move      $puky         $luky
417 Ac                   move      *blanks       $lrtn
417 Ac                   call      'PO240'
417 Ac                   parm                    $lparm
417 Ac                   parm                    $lrtn
417 Ac                   endif
     C*
     C*     Mark as touched/checked
     C*
     c     wkoopt        ifeq      ' X'
     C*
     C*    Once answered yes process others in subfile without
     C*    promptiong each time...
     C*
     c     woyes         ifeq      'N'
     c                   exfmt     verify
     c                   endif
     c     woyes         ifeq      'Y'
     C**
     C**  Get key to
     C*   Read PORCV.  If not found then add...
     c                   move      $puky         dsukey
     c     detlky        setll     porcv
     c     detlky        reade     porcv                                  55
     c     *in55         ifeq      *on
     c                   z-add     pdwhse        porwhs
     c                   movel     pdpo          porpo
     c                   z-add     pdseq         porseq
     c     #jobdt        mult      10000.01      wrkdte            6 0
     c     20000000      add       wrkdte        pordte
     c                   z-add     #jobtm        portim
     c                   movel     #user         porusr
     c                   z-add     $emp#         poremp
     c                   z-add     0             portrn
416eDC**                   Z-ADD0         PORLIC
416e c                   move      *blanks       porlic
     c                   z-add     0             porlbl
     c                   movel     'X'           poract
416eAc                   z-add     0             poredt
416eAc                   z-add     0             poreti
510aDc*                  write     porrec
416bAc                   else
416bAC*    Release lock if record found.
510aDc*                  unlock    porcv
     c                   endif
     c                   endif
     c                   endif
     C*
     c     endopt        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZOPN    Process file OPEN.
     C*
     c     zzopn         begsr
     C*
     C*   Process file Open for P/O by item view.
     c                   select
     c     ovrtyp        wheneq    '*POITEM '
     C*
     c                   open      po120a
     c                   move      *on           open1
     C*
     C*   Process file Open for P/O by Mfr view.
     c     ovrtyp        wheneq    '*POMFR  '
     C*
     c                   open      po120b
     c                   move      *on           open1
     C*
     C*   Process file Open for Position To P/O by item view.
     c     ovrtyp        wheneq    '*POS2ITM'
     c     ovrtyp        oreq      '*SLCTITM'
     C*
     c                   open      po120c
     c                   move      *on           open2
     C*
     C*   Process file Open for Position To P/O by Mfr view.
     c     ovrtyp        wheneq    '*POS2MFR'
     c     ovrtyp        oreq      '*SLCTMFR'
     C*
     c                   open      po120d
     c                   move      *on           open2
     C*
     c                   endsl
     C*
     c     endopn        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZOVR    Process file overrides.
     C*
     c     zzovr         begsr
     C*
     C*   Process file override for P/O by item view.
     c                   select
     c     ovrtyp        wheneq    '*POITEM '
     C*
     C*      If query file already open then close it.
     C*
     c                   movel(p)  cls1(1)       qcmd
     c                   call      'QCMDEXC'                            78
     c                   parm                    qcmd            256
     c                   parm      80            qlen             15 5
     C*
     c     open1         ifeq      *on
     c                   close     po120a                               78
     c                   close     po120b                               78
     c                   endif
     C*
     C*      Override database file.
     C*
     C*          OVRDBF FILE(PO120A) TOFILE(POSPO) SHARE(*YES)
     C*
     c                   movel(p)  ovr(1)        qcmd
     c                   call      'QCMDEXC'
     c                   parm                    qcmd            256
     c                   parm      80            qlen             15 5
     C*
     C*   Process file override for P/O by Mfr view.
     c     ovrtyp        wheneq    '*POMFR  '
     C*
     C*      If query file already open then close it.
     C*
     c                   movel(p)  cls1(1)       qcmd
     c                   call      'QCMDEXC'                            78
     c                   parm                    qcmd            256
     c                   parm      80            qlen             15 5
     C*
     c     open1         ifeq      *on
     c                   close     po120a                               78
     c                   close     po120b                               78
     c                   endif
     C*
     C*      Override database file.
     C*
     C*          OVRDBF FILE(PO120B) TOFILE(POSPO) SHARE(*YES)
     C*
     c                   movel(p)  ovr(2)        qcmd
     c                   call      'QCMDEXC'
     c                   parm                    qcmd
     c                   parm      80            qlen
     C*
     C*   Process file override for Position To P/O by item view.
     c     ovrtyp        wheneq    '*POS2ITM'
     c     ovrtyp        oreq      '*SLCTITM'
     C*
     C*      If query file already open then close it.
     C*
     c                   movel(p)  cls1(2)       qcmd
     c                   call      'QCMDEXC'                            78
     c                   parm                    qcmd            256
     c                   parm      80            qlen             15 5
     C*
     c     open2         ifeq      *on
     c                   close     po120c                               78
     c                   close     po120d                               78
     c                   endif
     C*
     C*      Override database file.
     C*          OVRDBF FILE(PO120C) TOFILE(POSPO2) SHARE(*YES)
     C*
     c                   movel(p)  ovr(3)        qcmd
     c                   call      'QCMDEXC'
     c                   parm                    qcmd
     c                   parm      80            qlen
     C*
     C*   Process file override for Position To P/O by Mfr view.
     c     ovrtyp        wheneq    '*POS2MFR'
     c     ovrtyp        oreq      '*SLCTMFR'
     C*
     C*      If query file already open then close it.
     C*
     c                   movel(p)  cls1(2)       qcmd
     c                   call      'QCMDEXC'                            78
     c                   parm                    qcmd            256
     c                   parm      80            qlen             15 5
     C*
     c     open2         ifeq      *on
     c                   close     po120c                               78
     c                   close     po120d                               78
     c                   endif
     C*
     C*      Override database file.
     C*
     C*          OVRDBF FILE(PO120D) TOFILE(POSPO2) SHARE(*YES)
     C*
     c                   movel(p)  ovr(4)        qcmd
     c                   call      'QCMDEXC'
     c                   parm                    qcmd
     c                   parm      80            qlen
     C*
     c                   endsl
     C*
     c     endovr        endsr
     C*  --------------------------------------------------------------
     C*
     C*  ZZPOS    Position to a different record.
     C*
     c     zzpos         begsr
     C*
     C*  See if user is trying to position to item or Mfr#
     c                   select
     C*  Position to Item with a Single P/O.
     c     ptinp1        whenne    *blanks
     c     view          andeq     '*POITEM '
     c     $spo          andeq     '*NO '
     c                   z-add     *loval        pdseq
     c                   move      ptinp1        pditem
     c                   move      *blanks       ptinp1
     c                   move      *on           repos
     C*
     C*  Position to mfr# with a Single P/O.
     c     w1mfr         whenne    *blanks
     c     view          andeq     '*POMFR  '
     c     $spo          andeq     '*NO '
     c                   move      w1mfr         pdvitm
     c                   move      *blanks       w1mfr
     c                   move      *on           repos
     C*
     C*    With a Super P/O.
     C*
     C*    Position to Item - Display Pop-up Window.
     c     $spo          wheneq    '*YES'
     c     view          andeq     '*POITEM '
     c     ptinp1        andne     *blanks
     c     ptinp2        andeq     *blanks
     c                   move      ptinp1        pditem
     c                   move      '*POS2ITM'    ovrtyp
     c                   exsr      zzwdw
     c                   move      *blanks       ptinp1
     C*
     C*    Position to Mfr# - Display Pop-up Window.
     c     $spo          wheneq    '*YES'
     c     view          andeq     '*POMFR  '
     c     w1mfr         andne     *blanks
     c     ptinp2        andeq     *blanks
     c                   move      w1mfr         pdvitm
     c                   move      '*POS2MFR'    ovrtyp
     c                   exsr      zzwdw
     c                   move      *blanks       w1mfr
     C*
     C*    Position to P/O and/or Item - No Window.
     c     $spo          wheneq    '*YES'
     c     view          andeq     '*POITEM '
     c     ptinp1        andne     *blanks
     c     ptinp2        andne     *blanks
     C*
     c     $spo          oreq      '*YES'
     c     view          andeq     '*POITEM '
     c     ptinp1        andeq     *blanks
     c     ptinp2        andne     *blanks
     c                   z-add     *loval        pdseq
     c                   move      ptinp1        pditem
     c                   move      *blanks       ptinp1
     c                   move      ptinp2        pdpo
     c                   move      *blanks       ptinp2
     c                   move      *on           repos
     C*
     C*    Position to Mfr# with a Super P/O - No Window.
     c     $spo          wheneq    '*YES'
     c     view          andeq     '*POMFR  '
     c     w1mfr         andne     *blanks
     c     ptinp2        andne     *blanks
     C*
     c     $spo          oreq      '*YES'
     c     view          andeq     '*POMFR  '
     c     ptinp1        andeq     *blanks
     c     ptinp2        andne     *blanks
     c                   move      w1mfr         pdvitm
     c                   move      *blanks       w1mfr
     c                   move      ptinp2        pdpo
     c                   move      *blanks       ptinp2
     c                   move      *on           repos
     C*
     c                   endsl
     c     endzps        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS2   Position to record
     C*
     c     zzpos2        begsr
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C*R         $POCMD    IFEQ '*TOP'
     C*R         *LOVAL    SETLLRECORD
     C*R                   ELSE
     C*R         $POCMD    IFEQ '*BOTTOM'
     C*R         *HIVAL    SETLLRECORD
     C*R                   END
     C*R                   END
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     c                   select
     C*
     C*    Single P/O in Item sequence.
     c     view          wheneq    '*POITEM '
     c     $spo          andeq     '*NO '
     C*
     c     $pocmd        ifeq      '*TOP'
     c     partky        setll     record
     c                   else
     c     $pocmd        ifeq      '*BOTTOM'
     c     partky        setgt     record
     c                   endif
     c                   endif
     C*
     C*    Single P/O in Mfr. sequence.
     c     view          wheneq    '*POMFR  '
     c     $spo          andeq     '*NO '
     C*
     c     $pocmd        ifeq      '*TOP'
     c     partky        setll     record2
     c                   else
     c     $pocmd        ifeq      '*BOTTOM'
     c     partky        setgt     record2
     c                   endif
     c                   endif
     C*
     C*    Super P/O in Item sequence.
     c     view          wheneq    '*POITEM '
     c     $spo          andeq     '*YES'
     C*
     c     $pocmd        ifeq      '*TOP'
     c     prtky2        setll     oqreca
     c                   else
     c     $pocmd        ifeq      '*BOTTOM'
     c     prtky2        setgt     oqreca
     c                   endif
     c                   endif
     C*
     C*    Super P/O in Mfr. sequence.
     c     view          wheneq    '*POMFR  '
     c     $spo          andeq     '*YES'
     C*
     c     $pocmd        ifeq      '*TOP'
     c     prtky2        setll     oqrecb
     c                   else
     c     $pocmd        ifeq      '*BOTTOM'
     c     prtky2        setgt     oqrecb
     c                   endif
     c                   endif
     c                   endsl
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZPUTO   Get Put away option.
     C*             Directed or Manual put away
     C*
     c     zzputo        begsr
     C*
     c     itkey2        chain     piritem                            79
     c     *in79         ifeq      *off
     c                   move      '*PICK   '    kycode
     c     opkey2        chain     optiond                            79
     c     *in79         ifeq      *on
     c                   move      'N'           opmput
     c                   endif
     c                   endif
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZQRY    Process OPNQRYF.
     C*
     c     zzqry         begsr
     C*
     C*    Run OPNQRYF to select records for Super P/O by P/O. by Item.
     c                   select
     c     ovrtyp        wheneq    '*POITEM '
     C*
     C*    Load QRYSLT selection values.
     c                   movea     qry1(2)       a80
     c                   movea     $whsea        a80(10)
     c                   movea     $kspo         a80(28)
     c                   movea     a80           qry1(2)
     C*
     C*    Build command string for query.
     c                   movel(p)  qry1(1)       qcmd
     c     qcmd          cat       qry1(2):0     qcmd
     c     qcmd          cat       qry1(3):1     qcmd
     c     qcmd          cat       qry1(4):1     qcmd
     c     qcmd          cat       qry1(5):1     qcmd
     C*
     c     ovrtyp        wheneq    '*POMFR  '
     C*
     C*    Load QRYSLT selection values.
     c                   movea     qry2(2)       a80
     c                   movea     $whsea        a80(10)
     c                   movea     $kspo         a80(28)
     c                   movea     a80           qry2(2)
     C*
     C*    Build command string for query.
     c                   movel(p)  qry2(1)       qcmd
     c     qcmd          cat       qry2(2):0     qcmd
     c     qcmd          cat       qry2(3):1     qcmd
     c     qcmd          cat       qry2(4):1     qcmd
     c     qcmd          cat       qry2(5):1     qcmd
     C*
     C*    Run OPNQRYF to Position to Item(s) on Super P/O.
     c     ovrtyp        wheneq    '*POS2ITM'
     C*
     C*    Load QRYSLT selection values.
     c                   movea     qry3(6)       a80
     c                   movea     $whsea        a80(10)
     c                   movea     $kspo         a80(28)
     c                   movea     ptinp1        a80(54)
     c                   movea     a80           qry3(2)
     C*
     C*    Build command string for query.
     c                   movel(p)  qry3(1)       qcmd
     c     qcmd          cat       qry3(2):0     qcmd
     c     qcmd          cat       qry3(3):1     qcmd
     c     qcmd          cat       qry3(4):1     qcmd
     c     qcmd          cat       qry3(5):1     qcmd
     C*
     C*    Run OPNQRYF to Position to Mfr#(s) on Super P/O.
     c     ovrtyp        wheneq    '*POS2MFR'
     C*
     C*    Load QRYSLT selection values.
     c                   movea     qry4(6)       a80
     c                   movea     $whsea        a80(10)
     c                   movea     $kspo         a80(28)
     c                   movea     w1mfr         a80(54)
     c                   movea     a80           qry4(2)
     C*
     C*    Build command string for query.
     c                   movel(p)  qry4(1)       qcmd
     c     qcmd          cat       qry4(2):0     qcmd
     c     qcmd          cat       qry4(3):1     qcmd
     c     qcmd          cat       qry4(4):1     qcmd
     c     qcmd          cat       qry4(5):1     qcmd
     C*
     C*    Run OPNQRYF to select item from Super P/O.
     c     ovrtyp        wheneq    '*SLCTITM'
     C*
     C*    Load QRYSLT selection values.
     c                   movea     qry3(2)       a80
     c                   movea     $whsea        a80(10)
     c                   movea     $kspo         a80(28)
     c                   movea     ptinp1        a80(54)
     c                   movea     a80           qry3(2)
     C*
     C*    Build command string for query.
     c                   movel(p)  qry3(1)       qcmd
     c     qcmd          cat       qry3(2):0     qcmd
     c     qcmd          cat       qry3(3):1     qcmd
     c     qcmd          cat       qry3(4):1     qcmd
     c     qcmd          cat       qry3(5):1     qcmd
     C*
     c     ovrtyp        wheneq    '*SLCTMFR'
     C*
     C*    Load QRYSLT selection values.
     c                   movea     qry4(2)       a80
     c                   movea     $whsea        a80(10)
     c                   movea     $kspo         a80(28)
     c                   movea     w1mfr         a80(54)
     c                   movea     a80           qry4(2)
     C*
     C*    Build command string for query.
     c                   movel(p)  qry4(1)       qcmd
     c     qcmd          cat       qry4(2):0     qcmd
     c     qcmd          cat       qry4(3):1     qcmd
     c     qcmd          cat       qry4(4):1     qcmd
     c     qcmd          cat       qry4(5):1     qcmd
     C*
     c                   endsl
     C*
     C*    Process OPNQRYF to select records.
     c                   call      'QCMDEXC'
     c                   parm                    qcmd
     c                   parm      256           qlen
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZRCV    Receive item
     C*
     c     zzrcv         begsr
     C*
     c                   exsr      zzputo
500a c     $cmd          ifeq      '*SPRECV '
500a c                   move      'N'           opmput
500a c                   endif
     C*
     c     wkoopt        ifeq      ' 7'
     c                   move      '*QUICK  '    $lcmd
     c                   else
     c                   move      '*CHANGE '    $lcmd
     c                   endif
     C*
     c                   move      $puky         $luky
417m c                   move      *blanks       $lupc
417m c     upcok         ifeq      *on
     c                   move      w1upc         $lupc
417m c                   else
417m c                   move      *blanks       $lupc
417m c                   endif
     c                   move      *blanks       w1upc
417bAc                   move      *blanks       w1upcd
     c                   z-add     0             $lrsqt
     C*
416fAc                   move      opmput        svmput
416fDC**         OPMPUT    IFEQ 'N'
     C*
416fAC*  Note: For every item check the DEPTDSG file for designation
416fAC*        code.  If the item's desig code is in the file, then
416fAC*        use opposite putaway method than the default for the
416fAC*        department (OPMPUT).
416fAC*
416fAC*        PUTTYP=*ON - Desig code found in file. Use opp. method.
416fAC*        PUTTYP=*OFF - DSesig code not found.
     C*
     C*
416fAc                   exsr      zzdesg
     C*
500a C*   Do not execute for desig code for special receiving.
500a c     $cmd          ifne      '*SPRECV '
416fAc     puttyp        ifeq      *on
416fAc     opmput        andeq     'N'
416fAc                   move      'Y'           svmput
416fAc                   endif
     C*
416fAc     puttyp        ifeq      *on
416fAc     opmput        andeq     'Y'
416fAc                   move      'N'           svmput
416fAc                   endif
500aAc                   endif
     C*
500a c     $cmd          ifeq      '*SPRECV '
500a c                   move      '*CHANGES'    $lcmd
500a c                   endif
416fMc     svmput        ifeq      'N'
     c                   call      'PO132'
     c                   parm                    $lparm
     c                   parm                    $lupc            20
     c                   parm                    $lrsqt            7 0
     C*R                   ADD  $LRSQT    WOSRC
     c                   exsr      zztrcv
     c                   else
     c                   call      'PO232'
     c                   parm                    $lparm
     c                   parm                    $lupc            20
     c                   parm                    $lrsqt            7 0
     C*R                   ADD  $LRSQT    WOSRC
     c                   exsr      zztrcv
     c                   endif
     c     $lrtn         ifeq      '*OK     '
     C*    Recalculate session total received.
     C*
     c                   move      $lmsg         #msgk
     c                   exsr      zmqmsg
     c                   endif
     c     $lrtn         ifeq      '*PGMQ   '
     c                   move      *on           error
     c                   move      $lmsg         #msgk
     c                   exsr      zmqmsg
     c                   endif
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZTRCV   Calculate total qty received for PO
     C*
     c     zztrcv        begsr
     C*
     c                   select
     c     $spo          wheneq    '*NO '
     C*
     c                   move      *zeros        wosrc
     c     partky        setll     record
     c                   move      *off          stop
     c     stop          doueq     *on
     c     partky        reade     record                                 79
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   else
     c                   add       pdqrc1        wosrc
     c                   add       pdqrc2        wosrc
     c                   add       pdqrc3        wosrc
     c                   endif
     c                   enddo
     C*
     C*    Process Super P/O. Accumulate receiving totals.
     c     $spo          wheneq    '*YES'
     c     view          andeq     '*POITEM '
     C*
     c                   move      *zeros        wosrc
     c     prtky2        setll     oqreca
     c                   move      *off          stop
     c     stop          doueq     *on
     c     prtky2        reade     oqreca                                 79
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   else
     c     *in79         ifeq      *off
     c     pdkey         chain     podtl                              77
     c                   endif
     c                   add       pdqrc1        wosrc
     c                   add       pdqrc2        wosrc
     c                   add       pdqrc3        wosrc
     c                   endif
     c                   enddo
     C*
     C*    Process Super P/O. Accumulate receiving totals.
     c     $spo          wheneq    '*YES'
     c     view          andeq     '*POMFR  '
     C*
     c                   move      *zeros        wosrc
     c     prtky2        setll     po120b
     c                   move      *off          stop
     c     stop          doueq     *on
     c     prtky2        reade     po120b                                 79
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   else
     c     *in79         ifeq      *off
     c     pdkey         chain     podtl                              77
     c                   endif
     c                   add       pdqrc1        wosrc
     c                   add       pdqrc2        wosrc
     c                   add       pdqrc3        wosrc
     c                   endif
     c                   enddo
     c                   endsl
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUHDR   Update Super P/O status upon exit.
     C*
     c     zzuhdr        begsr
     C*
     c                   move      *on           full              1
     c                   move      *off          part              1
     c                   move      *off          recv              1
     c     prtky2        setll     pujrec
     c     forevr        doweq     forevr
     c     prtky2        reade     pujrec                                 79
     c                   select
     c     *in79         wheneq    *on
     c                   leave
     C*
     c                   other
     C*
     c     *in79         ifeq      *off
     c     pdqrc1        iflt      pdqor1
     c                   move      *on           part
     c                   move      *off          full
     c                   endif
     C*
     c     pdqrc2        iflt      pdqor2
     c                   move      *on           part
     c                   move      *off          full
     c                   endif
     C*
     c     pdqrc3        iflt      pdqor3
     c                   move      *on           part
     c                   move      *off          full
     c                   endif
     C*
     c     pdqrc1        ifgt      0
     c                   move      *on           recv
     c                   endif
     C*
     c     pdqrc2        ifgt      0
     c                   move      *on           recv
     c                   endif
     C*
     c     pdqrc3        ifgt      0
     c                   move      *on           recv
     c                   endif
     c                   endif
     c                   endsl
     c                   enddo
     C*
     c     recv          ifeq      *off
     c                   move      *off          full
     c                   move      *off          part
     c                   endif
     C*
     C*    Update Super P/O header with new status.
     c     prtky2        chain     pohdr                              79
     c     *in79         ifeq      *off
     c                   select
     C*    Super P/O partially received.
     c     part          wheneq    *on
     c                   move      '1'           phstat
     C*
     C*    Super P/O Fully received.
     c     full          wheneq    *on
     c                   move      '2'           phstat
     C*
     C*    Super P/O still Open.
     c     part          wheneq    *off
     c     full          andeq     *off
     c                   move      '0'           phstat
     c                   endsl
510aDc*                  update    phrec
     c                   endif
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZWDW    Build Pop-Up window for selection of item/Mfr.
     C*
     c     zzwdw         begsr
     C*
     c                   move      *blanks       svp2po
     c                   move      *blanks       svp2vl
     c                   move      *blanks       option
417oAc                   move      *off          *in21
     C*
     c                   select
     c     ovrtyp        wheneq    '*POS2ITM'
     c     ovrtyp        oreq      '*POS2MFR'
     c     ovrtyp        oreq      '*SLCTITM'
     c     ovrtyp        oreq      '*SLCTMFR'
     C*    Condition heading in window.
     c                   move      *on           *in41
     C*    Process file override.
     c                   exsr      zzovr
     C*    Process OPNQRYF.
     c                   exsr      zzqry
     C*    Open file for processing.
     c                   exsr      zzopn
     c                   endsl
     C*
     C********************************************************************
     C*
     c                   move      *zeros        recno4
417b c                   move      *off          repos
     C*
     c                   select
     C*    User chose to Select one Item.
     c     ovrtyp        wheneq    '*SLCTITM'
     C*
     C*    Find out if item on more than one P/O.
     C*    If the item is on only ONE P/O, then position to the P/O
     C*    and item.
     c                   z-add     1             n
     c                   move      *zeros        ttlrcd
     c     prtky3        setll     oqrecc
     c     1             do        2             n
     c     prtky3        reade     oqrecc                                 79
     c                   select
     c     *in79         wheneq    *on
     c     n             andeq     1
     c                   leave
     C*
     C*    Item found on more than one P/O.
     c     n             wheneq    2
     c     *in79         ifeq      *on
     c                   z-add     1             ttlrcd
     c                   else
     c                   z-add     n             ttlrcd
     c                   endif
     c                   endsl
     c                   enddo
     C*
     c                   select
     C*    Item NOT found on any P/O. Don't reposition the screen.
     c     ttlrcd        whenlt    1
     c                   move      *off          repos
     C*
     C*    Item on only ONE P/O. Position to the item.
     c     ttlrcd        wheneq    1
     c                   move      pdpo          wopo4
     c                   z-add     pdseq         hseq
     c                   move      pditem        hitem
     c                   move      pdvitm        hvitm
     c                   move      pdpo          $kpo
     c                   move      pdpo          svp2po
     c                   move      ptinp1        svp2vl
     c                   move      *on           repos
     C*
     C*    Item on more than ONE P/O. Display select window.
     c     ttlrcd        whengt    1
     C*
     c                   movel(p)  titl01        w4titl
     c                   write     window4
     C*    Clear subfile.
     c                   move      *off          *in01
     c                   write     dspsfc4
     c                   move      *on           *in01
     c                   move      'Item:'       slctxt
     c                   move      ptinp1        slcval
     C*
     C*    Fill subfile.
     c     prtky3        setll     oqrecc
     c     forevr        doweq     forevr
     c     prtky3        reade     oqrecc                                 79
     c                   select
     c     *in79         wheneq    *on
     c                   leave
     C*
     c                   other
     c                   exsr      zzfil4
     c                   exsr      sflad4
     c                   endsl
     c                   enddo
     C*
     C*    Now that subfile is loaded, Display it to the user.
     c                   exsr      zzwdw2
     C*
     c                   endsl
     C*
     C********************************************************************
     C*
     C*    User chose to Select one Mfr#.
     c     ovrtyp        wheneq    '*SLCTMFR'
     C*
     C*    Find out if Mfr# on more than one P/O.
     C*    If the Mfr# is on only ONE P/O, then position to the P/O
     C*    and Mfr#.
     c                   z-add     1             n
     c                   move      *zeros        ttlrcd
     c     prtky4        setll     oqrecd
     c     1             do        2             n
     c     prtky4        reade     oqrecd                                 79
     c                   select
     c     *in79         wheneq    *on
     c     n             andeq     1
     c                   leave
     C*
     C*    Item found on more than one P/O.
     c     n             wheneq    2
     c     *in79         ifeq      *on
     c                   z-add     1             ttlrcd
     c                   else
     c                   z-add     n             ttlrcd
     c                   endif
     c                   endsl
     c                   enddo
     C*
     c                   select
     C*    Mfr# NOT found on any P/O. Don't reposition the screen.
     c     ttlrcd        whenlt    1
     c                   move      *off          repos
     C*
     C*    Mfr# on only ONE P/O. Position to the Mfr#.
     c     ttlrcd        wheneq    1
     c                   move      pdpo          wopo4
     c                   z-add     pdseq         hseq
     c                   move      pditem        hitem
     c                   move      pdvitm        hvitm
     c                   move      pdpo          $kpo
     c                   move      pdpo          svp2po
     c                   move      w1mfr         svp2vl
     c                   move      *on           repos
     C*
     C*    Mfr# on more than ONE P/O. Display select window.
     c     ttlrcd        whengt    1
     C*
     c                   movel(p)  titl01        w4titl
     c                   write     window4
     C*    Clear subfile.
     c                   move      *off          *in01
     c                   write     dspsfc4
     c                   move      *on           *in01
     c                   move      'Mfr :'       slctxt
     c                   move      w1mfr         slcval
     C*
     C*    Fill subfile.
     c     prtky4        setll     oqrecd
     c     forevr        doweq     forevr
     c     prtky4        reade     oqrecd                                 79
     c                   select
     c     *in79         wheneq    *on
     c                   leave
     c                   other
     C*
     c                   exsr      zzfil4
     c                   exsr      sflad4
     c                   endsl
     c                   enddo
     C*
     C*    Now that subfile is built, Display it to the user.
     c                   exsr      zzwdw2
     C*
     c                   endsl
     C*
     C********************************************************************
     C*
     C*    User chose to Position to Item.
     c     ovrtyp        wheneq    '*POS2ITM'
416dAC*
416dAC*    Find out if item on more than one P/O.
416dAC*    If the item is on only ONE P/O, then position to the P/O
416dAC*    and item and do not display pop-up window.
416dAc                   z-add     1             n
416dAc                   move      *zeros        ttlrcd
416dAc     prtky3        setll     oqrecc
416dAc     1             do        2             n
416dAc     prtky3        reade     oqrecc                                 79
416dAc                   select
416dAc     *in79         wheneq    *on
416dAc     n             andeq     1
416dAc                   leave
416dAC*
416dAC*    Item found on more than one P/O.
416dAc     n             wheneq    2
416dAc     *in79         ifeq      *on
416dAc                   z-add     1             ttlrcd
416dAc                   else
416dAc                   z-add     n             ttlrcd
416dAc                   endif
416dAc                   endsl
416dAc                   enddo
416dAC*
416dAc                   select
416dAC*    Item on only ONE P/O. Position to the item. No Window.
416dAc     ttlrcd        wheneq    1
416dAc                   move      pdpo          wopo4
416dAc                   z-add     pdseq         hseq
416dAc                   move      pditem        hitem
416dAc                   move      pdvitm        hvitm
416dAc                   move      pdpo          $kpo
416dAc                   move      pdpo          svp2po
416dAc                   move      ptinp1        svp2vl
416dAc                   move      *on           repos
416dAC*
416dAC*    Item on more than ONE P/O or item not found. Display window.
416dAc     ttlrcd        whengt    1
416dAc     ttlrcd        orlt      1
     C*
     c                   movel(p)  titl03        w4titl
     c                   write     window4
     C*    Clear subfile.
     c                   move      *off          *in01
     c                   write     dspsfc5
     c                   move      *on           *in01
     C*    Load headings.
     c                   movel(p)  hdr01         w5txt1
     c                   movel     'Mfr:'        w5txt2
     C*
     C*    Fill subfile.
     c     prtky3        setll     oqrecc
     c     forevr        doweq     forevr
     c     prtky2        reade     oqrecc                                 79
     c                   select
     c     *in79         wheneq    *on
     c                   leave
     C*
     c                   other
     c                   exsr      zzfil5
     c                   exsr      sflad5
     c                   endsl
     c                   enddo
     C*
     C*    Now that subfile is loaded, Display it to the user.
416cAc                   select
416cAC*    When 2 or more records are loaded in subfile. Display window.
416cAc     recno4        whenge    2
     c                   exsr      zzwdw4
416cAC*
416cAC*    Only one item loaded. Position to that p/o/item in main sfl.
416cAc     recno4        wheneq    1
416cAc                   move      pdpo          wopo4
416cAc                   z-add     pdseq         hseq
416cAc                   move      pditem        hitem
416cAc                   move      pdvitm        hvitm
416cAc                   move      pdpo          $kpo
416cAc                   move      pdpo          svp2po
416cAc                   move      ptinp1        svp2vl
416cAc                   move      *on           repos
416cAC*
416cAC*    No items loaded. Send error message.
416cAc     recno4        whenle    0
416cac                   move      'item'        erp2tp
416cAc                   move      $kspo         erspo
416cAc                   move      ptinp1        erp2vl
416cAc                   exsr      zm3236
416cAC*
416cAc                   endsl
416dAC*
416dAc                   endsl
     C*
     C********************************************************************
     C*
     C*    User chose to Position to Mfr#.
     c     ovrtyp        wheneq    '*POS2MFR'
416dAC*
416dAC*    Find out if Mfr# on more than one P/O.
416dAC*    If the Mfr# is on only ONE P/O, then position to the P/O
416dAC*    and Mfr#.
416dAc                   z-add     1             n
416dAc                   move      *zeros        ttlrcd
416dAc     prtky4        setll     oqrecd
416dAc     1             do        2             n
416dAc     prtky4        reade     oqrecd                                 79
416dAc                   select
416dAc     *in79         wheneq    *on
416dAc     n             andeq     1
416dAc                   leave
416dAC*
416dAC*    Item found on more than one P/O.
416dAc     n             wheneq    2
416dAc     *in79         ifeq      *on
416dAc                   z-add     1             ttlrcd
416dAc                   else
416dAc                   z-add     n             ttlrcd
416dAc                   endif
416dAc                   endsl
416dAc                   enddo
416dAC*
416dAc                   select
416dAC*    Mfr# on only ONE P/O. Position to the Mfr#.
416dAc     ttlrcd        wheneq    1
416dAc                   move      pdpo          wopo4
416dAc                   z-add     pdseq         hseq
416dAc                   move      pditem        hitem
416dAc                   move      pdvitm        hvitm
416dAc                   move      pdpo          $kpo
416dAc                   move      pdpo          svp2po
416dAc                   move      w1mfr         svp2vl
416dAc                   move      *on           repos
416dAC*
416dAC*    Mfr# on more than ONE P/O or not found. Display window.
416dAc     ttlrcd        whengt    1
416dAc     ttlrcd        orlt      1
     C*
     c                   movel(p)  titl04        w4titl
     c                   write     window4
     C*    Clear subfile.
     c                   move      *off          *in01
     c                   write     dspsfc5
     c                   move      *on           *in01
     C*    Load headings.
     c                   movel(p)  hdr02         w5txt1
     c                   movel     'Itm:'        w5txt2
     C*
     C*    Fill subfile.
     c     prtky4        setll     oqrecd
     c     forevr        doweq     forevr
     c     prtky2        reade     oqrecd                                 79
     c                   select
     c     *in79         wheneq    *on
     c                   leave
     c                   other
     C*
     c                   exsr      zzfil5
     c                   exsr      sflad5
     c                   endsl
     c                   enddo
     C*
     C*    Now that subfile is built, Display it to the user.
416cAc                   select
416cAC*    When 2 or more records are loaded in subfile. Display window.
416cAc     recno4        whenge    2
     c                   exsr      zzwdw4
416cAC*
416cAC*    Only one item loaded. Position to that p/o/item in main sfl.
416cAc     recno4        wheneq    1
416cAc                   move      pdpo          wopo4
416cAc                   z-add     pdseq         hseq
416cAc                   move      pditem        hitem
416cAc                   move      pdvitm        hvitm
416cAc                   move      pdpo          $kpo
416cAc                   move      pdpo          svp2po
416cAc                   move      ptinp1        svp2vl
416cAc                   move      *on           repos
416cAC*
416cAC*    No items loaded. Send error message.
416cAc     recno4        whenle    0
416cac                   move      'mfg#'        erp2tp
416cAc                   move      $kspo         erspo
416cAc                   move      w1mfr         erp2vl
416cAc                   exsr      zm3236
416cAC*
416cAc                   endsl
416dAC*
416dAc                   endsl
     C*
     C********************************************************************
     C*
     C*    User chose to see sub-total by p/o.
417k C*    Super PO.
     c     ovrtyp        wheneq    '*SUBTOTL'
417kAc     $spo          andeq     '*YES'
     C*
     C*    Condition heading in window.
     c                   move      *off          *in41
     c                   movel(p)  titl02        w4titl
     c                   write     window4
     C*    Clear subfile.
     c                   move      *off          *in01
     c                   write     dspsfc4
     c                   move      *on           *in01
     c                   move      'SPO :'       slctxt
     c                   movel(p)  $kspo         slcval
     c                   move      *blanks       svpo
     c                   move      *zeros        tqyor1
     c                   move      *zeros        tqyrc1
     c                   move      *off          first
     C*    Protect option field - Display only.
     c                   move      *on           *in90
     C*
     C*    Fill subfile.
     c     prtky2        setll     pujrec
     c     forevr        doweq     forevr
     c     prtky2        reade     pujrec                                 79
     c                   select
     c     *in79         wheneq    *on
     C*
     C*    End of p/o detail, convert totals.
     c                   move      *loval        svpo
     c                   exsr      zzfil4
     c                   exsr      sflad4
     c                   leave
     C*
     c                   other
     C*
     c     first         ifeq      *off
     c                   move      *on           first
     c                   move      pdpo          svpo
     c                   endif
     C*
     c                   exsr      zzfil4
     C*
     c                   select
     c     svpo          whenne    pdpo
     C*    Write total record for P/O to subfile.
     c                   exsr      sflad4
     c                   move      pdpo          svpo
     C*    Clear total fields.
     c                   move      *zeros        tqyor1
     c                   move      *zeros        tqyrc1
     C*    Add current record values to total.
     c                   exsr      zzfil4
     c                   endsl
     c                   endsl
     c                   enddo
     C*
     C*    Now that subfile is built, Display it to the user.
     c                   exsr      zzwdw2
     c                   move      *off          *in90
417k C********************************************************************
417k C*
417k C*    User chose to see item subtotal p/o, qty recvd <> ordered.
417k C*    Normal PO.
417k c     ovrtyp        wheneq    '*SUBITTL'
417kAc     $spo          andeq     '*NO'
417k C*
417k C*    Condition heading in window.
417k c                   move      *off          *in41
417k c                   movel(p)  titl02        w4titl
417k c                   write     window4
417k C*    Clear subfile.
417k c                   move      *off          *in01
417k c                   write     dspsfc7
417k c                   move      *on           *in01
417k c                   move      'PO  :'       slctxt
417k c                   movel(p)  $kpo          slcval
417k c                   move      *blanks       svpo
417k c                   move      *zeros        tqyor1
417k c                   move      *zeros        tqyrc1
417k c                   move      *off          first
417k C*    Protect option field - Display only.
417k c                   move      *on           *in90
417k C*
417k C*    Fill subfile.
417k c     partky        setll     record
417k c     forevr        doweq     forevr
417k c     partky        reade     record                                 79
417k c                   select
417k c     *in79         wheneq    *on
417k c                   move      $kpo          svpo
417k c                   leave
417k C*
417k c                   other
417k c     pdqor1        ifeq      pdqrc1
417k c     pdqor2        andeq     pdqrc2
417k c     pdqor3        andeq     pdqrc3
417k c                   iter
417k c                   endif
417k C*
417k c     first         ifeq      *off
417k c                   move      *on           first
417k c                   move      pdpo          svpo
417k c                   endif
417k C*
417k C*    For each line #, convert totals.
417k C*    Clear total fields.
417k c                   move      *zeros        tqyor1
417k c                   move      *zeros        tqyrc1
417k C*
417k C*    Add current record values to total.
417k c                   exsr      zzfil7
417k C*    Write total record for P/O to subfile.
417k c                   exsr      sflad7
417k c                   endsl
417k c                   enddo
417k C*
417k C*    Now that subfile is built, Display it to the user.
417kDC***                  EXSR ZZWDW2
417k c                   exsr      zzwdw8
417k c                   move      *off          *in90
417l C********************************************************************
417l C*
417l C*    User chose to see item subtotal p/o, qty recvd <> ordered.
417l C*    Super PO.
417l c     ovrtyp        wheneq    '*SUBITTL'
417lAc     $spo          andeq     '*YES'
417l C*
417l C*    Condition heading in window.
417l c                   move      *off          *in41
417l c                   movel(p)  titl02        w4titl
417l c                   write     window4
417l C*    Clear subfile.
417l c                   move      *off          *in01
417l c                   write     dspsfc8
417l c                   move      *on           *in01
417l c                   move      'SPO :'       slctxt
417l c                   movel(p)  $kspo         slcval
417l c                   move      *blanks       svpo
417l c                   move      *blanks       svitem           15
417l c                   move      *zeros        tqyor1
417l c                   move      *zeros        tqyrc1
417l c                   move      *off          first
417l C*    Protect option field - Display only.
417l c                   move      *on           *in90
417l C*
417l C*    Fill subfile.
417l c     prtky2        setll     pujrec
417l c     forevr        doweq     forevr
417l c     prtky2        reade     pujrec                                 79
417l c                   select
417l c     *in79         wheneq    *on
417l C*
417l C*    End of p/o detail, convert totals.
417l c                   move      *loval        svpo
417l c                   leave
417l C*
417l c                   other
417k c     pdqor1        ifeq      pdqrc1
417k c     pdqor2        andeq     pdqrc2
417k c     pdqor3        andeq     pdqrc3
417k c                   iter
417k c                   endif
417l C*
417l c     first         ifeq      *off
417l c                   move      *on           first
417l c                   move      pdpo          svpo
417l c                   move      pditem        svitem
417l c                   endif
417l C*
417k C*    For each line #, convert totals.
417k C*    Clear total fields.
417k c                   move      *zeros        tqyor1
417k c                   move      *zeros        tqyrc1
417l C*
417k C*    Add current record values to total.
417l c                   exsr      zzfil8
417l C*****                EXSR ZZFIL4
417k C*    Write total record for item to subfile.
417k c                   exsr      sflad8
417l c                   endsl
417l c                   enddo
417l C*
417l C*    Now that subfile is built, Display it to the user.
417l c                   exsr      zzwdw9
417l c                   move      *off          *in90
417a C********************************************************************
417a C*
417a C*    Multiple Items exist for UPC, select item.
417a c     ovrtyp        wheneq    '*UPCSLCT'
417aAC*
417a C*
417a c                   movel(p)  titl05        w4titl
417a c                   write     window4
417a C*    Clear subfile.
417a c                   move      *off          *in01
417a c                   write     dspsfc6
417a c                   move      *on           *in01
417a C*    Load headings.
417a c                   movel(p)  hdr01         w6txt1
417a c                   movel     'Itm:'        w6txt2
417aAC*    Process for one po
417aAc     $spo          ifeq      '*NO'
417aAc     upckey        setll     upc
417a c     forevr        doweq     forevr
417aAc     upckey        reade     upc                                    79
417aAc     *in79         ifeq      *on
417aAc                   leave
417aAc                   endif
417a C*
417a c                   move      upitem        woitm#           15
417a c     podky1        setll     podtl1                             78
417a c     forevr        doweq     forevr
     c     podky1        reade     podtl1                                 78
     c     *in78         ifeq      *on
417a C*
417a c                   move      *blanks       w6po
417a c                   z-add     0             hseq
417a c                   move      woitm#        pditem
417a c                   move      woitm#        w6val1
417a c                   move      *blanks       w6val2
     c                   leave
     c                   else
417a C*
417a c                   move      pdpo          w6po
417a c                   z-add     pdseq         hseq
417a c                   move      pditem        w6val1
417a c                   move      pdvitm        w6val2
     c                   leave
     c                   endif
     C*
417a c                   enddo
417a c                   exsr      zzfil6
417a c                   exsr      sflad6
417AAc                   enddo
417a C*
417a C*    Now that subfile is built, Display it to the user.
417a c                   exsr      zzwdw6
417AAc                   endif
417a C*
417aAC*    Process for SUPER po
417aAc     $spo          ifeq      '*YES'
417aAc     upckey        setll     upc
417a c     forevr        doweq     forevr
417aAc     upckey        reade     upc                                    79
417aAc     *in79         ifeq      *on
417aAc                   leave
417aAc                   endif
417a c                   move      upitem        woitm#           15
417a c                   move      *off          prtupc            1
417a C*    Get regular PO#
417a c     prtky2        setll     pospo                              77
417a c     forevr        doweq     forevr
     c     prtky2        reade     pospo                                  77
     c     *in77         ifeq      *on
417aAc                   leave
417aAc                   else
417a c                   move      pupo          $kpo
417aAc                   endif
417a C*
417a c     podky1        setll     podtl1                             78
417a c     forevr        doweq     forevr
     c     podky1        reade     podtl1                                 78
     c     *in78         ifeq      *on
417a C*
417a c                   move      *blanks       w6po
417a c                   z-add     0             hseq
417a c                   move      woitm#        pditem
417a c                   move      woitm#        w6val1
417a c                   move      *blanks       w6val2
     c                   leave
     c                   else
417a C*
417a c                   move      pdpo          w6po
417a c                   z-add     pdseq         hseq
417a c                   move      pditem        w6val1
417a c                   move      pdvitm        w6val2
     c                   leave
     c                   endif
     C*
417a c                   enddo
417a c     *in78         ifeq      *off
417a c                   exsr      zzfil6
417a c                   exsr      sflad6
417a c                   move      *on           prtupc
417AAc                   endif
417a c                   enddo
417a c     prtupc        ifeq      *off
417a c                   exsr      zzfil6
417a c                   exsr      sflad6
417a c                   move      *on           prtupc
417AAc                   endif
417AAc                   enddo
417a C*
417a C*    Now that subfile is built, Display it to the user.
417a c                   exsr      zzwdw6
417AAc                   endif
     C*
     c                   endsl
     C********************************************************************
     C*
     c                   endsr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZWDW2   Display Pop-Up window for selection of item/Mfr.
     C*
     c     zzwdw2        begsr
     C*
     c     recno4        ifeq      *zeros
     c                   write     blank4
     c                   move      *on           *in56
     c                   else
     c                   move      *off          *in56
     c                   endif
     C*
     c                   move      *on           *in57
     c     forevr        doweq     forevr
     C*
     C*   Overlay screen with error messages
     c                   exsr      zmdms4
     C*
     c                   exfmt     dspsfc4
     C*
     C*   Initialize error subfile
     c                   exsr      zmcms4
     C*
     c                   select
     C*    F12=Cancel selected.
     c     *inkl         wheneq    *on
     c                   move      *off          *inkl
     c                   leave
     C*
     C*    F5=Refresh selected.
     c     *inke         wheneq    *on
     c                   exsr      clrsch
     c     1             do        05            x
     c     x             chain     dspsfl4                            79
     c     *in79         ifeq      *off
     c                   move      '  '          option
     c                   update    dspsfl4
     c                   endif
     c                   enddo
     C*
     c                   other
     C*
     C*    Process subfile.
     c                   exsr      zzwdw3
     C*
     C*    User selected record from list.
     c     optslt        ifeq      *on
     c     error         andeq     *off
     c                   leave
     c                   endif
     C*
     c                   endsl
     c                   enddo
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZWDW3   Process subfile looking for selection.
     C*
     c     zzwdw3        begsr
     C*
     C*    Read ONLY the changed options.
     c                   move      *off          error
     c                   move      *zeros        nrslct
     c                   move      *off          optslt
     c     forevr        doweq     forevr
     c                   readc     dspsfl4                                79
     c                   select
     c     *in79         wheneq    *on
     c                   leave
     C*
     c                   other
     C*
     C*    Display error if option is not valid.
     c     option        ifne      *blanks
     c                   move      *on           *in21
     c                   update    dspsfl4
     C*
     c                   movea     option        a2
     c     a2(2)         ifeq      ' '
     c                   move      a2(1)         a2(2)
     c                   move      ' '           a2(1)
     c                   movea     a2            option
     c                   endif
     C*
     C*    Look up option in profile - Error if not found.
     c     option        lookup    zopt4                                  50
     c     *in50         ifeq      *off
     c                   move      *on           error
     c                   move      *blanks       errmsg
     c                   exsr      z40108
     c                   endif
     C*
     C*    Count number of entries when Option=1
     c     option        ifeq      ' 1'
     c                   add       1             nrslct
     c                   move      wopo4         pdpo
     c                   move      wopo4         $kpo
     c                   move      wopo4         svp2po
     c                   move      slcval        svp2vl
     C*    If number selected greater than 1, Then display message.
     c                   select
     c     nrslct        wheneq    1
     c                   move      *on           optslt
     c                   move      *on           repos
     c     nrslct        whenge    2
     c                   move      *on           error
     c                   movel(p)  err01         errmsg
     c                   exsr      z40105
     c                   move      *off          optslt
     c                   move      *off          repos
     c                   endsl
     c                   endif
     c                   endif
     C*
     c                   endsl
     c                   enddo
     C*
     c                   endsr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZWDW4   Display Pop-Up window for Position to item/Mfr.
     C*
     c     zzwdw4        begsr
     C*
     c     recno4        ifeq      *zeros
     c                   write     blank5
     c                   move      *on           *in56
     c                   else
     c                   move      *off          *in56
     c                   endif
     C*
     c                   move      *on           *in57
     c     forevr        doweq     forevr
     C*
     C*   Overlay screen with error messages
     c                   exsr      zmdms4
     C*
     c                   exfmt     dspsfc5
     C*
     C*   Initialize error subfile
     c                   exsr      zmcms4
     C*
     c                   select
     C*    F12=Cancel selected.
     c     *inkl         wheneq    *on
     c                   move      *off          *inkl
     c                   leave
     C*
     C*    F5=Refresh selected.
     c     *inke         wheneq    *on
     c                   exsr      clrsch
     c     1             do        05            x
     c     x             chain     dspsfl5                            79
     c     *in79         ifeq      *off
     c                   move      '  '          option
     c                   update    dspsfl5
     c                   endif
     c                   enddo
     C*
     c                   other
     C*
     C*    Process subfile.
     c                   exsr      zzwdw5
     C*
     C*    User selected record from list.
     c     optslt        ifeq      *on
     c     error         andeq     *off
     c                   leave
     c                   endif
     C*
     c                   endsl
     c                   enddo
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZWDW5   Process subfile5 looking for selection.
     C*
     c     zzwdw5        begsr
     C*
     C*    Read ONLY the changed options.
     c                   move      *off          error
     c                   move      *zeros        nrslct
     c                   move      *off          optslt
     c     forevr        doweq     forevr
     c                   readc     dspsfl5                                79
     c                   select
     c     *in79         wheneq    *on
     c                   leave
     C*
     c                   other
     C*
     C*    Display error if option is not valid.
     c     option        ifne      *blanks
     c                   move      *on           *in21
     c                   update    dspsfl5
     C*
     c                   movea     option        a2
     c     a2(2)         ifeq      ' '
     c                   move      a2(1)         a2(2)
     c                   move      ' '           a2(1)
     c                   movea     a2            option
     c                   endif
     C*
     C*    Look up option in profile - Error if not found.
     c     option        lookup    zopt4                                  50
     c     *in50         ifeq      *off
     c                   move      *on           error
     c                   move      *blanks       errmsg
     c                   exsr      z40108
     c                   endif
     C*
     C*    Count number of entries when Option=1
     c     option        ifeq      ' 1'
     c                   add       1             nrslct
     c                   move      w5po          pdpo
     c                   move      w5po          $kpo
     c                   move      w5po          svp2po
     c                   z-add     hseq          pdseq
     c                   select
     c     ovrtyp        wheneq    '*POS2ITM'
     c                   move      w5val1        pditem
     c                   move      w5val1        svp2vl
     c                   move      w5val2        pdvitm
     c     ovrtyp        wheneq    '*POS2MFR'
     c                   move      w5val1        pdvitm
     c                   move      w5val2        pditem
     c                   move      w5val2        svp2vl
     c                   endsl
     C*    If number selected greater than 1, Then display message.
     c                   select
     c     nrslct        wheneq    1
     c                   move      *on           optslt
     c                   move      *on           repos
     c     nrslct        whenge    2
     c                   move      *on           error
     c                   movel(p)  err01         errmsg
     c                   exsr      z40105
     c                   move      *off          optslt
     c                   move      *off          repos
     c                   endsl
     c                   endif
     c                   endif
     C*
     c                   endsl
     c                   enddo
     C*
     c                   endsr
417a C*----------------------------------------------------------------
417a C*
417a C*  ZZWDW6   Display Pop-Up window for UPC multiple items.
417a C*
417a c     zzwdw6        begsr
417a C*
417a c     recno4        ifeq      *zeros
417a c                   write     blank5
417a c                   move      *on           *in56
417a c                   else
417a c                   move      *off          *in56
417a c                   endif
417a C*
417a c                   move      *on           *in57
417a c     forevr        doweq     forevr
417a C***        REFRSH    CABEQ*ON       JMP1
417a C*
417a C*   Overlay screen with error messages
417a c                   exsr      zmdms4
417a C*
417a c                   exfmt     dspsfc6
417a C*
417a C*   Initialize error subfile
417a c                   exsr      zmcms4
417a C*
417a c                   select
417a C*    F12=Cancel selected.
417a c     *inkl         wheneq    *on
417a c                   move      *off          *inkl
417a c                   leave
417a C*
417a C*    F5=Refresh selected.
417a c     *inke         wheneq    *on
417a c     refrsh        oreq      *on
417a c                   move      *off          refrsh
417a c                   exsr      clrsch
417a c     1             do        05            x
417a c     x             chain     dspsfl6                            79
417a c     *in79         ifeq      *off
417a c                   move      '  '          option
417a c                   update    dspsfl6
417a c                   endif
417a c                   enddo
417a C*
417a c                   other
417a C*
417a C*    Process subfile.
417f c                   exsr      zzwdwx
417a c                   exsr      zzwdw7
417a C*
417a C*    User selected record from list.
417a c     optslt        ifeq      *on
417a c     error         andeq     *off
417a c                   leave
417a c                   endif
417a C*
417f C*    User did NOT select record from list.
417f c     optslt        ifeq      *off
417f c     error         andeq     *off
417f c                   leave
417f c                   endif
417f C*
417a c                   endsl
417a c     refrsh        ifeq      *on
417a c                   move      *off          refrsh
417a c                   exsr      clrsch
417a c     1             do        05            x
417a c     x             chain     dspsfl6                            79
417a c     *in79         ifeq      *off
417a c                   move      '  '          option
417a c                   update    dspsfl6
417a c                   endif
417a c                   enddo
417a c                   iter
417a c                   endif
417a c                   enddo
417a C*
417a c                   endsr
     C*----------------------------------------------------------------
417a C*
417a C*  ZZWDW7   Process subfile6 looking for selection 1.
417a C*
417a c     zzwdw7        begsr
417a C*
417a C*    Read ONLY the changed options.
417a c                   move      *off          error
417a c                   move      *zeros        nrslct
417a c                   move      *off          optslt
417a c     forevr        doweq     forevr
417a c                   readc     dspsfl6                                79
417a c                   select
417a c     *in79         wheneq    *on
417a c                   leave
417a C*
417a c                   other
417a C*
417a C*    Display error if option is not valid.
417a c     option        ifne      *blanks
417a c                   move      *on           *in21
417a c                   update    dspsfl6
417a C*
417a c                   movea     option        a2
417a c     a2(2)         ifeq      ' '
417a c                   move      a2(1)         a2(2)
417a c                   move      ' '           a2(1)
417a c                   movea     a2            option
417a c                   endif
417a C*
417a C*    Look up option in profile - Error if not found.
417eDC*R         OPTION    LOKUPZOPT4                    50
417eMc     option        lookup    zopt6                                  50
417a c     *in50         ifeq      *off
417a c                   move      *on           error
417a c                   move      *blanks       errmsg
417a c                   exsr      z40108
417a c                   endif
417a C*
417a C*    Count number of entries when Option=1
417a c     option        ifeq      ' 1'
417a c                   add       1             nrslct
417a c                   move      w6po          pdpo
417g c     w6po          ifne      *blanks
417a c                   move      w6po          $kpo
417g c                   endif
417a c                   move      w6po          svp2po
417a c                   move      w6val1        upitem
417a c                   move      w6val1        pditem
417a c                   z-add     hseq          pdseq
417a c                   move      w6val2        pdvitm
417a C*    If number selected greater than 1, Then display message.
417a c                   select
417a c     nrslct        wheneq    1
417h c                   move      *off          noupc
417a c                   move      *on           optslt
417a c                   move      *on           repos
417a c     nrslct        whenge    2
417a c                   move      *on           error
417a c                   movel(p)  err01         errmsg
417a c                   exsr      z40105
417a c                   move      *off          optslt
417a c                   move      *off          repos
417a c                   endsl
417a c                   endif
417a C*
417a C*
417a c                   endif
417a C*
417a c                   endsl
417a c                   enddo
417a C*
417a c                   endsr
417k C*----------------------------------------------------------------
417k C*
417k C*  ZZWDW8   Display Pop-Up window for PO item subtotal
417k C*
417k c     zzwdw8        begsr
417k C*
417k c     recno4        ifeq      *zeros
417k c                   write     blank4
417k c                   move      *on           *in56
417k c                   else
417k c                   move      *off          *in56
417k c                   endif
417k C*
417k c                   move      *on           *in57
417k c     forevr        doweq     forevr
417k C*
417k C*   Overlay screen with error messages
417k c                   exsr      zmdms4
417k C*
417k c                   exfmt     dspsfc7
417k C*
417k C*   Initialize error subfile
417k c                   exsr      zmcms4
417k C*
417k c                   select
417k C*    F12=Cancel selected.
417k c     *inkl         wheneq    *on
417k c                   move      *off          *inkl
417k c                   leave
417k C*
417k C*    F5=Refresh selected.
417k c     *inke         wheneq    *on
417k c                   exsr      clrsch
417k c     1             do        05            x
417k c     x             chain     dspsfl7                            79
417k c     *in79         ifeq      *off
417k c                   move      '  '          option
417k c                   update    dspsfl7
417k c                   endif
417k c                   enddo
417k C*
417k c                   other
     C*
     C*    Process subfile.
417kdC****                 EXSR ZZWDW3
417kdC*
417kdC*    User selected record from list.
417kdC****       OPTSLT    IFEQ *ON
417kdC****       ERROR     ANDEQ*OFF
417kdC****                 LEAVE
417kdC****                 ENDIF
417k C*
417k c                   endsl
417k c                   enddo
417k C*
417k c                   endsr
417l C*----------------------------------------------------------------
417l C*
417l C*  ZZWDW9   Display Pop-Up window for Super PO item subtotal
417l C*
417l c     zzwdw9        begsr
417l C*
417l c     recno4        ifeq      *zeros
417l c                   write     blank4
417l c                   move      *on           *in56
417l c                   else
417l c                   move      *off          *in56
417l c                   endif
417l C*
417l c                   move      *on           *in57
417l c     forevr        doweq     forevr
417l C*
417l C*   Overlay screen with error messages
417l c                   exsr      zmdms4
417l C*
417l c                   exfmt     dspsfc8
417l C*
417l C*   Initialize error subfile
417l c                   exsr      zmcms4
417l C*
417l c                   select
417l C*    F12=Cancel selected.
417l c     *inkl         wheneq    *on
417l c                   move      *off          *inkl
417l c                   leave
417l C*
417l C*    F5=Refresh selected.
417l c     *inke         wheneq    *on
417l c                   exsr      clrsch
417l c     1             do        05            x
417l c     x             chain     dspsfl8                            79
417l c     *in79         ifeq      *off
417l c                   move      '  '          option
417l c                   update    dspsfl8
417l c                   endif
417l c                   enddo
417l C*
417l c                   other
     C*
     C*    Process subfile.
417ldC****                 EXSR ZZWDW3
417ldC*
417ldC*    User selected record from list.
417ldC****       OPTSLT    IFEQ *ON
417ldC****       ERROR     ANDEQ*OFF
417ldC****                 LEAVE
417ldC****                 ENDIF
417l C*
417l c                   endsl
417l c                   enddo
417l C*
417l c                   endsr
417f C*----------------------------------------------------------------
417f C*
417f C*  ZZWDWX   Process subfile6 looking for selection X
417f C*
417f c     zzwdwx        begsr
417h c                   move      *on           noupc
417f C*
417f C*    Read ONLY the changed options.
417f c                   move      *off          error
417f c                   move      *zeros        nrslct
417f c                   move      *off          optslt
417f c     forevr        doweq     forevr
417f c                   readc     dspsfl6                                79
417f c                   select
417f c     *in79         wheneq    *on
417f c                   leave
417f C*
417f c                   other
417f C*
417f C*    Display error if option is not valid.
417f c     option        ifne      *blanks
417f c                   move      *on           *in21
417f c                   update    dspsfl6
417f C*
417f c                   movea     option        a2
417f c     a2(2)         ifeq      ' '
417f c                   move      a2(1)         a2(2)
417f c                   move      ' '           a2(1)
417f c                   movea     a2            option
417f c                   endif
417f C*
417f C*    Look up option in profile - Error if not found.
417eDC*R         OPTION    LOKUPZOPT4                    50
417fMc     option        lookup    zopt6                                  50
417f c     *in50         ifeq      *off
417f c                   move      *on           error
417f c                   move      *blanks       errmsg
417f c                   exsr      z40108
417f c                   endif
417f C*
417f C*    Process exceptions Option=X
417f c     option        ifeq      ' X'
417fAc                   move      w6val1        kyitem
417fac                   movel(p)  'RCV'         kytask
417fAc                   movel(p)  'RDUPUPC'     kyerid
417fAc                   move      '1 '          kyesta
417f c     ix2key        setll     itmexcp2
417f c     forevr        doweq     forevr
417f c     ix2key        reade     itmexcp2                               79
     C*
417f c     *in79         ifeq      *on
417f c                   move      *on           doex              1
417f c                   leave
417f c                   else
417f c                   move      *off          doex
417f c                   leave
417f c                   endif
     C*
417f c                   enddo
     C*
417f c     doex          ifeq      *on
417fAc                   move      w6val1        pditem
417f c     itkey         chain     piritem                            79
417f c     *in79         ifeq      *off
417fAc                   move      itwhdp        exwhdp
417fAc                   move      itstyp        exstyp
417fAc                   else
417fAc                   move      *blanks       exwhdp
417fAc                   move      *blanks       exstyp
417fAc                   endif
417f C**                   ADD  1         NRSLCT
417fAc                   z-add     $kwhse        exwhse
417fAc                   move      w6val1        exitem
417fAc                   move      *blanks       exfdis
417fAc                   move      *blanks       extdis
417fAc                   z-add     today         exgdte
417fAc                   time                    exgtim
417fMc                   z-add     0             exqty
417fac                   movel(p)  'RCV'         extask
417fAc                   move      #user         exgby
417fAc                   movel(p)  'RDUPUPC'     exerid
417fAc                   move      '1 '          exesta
417fAc                   move      w1upc         dsupc
417fAc                   move      dsfdis        exfdis
417fAc                   move      dstdis        extdis
510aDc*                  write     exrec
417f c                   endif
417g C**                   MOVE *ON       REFRSH
417g C**                   MOVE *OFF      *IN21
417g C**                   LEAVE
417f c                   endif
417f C*
417f c                   endif
417f C*
417f c                   endsl
417f c                   enddo
417f C*
417f c                   endsr
417f C*----------------------------------------------------------------
     C*
     C*  ZZXOPT   Get use extended description option
     C*
     c     zzxopt        begsr
     C*
     C*   Get extended description option.
     c                   z-add     10            prcrec            2 0
     c                   move      *off          uxflag            1
     c                   move      '*ITEMMNT'    ocode             8
     C*
     c     opkey         chain     options                            79
     c     *in79         ifeq      *off
     c     opxdsc        ifeq      'Y'
     c                   move      *on           uxflag
     c                   z-add     5             prcrec
     c                   endif
     c                   endif
     C*
     C*   If processing a Super P/O, Force display to be displayed
     C*   in 2-line mode.
     c     $spo          ifeq      '*YES'
     c     uxflag        andeq     '0'
     c                   move      '1'           uxflag
     c                   z-add     5             prcrec
     c                   endif
     C*
     c                   endsr
     C*
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**  ZOPT - Valid options

**  ZOPT4 - Valid options for WINDOW4

**  ZOPT6 - Valid options for DSPSFL6

**  OPTLN - Option display line
X=Touched



**  OPTLNP - Option display line - Packers
X=Touched
                                                                       ons


**  OPTLNS - Option line 1 for *SPRECV

**  CMDLN - Command display line
F3=Exit  F9=PO/Mfr Code  F11=No-X  F12=Cancel
F3=Exit  F9=PO/Item  F11=No-X  F12=Cancel
F3=Exit  F9=PO/Mfr Code  F11=No-X  F12=Cancel
F3=Exit  F9=PO/Item  F11=No-X  F12=Cancel

F3=Exit  F9=PO/Mfr Code  F11=All  F12=Cancel
F3=Exit  F9=PO/Item  F11=All  F12=Cancel
F3=Exit  F9=PO/Mfr Code  F11=All  F12=Cancel
F3=Exit  F9=PO/Item  F11=All  F12=Cancel
**   OVRDBF statements
OVRDBF FILE(PO120A) TOFILE(POSPO) SHARE(*YES) LVLCHK(*NO)
OVRDBF FILE(PO120B) TOFILE(POSPO) SHARE(*YES) LVLCHK(*NO)
OVRDBF FILE(PO120C) TOFILE(POSPO2) SHARE(*YES) LVLCHK(*NO)
OVRDBF FILE(PO120D) TOFILE(POSPO2) SHARE(*YES) LVLCHK(*NO)
**   OPNQRYF statements for PO120A - whse/spo/po/item seq.
OPNQRYF FILE((POSPO) (PODTL)) FORMAT(PO120A) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789"')
KEYFLD((1/PUWHSE) (1/PUSPO) (1/PUPO) (2/PDITEM))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO *EQ))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO) SEQONLY(*NO)
**   OPNQRYF statements for PO120B - whse/spo/po/vitm seq.
OPNQRYF FILE((POSPO) (PODTL)) FORMAT(PO120B) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789"')
KEYFLD((1/PUWHSE) (1/PUSPO) (1/PUPO) (2/PDVITM))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO) SEQONLY(*NO)
**   OPNQRYF statements for PO120C - whse/spo/item/po seq.
OPNQRYF FILE((POSPO2) (PODTL)) FORMAT(PO120C) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDITEM = "123456789012345"')
KEYFLD((1/PUWHSE) (1/PUSPO) (2/PDITEM) (1/PUPO))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO)
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDITEM >="123456789012345"')
**   OPNQRYF statements for PO120D - whse/spo/vitm/po seq.
OPNQRYF FILE((POSPO2) (PODTL)) FORMAT(PO120D) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDVITM  ="123456789012345"')
KEYFLD((1/PUWHSE) (1/PUSPO) (2/PDVITM) (1/PUPO))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO)
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDVITM >="123456789012345"')
**   CLOF statement.
CLOF POSPO
CLOF POSPO2
