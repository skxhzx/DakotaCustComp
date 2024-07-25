740aA /COPY *libl/qcopysrc,hspecs
740aAH DFTACTGRP(*NO) ACTGRP(*CALLER)
740aAH BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
500 A*----------------------------------------------------------------
500 A*  Multilingual Verision
500 A*  Every screen and message has a corresponding Spanish version.
500 A*  Any changes must be made to both languages.
500 A*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   Wes Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT600     RF Item data collection
     *  26 February, 2001
     *  Hemant Kapadia
     *
     *  Notes
     *       Created using SU140
     *       8 X 20 Screens for hand held scanners
     *
     *
     *----------------------------------------------------------------
     *  Revisions
415 A*    02/26/01  HNK 4.15
     *      - Created
     *
415aA*    03/21/01  DAS 4.15a
     *      - Moved call to CVTBAR from ZZUPD2 into ZZCHK2.
     *      - Revised CVTBAR program to trap errors. Therefore,
     *        this program was revised to pass an error from CVTBAR
     *        to the user.
     *
415bA*    03/28/01  DAS 4.15b
     *      - Added check to make sure upc code isn't defined
     *        for a different item.
     *
415cA*    03/29/01  DAS 4.15c
     *      - Revised to allow a blank UPC code. In this case only
     *        dimensions will be updated, no the UPC file.
     *      - Changed UPC error into a warning/override.
     *      - Displaying new warning message plus message sent
     *        back from CVTBAR.
     *
416 A*    01/17/02  HNK 4.16
     *      - Revised to initialize W2UPC field.
     *
417aA*    04/14/03  RH   4.17a
     *      - Enh: Allow multiple items for one UPC code.
417bA*    02/05/04  DAS  4.17b
     *      - Enh: Added ability to work with virtual slots.
417cA*    02/28/04  MLB  4.17c
     *      - Fix: Revised ZZCHK1 to see if item attached to
     *        slot scanned by user. If no item attached, then
     *        flag error.
     *
500 A*    05/31/06  JCJ  5.00
     *      - Added Multilingual logic.
510aA*    07/16/07  RH   5.10a
     *      - Enh: Add screen 4 & screen4SP to capture tie/hi
530aA*    09/17/09  RH   5.30a
     *      - Enh: Add Client custom code support.
640aA*    01/27/11  RBD  6.40A
     *      - Enh: Add screen 5 & screen5SP to capture shipping
     *        weight.  If weight is 0, do not update PIRITEM.
     *      - Enh: If dimensions are 0, do not update PIRITEM.
640bA*    02/08/11  RH   6.40b
     *      - Fix: Was writing ITUM1 to ITEMDEF, change to 'N'
     *        for Normal UOM.
700aA*    06/02/15  RH   7.00a
     *      - Enh: Convert to ILE
     *        Add license to get item # on Screen1
     *        Move Screen 1 fields to the left.
700bA*    10/04/16  LMC  7.00b
     *      - Enh: Adding New screen for capturing breakdown UPC.
     *        This screen will display after the Normal UPC screen.
700cA*    03/06/17  LMC  7.00c
     *      - Fix: Init some of the breakdown fields, the data was
     *        being carried over to other items, and the UPC file was
     *        getting records loaded with no UOM, those records should
     *        not be loaded.
720aA*    05/10/18  LMC  7.20a
     *      - Enh: When loading breakdowns, have to consider ssb logic
720bA*    07/03/18  LMC  7.20b
     *      - Enh: Allow for multiple breakdown upc's to be loaded.
720cA*    07/06/18  LMC  7.20c
     *      - Enh: do not write the upc if it already exists.
730aA*    11/01/19  LMC  7.30a
     *      - Enh: Changed to use IT60004 upc field size on screen
     *        was increased to eliminate wrap/overflow problem.
730b *    11/25/19  RTR  7.30b
     *      - Enh: Default recalc cube to 'N'.
740a *    02/25/20  LMC  7.40a
     *      - Enh: Added ability to Replace all existing UPCs for the
     *        item being updated.
740b *    03/02/20  LMC  7.40b
     *      - Enh: Change the logic to always show the breakdown
     *        screen if the item is linked to a SSB item.
     *        Do not show the breakdown if the linked item is a breakdown
740c *    06/25/20  LMC  7.40c
     *      - Enh: Added parms to cvtbar.
     *----------------------------------------------------------------
HSY  *   Client custom revisions: Halsey
HSY A*    09/17/09  RH   HSY
     *      - Default recalculate cube to 'N'
     *----------------------------------------------------------------
GFCa *   Client custom revisions: Glazier
     *    05/12/12  GJA  GFCa
     *      - Default recalculate cube to 'N'
     *
     *----------------------------------------------------------------
     *   Client custom revisions: Kelly's Foods
KFS A*    08/15/13  MLB  KFS
     *      - Default recalculate cube to 'N'
     *      - Added KFS to HSY mod.
     *
     *----------------------------------------------------------------
     *   Client custom revisions: A&D Foods
     *    10/10/18  RTR  ADFa
ADFa *      - Default recalculate cube to 'N'
     *----------------------------------------------------------------
     *   Client custom revisions: Presto Foods
     *    12/05/17  GJA  PFCa
PFCa *      - Default recalculate cube to 'N'
     *----------------------------------------------------------------
     *   Custom Client Revisions: Palmer
     *
JPFa *    06/23/17  GJA  JPFa
     *      - Changed default of recalculate cube to "N"
     *
     *----------------------------------------------------------------
     *   Custom Client Revisions: Packers Provision
     *
PCKaA*    07/13/20  MLB  PCK
     *      - Changed pgm to default column to 8 on call to APICVTSLT.
     *        Cursor was being left in middle of Slot field.
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
     *  File Specs
     *
700aDF*t60001   cf   e             workstn
700bDF*it60002   cf   e             workstn
730aDF*it60003   cf   e             workstn
740aDF*it60004   cf   e             workstn
740aMFit60005   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiritem   uf   e           k disk
417aD*PC     UF  E           K        DISK                      A
417aMFupc2      uf a e           k disk
510a Fitemdef   uf a e           k disk
     Fslot2     if   e           k disk
     Foptions   if   e           k disk
417bAFvslot2    if   e           k disk
     F                                     rename(vsrec:vsrec2)
720aAFitemlnk1  if   e           k disk
720aAFpiritem1  if   e           k disk    prefix(ssb_) rename(itrec:itrec1)
720cAFupc3      uf a e           k disk    rename(uprec:uprec3)
740aAFupclogd   o    e           k disk
740aAFupc5      uf   e           k disk    rename(uprec:uprec5) prefix(u_)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
415cD**                  DESC    1   4 60
417cD**                  DESC    1   5 60
510aD**                  DESC    1   6 60
640aD**                  DESC    1   7 60
640aMD desc            s             60    dim(8) ctdata perrcd(1)
510aD**                  DESCSP  1   6 60
640aD**                  DESCSP  1   7 60
640aMD descsp          s             60    dim(8) ctdata perrcd(1)
     D hnd             s              2    dim(702)
530aA*----------------------------------------------------------------
530aA*  Customer id
530aA*
     D @getcl          c                   const('GETCLIENT')
530aA*
530aA /COPY QCOPYSRC,ID#HALSEY
GFCaA /COPY QCOPYSRC,ID#GLAZIER
KFSaA /COPY QCOPYSRC,ID#KFS
ADFaA /copy qcopysrc,id#adf
JPFaA /COPY QCOPYSRC,ID#palmer
PFCaA /COPY QCOPYSRC,ID#PFC
PCK A /copy qcopysrc,id#packers
700aA*----------------------------------------------------------------
700aA*  DRI parameters
700aA*----------------------------------------------------------------
700aA
700aA /COPY *libl/qcopysrc,C#DRIPARMS
700aA
700aA*----------------------------------------------------------------
700aA*  Data Formats
700aA*----------------------------------------------------------------
700aA
600aA /COPY *libl/qcopysrc,C#ITEM
700aA /COPY *libl/qcopysrc,C#LICENSE
600aAD saveVer#        s                   like($liver#)
740cA /COPY *libl/qcopysrc,C#CVTPARMS
     *----------------------------------------------------------------
700aA*  Called program parameters
     *
700aAD $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $pitem                39     53
700aAD  $plcns                54     68
     *
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  *ITEMMNT  -  Item maintenance options.
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
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     *----------------------------------------------------------------
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     *
     D  $litm                 22     36
     *
417bAD  $ldsp1                27     38
     *
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
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     *                                   P   1   20ERWHSE
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
700aA /Copy qcopysrc,c#pgminfds
700a D*               sds
700a D* #prog            *proc
700a D* #job                 244    253
700a D* #user                254    263
700a D* #jobn                264    269
700a D* #jobdt               276    281  0
700a D* #jobtm               282    287  0
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
740aA*----------------------------------------------------------------
740aA*  Time variables
740aA*----------------------------------------------------------------

740aAD CurrStamploc    s               z
740aAD CurrStampsys    s               z
740aAD CurrStampuc     s               z
740aAD bfcoffset       s              3  0 inz(0)
740aAD ucOffset        s              3  0

740aA*----------------------------------------------------------------
740aA*  Sub-procedure prototypes
740aA*----------------------------------------------------------------
740aAd GetCurrStamp    pr

740aA*----------------------------------------------------------------
740aA*  Called Programs Prototypes
740aA*----------------------------------------------------------------

740aAd/copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D actcub          s                   like(itcube)
700bAD b1type          s              7
700bAD b2type          s              7
700bAD b1upc           s                   like(upupc)
700bAD b2upc           s                   like(upupc)
700aAD chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D exist           s              1
     D forevr          s              1
     D hasvs           s              1
     D help            s              5  0
     D kydisp          s                   like(sldisp)
     D kywhdp          s                   like(slwhdp)
     D kywhse          s                   like(slwhse)
     D more            s              1
     D msgk            s              4  0
700bAD Needb1          s               n
700bAD Needb2          s               n
700bAD Ntype           s              7
     D newvs           s              1
     D nxtscr          s              3
     D ovrrid          s              1
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D skpslt          s              1
     D svfdis          s                   like(sldisp)
     D svscan          s             12
     D svupc           s                   like(w2upc)
     D tmpcub          s             15  6
     D warn            s              1
     D wkupc           s                   like(upupc)
700bAD Writeb1         s               n
700bAD Writeb2         s               n
700aAD zmflag          s               n
740aAD uomtype         s              1
740aAD uomcode         s              2
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in99 = *off
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
700bAC     nxtscr        caseq     '02B'         sc2b
     C     nxtscr        caseq     '03 '         sc3
510a C     nxtscr        caseq     '04 '         sc4
640aAC     nxtscr        caseq     '05 '         sc5
     C                   endcs
     C                   enddo
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
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   exfmt     scrn1sp                              50
500 AC                   other
     C                   exfmt     screen1                              50
500 AC                   endsl
     C                   endif
     C                   if        nxtscr = '02 '
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   exfmt     scrn2sp                              50
500 AC                   other
     C                   exfmt     screen2                              50
500 AC                   endsl
     C                   endif
700bAC                   if        nxtscr = '02B'
700bAC                   select
700bAC                   when      e$lng = 'SP'
700bAC                   exfmt     scrn2bsp                             50
700bAC                   other
700bAC                   exfmt     screen2b                             50
700bAC                   endsl
700bAC                   endif
     C                   if        nxtscr = '03 '
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   exfmt     scrn3sp                              50
500 AC                   other
     C                   exfmt     screen3                              50
500 AC                   endsl
     C                   endif
510a C                   if        nxtscr = '04 '
510aAC                   select
510aAC                   when      e$lng = 'SP'
510aAC                   exfmt     scrn4sp                              50
510aAC                   other
510a C                   exfmt     screen4                              50
510aAC                   endsl
510a C                   endif
640aAC                   if        nxtscr = '05 '
640aAC                   select
640aAC                   when      e$lng = 'SP'
640aAC                   exfmt     scrn5sp                              50
640aAC                   other
640aAC                   exfmt     screen5                              50
640aAC                   endsl
640aAC                   endif
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
740aAC                   setoff                                       4142
     C                   setoff                                       9298
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
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
     C                   eval      refrsh = *off
415cAC                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      exist = *off
     C                   eval      newvs = *off
     C                   eval      nxtscr = '02 '
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  Screen 02b initialization
700bA*
700bAC     scr02bi       begsr
700bA*
700bA*  This screen will get initiated if ifrcvmth = 3 to
740bA*  capture upc's for breakdown. This is no longer true
740bA*  We don't use the receiving method to control this.
700bA*
700bA*  We will display the screen2b if the item has breakdowns
700bA*  defined, and we do not have a UPC record for the breakdown uom
740bA*  This is also no longer true.
700bA*
740bA*  We will display the screen2b if the item has breakdowns
740bA*  defined, And the item is not linked to a Breakdown item.
740bA*  This will allow the client to capture upc for an item sold
740bA*  in multiple Unit of measures as the same item or an SSB item
700bA*
700bA /free
700bA   writeb1 = *off;
700bA   writeb2 = *off;
700cA   Needb1 = *off;
700cA   Needb2 = *off;
700cA   b1upc = ' ';
700cA   b2upc = ' ';
700bA   w2buom1 = ' ';
700bA   w2bupc1 = ' ';
700bA   w2buom2 = ' ';
700bA   w2bupc2 = ' ';
700bA   *in15 = *off;
700bA   *in16 = *off;
700bA   // breakdown 1 is setup on item
720aA   ssb_ititem = ' ';
720aA   ssb_ittype = ' ';
720aA   ssb_itum1 = ' ';
720aA   select;
720aA     when itum2 <> ' ' and itflg1 = 'Y';
720aD     //if itum2 <> ' ';
700bA       Needb1  = *on;
700bA       // do we have a upc loaded for this breakdown uom
720bD    //   setll (itwhse: ititem) upc2;
720bD    //   dow forevr = forevr;
720bD    //     reade(n) (itwhse: ititem) upc2;
720bD    //     if %eof(upc2);
720bD    //       leave;
720bD    //     endif;
720bD    //     if upuom = itum2;
720bD    //       needb1  = *off;
720bD    //       leave;
720bD    //     endif;
720bD    //   enddo;
720aD     //endif;
720aA     when itum2 <> ' ' and itflg1 <> 'Y';
720aA       Needb1  = *on;
720aA       // do we have an ssb item for this base item
720aA       setll (itwhse: ititem) itemlnk1;
720aA       dow forevr = forevr;
720aA         reade (itwhse: ititem) itemlnk1;
720aA         if %eof(itemlnk1);
720aA           leave;
720aA         endif;
720aA         // found one is it an ssb Item?
720aA         chain (itwhse: itwhdp: ilitem) piritem1;
720aA         if %found(piritem1);
740bA           // turn off needb1 if the linked item is an Breakdown
740bA           if ssb_ittype = 'B';
740bA             needb1  = *off;
740bA             leave;
740bA           endif;
720aA           if ssb_ittype = 'S';
740bD             // do we have a upc loaded for this ssb item uom
740bD             //setll (itwhse: ilitem) upc2;
740bD             //dow forevr = forevr;
740bD               //reade(n) (itwhse: ilitem) upc2;
740bD               //if %eof(upc2);
740bD                 //leave;
740bD               //endif;
740bD               //if upuom = ssb_itum1;
740bD                 //needb1  = *off;
740bD                 //leave;
740bD               //endif;
740bD             //enddo;
740bA             leave;
720aA           endif;
720aA         endif;
720aA       enddo;
720aA   endsl;
700bA   // breakdown 2 is setup on item
740bD   //if itum3 <> ' ';
740bA   if itum3 <> ' ' and itflg1 = 'Y';
700bA     Needb2  = *on;
700bA     // do we have a upc loaded for this breakdown uom
720bD   //  setll (itwhse: ititem) upc2;
720bD   //  dow forevr = forevr;
720bD   //    reade(n) (itwhse: ititem) upc2;
720bD   //    if %eof(upc2);
720bD   //      leave;
720bD   //    endif;
720bD   //    if upuom = itum3;
720bD   //      needb2  = *off;
720bD   //      leave;
720bD   //    endif;
720bD   //  enddo;
700bA   endif;
700bA   // need to capture a breakdown upc
700bA   if needb1 = *on or needb2 = *on;
700bA     nxtscr = '02B';
700bA     exsr zzdft2b;
700bA   else;
700bA     exsr scr03i;
700bA   endif;
700bA /end-free
700bAC     end02ib       endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   exsr      zzfil3
     C                   eval      refrsh = *off
     C     end03i        endsr
510a *----------------------------------------------------------------
510a *
510a *  Screen 04 initialization
510a *
510a C     scr04i        begsr
510a C                   eval      nxtscr = '04 '
510a C                   exsr      zzfil4
510a C                   eval      refrsh = *off
510a C     end04i        endsr
     *----------------------------------------------------------------
640aA*
640aA*  Screen 05 initialization
640aA*
640aAC     scr05i        begsr
640aAC                   eval      nxtscr = '05 '
640aAC                   exsr      zzfil5
640aAC                   eval      refrsh = *off
640aAC     end05i        endsr
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
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
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
     C     redspl        cabeq     *on           endsc1
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
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   eval      nxtscr = '01 '
     C                   eval      w1disp = svscan
     C                   goto      endsc2
     C                   endif
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
700bA*----------------------------------------------------------------
700bA*
700bA*  SC2b -  Screen 2b
700bA*
700bAC     sc2b          begsr
700bA*
700bA*  Test for F3 - Exit
700bA*
700baC                   if        *inkc
700bAC                   eval      nxtscr = 'EOJ'
700bAC                   goto      endsc2b
700bAC                   endif
700bA*
700bA*  Test for F5 - Refresh
700bA*
700bAC                   if        *inke
700bAC                   if        $pcmd <> '*VIEW   '
700bAC                   exsr      scr02bi
700bAC                   endif
700bAC                   goto      endsc2b
700bAC                   endif
700bA*
700bA*  Test for F12 - Previous
700bA*
700bAC                   if        *inkl
700bAC                   eval      nxtscr = '02 '
740aA /free
740aA   *in01 = *on;
740aA   if w2upcar <> 'R';
740aA     w2upcar = 'A';
740aA   endif;
740aA /end-free
700bAC                   goto      endsc2b
700bAC                   endif
700bA*  Test for F9  - skip
700bA*
700bAC                   if        *inki
700bAC                   eval      nxtscr = '03 '
700bA*    Setup command display line 1.
700bA*
700bAC                   goto      endsc2b
700bAC                   endif
700bA*
700bA*  Test for other command keys
700bA*
700bAC                   exsr      zzcmd2b
700bAC     cmdtkn        cabeq     *on           endsc2b
700bA*
700bA*  Some other key pressed.
700bA*
700bA*     Check input and write/update record.
700bA*
700bA
700bAC                   exsr      zzchk2b
700bAC     error         cabeq     *on           endsc2b
700bAC                   exsr      zzupd2b
700bAC     error         cabeq     *on           endsc2b
700bA*
700bAC                   exsr      scr03i
700bAC     endsc2b       endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   eval      nxtscr = '02 '
740aA /free
740aA   *in01 = *on;
740aA   if w2upcar <> 'R';
740aA     w2upcar = 'A';
740aA   endif;
740aA /end-free
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
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
510a *----------------------------------------------------------------
510a *
510a *  SC4  -  Screen 4
510a *
510a C     sc4           begsr
510a *
510a *  Test for F3 - Exit
510a *
510a C                   if        *inkc
510a C                   eval      nxtscr = 'EOJ'
510a C                   goto      endsc4
510a C                   endif
510a *
510a *  Test for F5 - Refresh
510a *
510a C                   if        *inke
510a C                   eval      refrsh = *on
510a C                   exsr      scr04i
510a C                   goto      endsc4
510a C                   endif
510a *
510a *  Test for F12 - Previous
510a *
510a C                   if        *inkl
510a C                   eval      refrsh = *off
510a C                   eval      nxtscr = '03 '
510a C                   goto      endsc4
510a C                   endif
510a *
510a *  Test for other command keys BEFORE verification and update.
510a *
510a C                   eval      cmdchk = '*BEFORE '
510a C                   exsr      zzcmd4
510a C     cmdtkn        cabeq     *on           endsc4
510a *
510a *  Some other key pressed.
510a *
510a *     Check input and write/update record.
510a *
510a C                   exsr      zzchk4
510a C     error         cabeq     *on           endsc4
510a C                   exsr      zzupd4
510a C     error         cabeq     *on           endsc4
510a *
510a *  Test for other command keys AFTER verification and update.
510a *
510a C                   eval      cmdchk = '*AFTER  '
510a C                   exsr      zzcmd4
510a C     cmdtkn        cabeq     *on           endsc4
510a *
510a C     endsc4        endsr
     *----------------------------------------------------------------
640aA*
640aA*  SC5  -  Screen 5
640aA*
640aAC     sc5           begsr
640aA*
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr05i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   eval      nxtscr = '04 '
     C                   goto      endsc5
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     C     endsc5        endsr
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
740aA*----------------------------------------------------------------
740aA*
740aA*  UPCREPLACE  USER REQUESTED TO REPLACE ALL UPC WITH A NEW ONE
740aA*
740aAC     UPCReplace    begsr
740aA /free
740aA   setll (w1whse: w2item: uomtype: uomcode)upc5;
740aA   dow forevr = forevr;
740aA     reade (w1whse: w2item: uomtype: uomcode)upc5;
740aA     if %eof(upc5);
740aA       leave;
740aA     endif;
740aA     // move to log file UPCLOGD
740aA     updwhse   = u_upwhse;
740aA     upditem   = u_upitem;
740aA     updupc    = u_upupc;
740aA     updven    = u_upven;
740aA     updvnam   = u_upvnam;
740aA     updvitm   = u_upvitm;
740aA     updbran   = u_upbran;
740aA     upduom    = u_upuom;
740aA     updutyp   = u_uputyp;
740aA     updctyp   = u_upctyp;
740aA     GetCurrStamp();
740aA     udaddts = currstampsys;
740aA     udadduc = currstampuc;
740aA     udaddcpgm = #prog;
740aA     udaddjpgm = #prog;
740aA     udaddemp = e$emp#;
740aA     udaddeusr = #user;
740aA     udaddcusr = #user;
740aA     udaddjusr = #user;
740aA     udaddjob = #job;
740aA     udaddnbr = #jobn;
740aA     write updrec;
740aA     // now delete
740aA     delete uprec5;
740aA   enddo;
740aA /end-free
740aAC                   endsr
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      $msgf = #msgsp
500 AC                   other
     C                   eval      $msgf = #msgf
500 AC                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0105  Invalid slot entered.
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Value cannot be blank
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
700aA*----------------------------------------------------------------
700aA*    LP11022  License not on file.
700aA*
700aAC     zm022         begsr
700aAC                   eval      #msgid = 'LP11022'
700aAC                   eval      #msgtp = '*DIAG  '
700aAC                   eval      $md = *blanks
700aAC                   exsr      zmpmsg
700aAC                   endsr
     *----------------------------------------------------------------
     *   IT28001  Invalid slot entered.
     *
     C     zm2801        begsr
     C                   eval      #msgid = 'IT28001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0110  Number must be > 0
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL16001 No more zero slots.
     *
     C     zm1601        begsr
     C                   eval      #msgid = 'SL16001'
     C                   eval      #msgtp = '*DIAG  '
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
415bA*----------------------------------------------------------------
415bA*   PIR0202  Code already exists.
415bA*
415bAC     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *   Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Verify warehouse department.
     *
     *  Only if slot is entered, not if license is used.
700aAC                   if        w1disp <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
700aAC                   endif
     *
     *  Slot can't be blank and license
     *
     C                   if        w1disp = *blanks
700aAC                             and w1lcns = *blanks
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     descsp(2)     errmsg
500 AC                   other
     C                   movea     desc(2)       errmsg
500 AC                   endsl
     C                   exsr      zm0203
     C                   endif
700aA*
700aA*  Verify License if entered.
700aA*
700aAC                   if        w1lcns <> ' '
700aAC                   exsr      clr$license
700aAC                   eval      $liToLcnsU = *on
700aAC                   eval      $liToLcns = w1lcns
700aAC                   eval      $dricommand = '*LICENSE'
700aMC                   eval      $drisubcmd  = '%GETINFO'
700aAC                   eval      $drisys2upd = 'D'
700aAC                   eval      chk4err = *on
700aAC                   eval      zmflag  = *off
700aAC                   exsr      zzzdricop

700aAC                   if        error
700aAC                   eval      *in23 = *on
700aAC                   eval      *in03 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   exsr      zm022
700aAC                   else
700aAC                   eval      w1disp = $litodisp
700eAc                   if        $litowhdp <> ' '
700dAC                   eval      w1whdp = $litowhdp
700eAc                   endif
700aAC                   endif
700aAC                   goto      endck1
700aAC                   endif
     *
     *  Call API for slot.
     *
700aAC                   if        w1disp <> *blanks
PCK A*
PCK AC                   select
PCK AC                   when      client = pack730
PCK AC                   eval      worow = 5
PCK AC                   eval      wocol = 8
PCK AC                   other
PCK AC                   eval      worow = 5
PCK AC                   eval      wocol = 13
PCK A*
PCK AC                   endsl
     C                   call      @apics
     C                   parm                    w1disp
PCK MC                   parm                    worow
PCK MC                   parm                    wocol
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck1
     C                   endif
     C                   endif
     *
     *  Verify slot
     *
     C                   if        w1disp <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   eval      $litem = *blanks
     C                   eval      $ldisp = w1disp
     C                   call      'SL900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   eval      svscan = w1disp
     C                   endif
417bA*
417bA*    Check for virtual slots attached to pick slot.
417bA*
417bAC                   select
417bAC                   when      error = *off
417bAC                   eval      kywhse = w1whse
417bAC                   eval      kywhdp = w1whdp
417bAC                   eval      kydisp = w1disp
417bAC                   exsr      zzchkv
417bAC                   if        hasvs = *on
417bAC                   eval      $lcmd = '*SELECT '
417bAC                   eval      $lwhse = w1whse
417bAC                   eval      $lwhdp = w1whdp
417bAC                   eval      $ldsp1 = w1disp
417bAC                   call      'VS820'
417bAC                   parm                    $lparm
417bAC                   select
417bAC                   when      $lrtn = '*SELECT '
417bAC                   eval      w1disp = $ldsp1
417bAC                   other
417bAC                   eval      error = *on
417bAC                   endsl
417bAC                   endif
417bAC                   endsl
417cA*
417cA*    Verify item attached to slot scanned by user.
417cAC     keysl2        chain     slot2                              79
417cAC                   if        not *in79  and
417cAC                             slitem = *blanks
417cAC                   eval      error = *on
417cAC                   eval      *in24 = *on
417cAC                   eval      *in04 = *on
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     descsp(6)     errmsg
500 AC                   other
417cAC                   movel     desc(6)       errmsg
500 AC                   endsl
417cAC                   exsr      zm0105
417cAC                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
415cA*
415cA*  Skip UPC logic if UPC is blank.
415cA*
415cAC                   if        w2upc = *blanks
415cAC                   eval      wkupc = *blanks
415cAC                   goto      endck2
415cAC                   endif
740aA*
740aA*  validate Add/Rpl flag.
740aA*
740aA /free
740aA   if w2upcar <> 'A' and w2upcar <> 'R';
740aA     error = *on;
740aA     *in41 = *on;
740aA     errmsg = 'Invalid use A or R';
740aA     exsr zm0105;
740aA   endif;
740aA /end-free
415cA*
415cA*  Skip UPC code verification if second time around.
415cA*
415cAC                   if        ovrrid = *on  and
415cAC                             w2upc = svupc
415cAC                   goto      skpupc
415cAC                   endif
415cAC                   eval      svupc = w2upc
     *
415aA*
415aA*  Extract UPC code from entered string.
415aA*
415aAC                   eval      $cbcmd = '*UPC    '
415aAC                   eval      $cbbar = w2upc
415aA*
415aAC                   call      'CVTBAR'
415aAC                   parm                    $cbcmd            8
415aAC                   parm                    $cbbar          100
415aAC                   parm                    $cbcod            3 0
415aAC                   parm                    $cbdec            1 0
415aAC                   parm                    $cbdsc           30
415aAC                   parm                    $cbpos            3 0
415aAC                   parm                    $cbtyp            1 0
415aAC                   parm                    $cbv1            11 3
415aAC                   parm                    $cbv2            50
415aAC                   parm                    $cbrtn            8
415aAC                   parm                    $cberm           60
740cAC                   parm      itven#        $cbven           10 0
740cAC                   parm                    $cvtdata
740cAC                   parm                    $cvtdata2
740cAC                   parm      w1whse        $cbwhse           3 0
740cAC                   parm                    $cbsent           1
740cAC                   parm                    $cbitem          15
415aA*
415aAC                   select
415aAC                   when      $cbrtn = '*OK'
700bAc                   eval      ntype = %trimr($cbdsc)
415aAC                   movel     $cbv2         $cstr
415aAC                   call      'ADJUST'
415aAC                   parm      '*RIGHT  '    $ccmd             8
415aAC                   parm                    $cstr            30
415aAC                   eval      wkupc = *blanks
415aAC                   move      $cstr         wkupc
415aA*
415aAC                   other
415aAC                   eval      error = *on
415cAC                   eval      warn = *on
415aAC                   eval      *in21 = *on
415aAC                   eval      *in01 = *on
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     descsp(5)     errmsg
500 AC                   other
415cAC                   movel(p)  desc(5)       errmsg
500 AC                   endsl
415cAC                   exsr      zm0105
415aAC                   movel     $cberm        errmsg
415aAC                   exsr      zm0105
415cAC                   movel     w2upc         $cstr
415cAC                   call      'ADJUST'
415cAC                   parm      '*RIGHT  '    $ccmd
415cAC                   parm                    $cstr
415cAC                   eval      wkupc = *blanks
415cAC                   move      $cstr         wkupc
415cAC                   goto      endck2
415aAC                   endsl
     *
415cAC     skpupc        tag
     *
417aA*   Following code removed, upc can exist for multiple items.
417aD*   Verify upc code isn't already defined for different item.
417aD*
417aD*R         KEYUPC    CHAINUPC                 N79
417aD*R         *IN79     IFEQ *OFF
417aD*R         UPITEM    ANDNEW2ITEM
417aD*R                   MOVE *ON       ERROR
417aD*R                   MOVE *ON       *IN21
417aD*R                   MOVE *ON       *IN01
417aD*R                   MOVE *BLANKS   ERRMSG
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     descsp(4)     errmsg
500 AC                   other
417aD*R                   MOVELDESC,4    ERRMSG
500 AC                   endsl
417aD*R                   EXSR ZM02
417aD*R                   ENDIF
     *
     C     endck2        endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  ZZCHK2b  Screen 2 error checking.
700bA*
700bAC     zzchk2b       begsr
700bAC                   eval      error = *off
700bA*  at least one UPC must be entered or f9 to skip.
700bA*
700bA*  Extract UPC code from entered string.
700bA*
700bA * reset indicators so we only display the needed breakdowns
700bA /free
700bA   if w2buom1 = ' ';
700bA     *in38 = *on;
700bA   endif;
700bA   if w2buom2 = ' ';
700bA     *in39 = *on;
700bA   endif;
700bA /end-free
740aA*
740aA*  validate Add/Rpl flag.
740aA*
740aA /free
740aA   if W2BUPC1 <> ' ' or W2BUPC2 <> ' ';
740aA     if w2bupcar <> 'A' and w2bupcar <> 'R';
740aA       error = *on;
740aA       *in42 = *on;
740aA       errmsg = 'Invalid use A or R';
740aA       exsr zm0105;
740aA     endif;
740aA   endif;
740aA /end-free
700bA * edit breakdown 1 upc
700bAc                   if        w2buom1 <> ' ' and
700bAC                             w2bupc1 <> *blanks
700bAC                   eval      $cbcmd = '*UPC    '
700bAC                   eval      $cbbar = w2bupc1
700bA*
700bAC                   call      'CVTBAR'
700bAC                   parm                    $cbcmd            8
700bAC                   parm                    $cbbar          100
700bAC                   parm                    $cbcod            3 0
700bAC                   parm                    $cbdec            1 0
700bAC                   parm                    $cbdsc           30
700bAC                   parm                    $cbpos            3 0
700bAC                   parm                    $cbtyp            1 0
700bAC                   parm                    $cbv1            11 3
700bAC                   parm                    $cbv2            50
700bAC                   parm                    $cbrtn            8
700bAC                   parm                    $cberm           60
740cAC                   parm      itven#        $cbven           10 0
740cAC                   parm                    $cvtdata
740cAC                   parm                    $cvtdata2
740cAC                   parm      w1whse        $cbwhse           3 0
740cAC                   parm                    $cbsent           1
740cAC                   parm                    $cbitem          15
700bA*
700bAC                   movel     $cbv2         $cstr
700bAC                   call      'ADJUST'
700bAC                   parm      '*RIGHT  '    $ccmd             8
700bAC                   parm                    $cstr            30
700bAC                   move      $cstr         b1upc
700bAC                   endif
700bA*   Do UPC Check
700bAC                   if        w2bupc1 <> ' '
700bA*
700bA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700bAC                   select
700bA*
700bAC                   when      $cbrtn = '*OK'
700bAc                   eval      writeb1 = *on
700bAc                   eval      b1type = %trimr($cbdsc)
700bA*
700bAC                   other
700bAC                   eval      error = *on
700bAC                   eval      *in15 = *on
700bAC                   movel     $cberm        errmsg
700bAC                   exsr      zm0105
700bAC                   endsl
700bA*
700bAC     error         cabeq     *on           endck2b
700bAC                   endif
700bA*
700bA * edit breakdown 2 upc
700bAc                   if        w2buom2 <> ' ' and
700bAC                             w2bupc2 <> *blanks
700bAC                   eval      $cbcmd = '*UPC    '
700bAC                   eval      $cbbar = w2bupc2
700bA*
700bAC                   call      'CVTBAR'
700bAC                   parm                    $cbcmd            8
700bAC                   parm                    $cbbar          100
700bAC                   parm                    $cbcod            3 0
700bAC                   parm                    $cbdec            1 0
700bAC                   parm                    $cbdsc           30
700bAC                   parm                    $cbpos            3 0
700bAC                   parm                    $cbtyp            1 0
700bAC                   parm                    $cbv1            11 3
700bAC                   parm                    $cbv2            50
700bAC                   parm                    $cbrtn            8
700bAC                   parm                    $cberm           60
740cAC                   parm      itven#        $cbven           10 0
740cAC                   parm                    $cvtdata
740cAC                   parm                    $cvtdata2
740cAC                   parm      w1whse        $cbwhse           3 0
740cAC                   parm                    $cbsent           1
740cAC                   parm                    $cbitem          15
700bA*
700bAC                   movel     $cbv2         $cstr
700bAC                   call      'ADJUST'
700bAC                   parm      '*RIGHT  '    $ccmd             8
700bAC                   parm                    $cstr            30
700bAC                   move      $cstr         b2upc
700bAC                   endif
700bA*   Do UPC Check
700bAC                   if        w2bupc2 <> ' '
700bA*
700bA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700bAC                   select
700bA*
700bAC                   when      $cbrtn = '*OK'
700bAc                   eval      writeb2 = *on
700bAc                   eval      b2type = %trimr($cbdsc)
700bA*
700bAC                   other
700bAC                   eval      error = *on
700bAC                   eval      *in16 = *on
700bAC                   movel     $cberm        errmsg
700bAC                   exsr      zm0105
700bAC                   endsl
700bA*
700bAC     error         cabeq     *on           endck2b
700bAC                   endif
700bA*
700bAC     endck2b       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     *
     *  Dimensions must be within range.
     *
     C                   if        w3ulen < 0  or
     C                             w3ulen > 999.99
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   endif
     *
     C                   if        w3uwdt < 0  or
     C                             w3uwdt > 999.99
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif
     *
     C                   if        w3uhgt < 0  or
     C                             w3uhgt > 999.99
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif
     *
     C                   if        *in21  or
     C                             *in22  or
     C                             *in23
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     descsp(1)     errmsg
500 AC                   other
     C                   movel     desc(1)       erfld
500 AC                   endsl
     C                   movel     *off          erfrom
     C                   movel     '999.99'      erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify Recalculate option (Y,N)
     *
     C                   if        w3calc <> 'Y'  and
     C                             w3calc <> 'N'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     descsp(3)     errmsg
500 AC                   other
     C                   movel     desc(3)       errmsg
500 AC                   endsl
     C                   exsr      zm1001
     C                   endif
     *
     *
     C     endck3        endsr
510a *----------------------------------------------------------------
510a *
510a *  ZZCHK4   Screen 4 error checking.
510a *
510a C     zzchk4        begsr
510a C                   eval      error = *off
510a *
510a *  Tie/hi must be within range.
510a *
510a C                   if        w4tie < 0  or
510a C                             w4tie > 9999
510a C                   eval      *in25 = *on
510a C                   eval      *in05 = *on
510a C                   endif
510a *
510a C                   if        w4hi < 0  or
510a C                             w4hi > 99
510a C                   eval      *in26 = *on
510a C                   eval      *in06 = *on
510a C                   endif
510a *
510a *  Can not enter 0 for only one value tie or hi.
510a *  Both must be 0 or both have value.
510a C                   if        w4tie = 0  and
510a C                             w4hi <> 0  or
510a C                             w4hi = 0  and
510a C                             w4tie <> 0
510a C                   eval      *in25 = *on
510a C                   eval      *in05 = *on
510a C                   eval      *in26 = *on
510a C                   eval      *in06 = *on
510a C                   endif
510a *
510a C                   if        *in25  or
510a C                             *in26
510a C                   eval      error = *on
510a C                   eval      errmsg = *blanks
510a C                   select
510a C                   when      e$lng = 'SP'
510a C                   movea     descsp(7)     errmsg
510a C                   other
510a C                   movel     desc(7)       erfld
510a C                   endsl
510a C                   movel     *off          erfrom
510a C                   movel     '999   '      erto
510a C                   exsr      zm0112
510a C                   endif
510a *
510a *
510a C     endck4        endsr
     *----------------------------------------------------------------
640aA*
640aA*  ZZCHK5   Screen 5 error checking.
640aA*
640aAC     zzchk5        begsr
640aAC                   eval      error = *off
640aA*
     *  Shipping weight must be within range.
     *
     C                   if        w5swgt < 0  or
     C                             w5swgt > 9999
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   endif
     *
     C                   if        *in27
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movea     descsp(8)     errmsg
     C                   other
     C                   movel     desc(8)       erfld
     C                   endsl
     C                   movel     *off          erfrom
     C                   movel     '999   '      erto
     C                   exsr      zm0112
     C                   endif
     *
     C     endck5        endsr
417bA*----------------------------------------------------------------
417bA*
417bA*  ZZCHKV   Check if slot has virtual slots tied to it.
417bA*
417bAC     zzchkv        begsr
     C                   eval      error = *off
     C                   eval      hasvs = *off
     *
     C     keyvs2        setll     vslot2
     C                   dou       forevr <> forevr
     C     keyvs2        reade     vslot2                               7879
     C                   if        *in79
     C                   leave
     C                   endif
     *    If slot read same as one selected for replenishment, skip
     *    this slot and see if any other virtuals exist.
     C                   if        skpslt = *on  and
     C                             vsdisp = svfdis
     C                   iter
     C                   endif
     *  Skip, if slot is empty
     C                   call      'RTNSTAT'
     C                   parm                    kywhse
     C                   parm                    kywhdp
     C                   parm                    vsdisp
     C                   parm                    $pstat            2
     C                   if        $pstat = 'Z '
     C                   iter
     C                   endif
     *
     C                   eval      hasvs = *on
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
415cA*
415cA*      F10 - Accept Warning.
415cA*
415cAC                   if        *inkj
415cAC                   eval      ovrrid = *on
415cAC                   else
415cAC                   eval      ovrrid = *off
415cAC                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  ZZCMD2b  User defined command keys for screen 2b.
700bA*
700bAC     zzcmd2b       begsr
700bAC                   eval      cmdtkn = *off
700bA*
700bAC     endcm2b       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
510a *----------------------------------------------------------------
510a *
510a *  ZZCMD4   User defined command keys for screen 4.
510a *
510a C     zzcmd4        begsr
510a *
510a *  Command keys to check BEFORE verification and update.
510a *
510a C                   if        cmdchk = '*BEFORE '
510a *
510a C                   endif
510a *
510a *  Command keys to check AFTER verification and update.
510a *
510a C                   if        cmdchk = '*AFTER  '
510a C                   endif
510a C     endcm4        endsr
     *----------------------------------------------------------------
640aA*
640aA*  ZZCMD5   User defined command keys for screen 5.
640aA*
640aAC     zzcmd5        begsr
640aA*
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm5        endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  ZZDFT2b  Get default values for add.
700bA*
700bAC     zzdft2b       begsr
700bA /free
700bA   // setup which fields are displayed
700bA   if needb1 = *on;
700bA     w2bupc1 = ' ';
700bA     w2buom1 = itum2;
700bA     *in38 = *off;
700bA   else;
700bA     *in38 = *on;
700bA   endif;
700bA   if needb2 = *on;
700bA     w2bupc2 = ' ';
700bA     w2buom2 = itum3;
700bA     *in39 = *off;
700bA   else;
700bA     *in39 = *on;
700bA   endif;
740aA   *in01 = *on;
740aA   if w2bupcar <> 'R';
740aA     w2bupcar = 'A';
740aA   endif;
700bA /end-free
700bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1disp = *blanks
415cAC                   eval      svupc = '#*'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   eval      w2item = *blanks
     C                   eval      w2desc = *blanks
416 AC                   eval      w2upc = *blanks
     C                   eval      w2disp = w1disp
740aA /free
740aA   *in01 = *on;
740aA   if w2upcar <> 'R';
740aA     w2upcar = 'A';
740aA   endif;
740aA /end-free
     C     keysl2        chain     slot2                              79
     C                   if        not *in79
     C                   eval      w2item = slitem
     C                   endif
     *
     C     keyit         chain(n)  piritem                            79
     C                   if        not *in79
     C                   eval      w2desc = itdesc
     C                   eval      w2mfgc = itvit#
640aAC                   else
640aAC                   eval      w5swgt = 0
     C                   endif
     *
     C     endfl2        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     C                   eval      w3item = w2item
     C                   eval      w3desc = w2desc
     C                   eval      w3disp = w2disp
     C                   eval      w3ulen = itulen
     C                   eval      w3uwdt = ituwdt
     C                   eval      w3uhgt = ituhgt
730bDC****               if        client = halsey  or
GFCaAC*                            client = gfc  or
JPFaAC*                            client = palmer or
KFS AC*                            client = kellys or
PFCaAC*                            client = presto
ADFaAC*                            or client = AandDFoods
HSY AC                   eval      w3calc = 'N'
HSY AC*                  else
     C*                  eval      w3calc = 'Y'
730bAC****               endif
     C     endfl3        endsr
510a *----------------------------------------------------------------
510a *
510a *  ZZFIL4   Fill screen 4 fields with info from file.
510a *
510a C     zzfil4        begsr
510a *
510a C     keyid         chain(n)  itemdef                            79
510a C                   if        not *in79
510a C                   eval      w4tie = idtie
510a C                   eval      w4hi = idhigh
510a C                   endif
510a *
510a C                   eval      w4item = w3item
510a C                   eval      w4desc = w3desc
510a C                   eval      w4disp = w3disp
510a C     endfl4        endsr
     *----------------------------------------------------------------
640aA*
640aA*  ZZFIL5   Fill screen 5 fields with info from file.
640aA*
640aAC     zzfil5        begsr
640aA*
     C                   eval      w5swgt = itswgt
     *
     C                   eval      w5item = w4item
     C                   eval      w5desc = w4desc
     C                   eval      w5disp = w4disp
     C     endfl5        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      forevr = *off
417bAC                   eval      skpslt = *off
510a *
510a *  Define key for ITEMDEF.
510a *
510a C     keyid         klist
510a C                   kfld                    w1whse
510a C                   kfld                    w2item
510a C                   kfld                    slsdef
     *
     *  Define key for PIRITEM.
     *
     C     keyit         klist
     C                   kfld                    w1whse
     C                   kfld                    w2item
     *
     *  Define key for slot2 file by display field.
     *
     C     keysl2        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    w1disp
     *
     *  Define key for UPC.
     *
     C     keyupc        klist
     C                   kfld                    w1whse
417aAC                   kfld                    w2item
     C                   kfld                    wkupc
     *
     *  Define key for options file.
     *
     C     optnky        klist
     C                   kfld                    w1whse
     C                   kfld                    opcode
417bA*
417bA*    Define key for VSLOT2 file.
417bA*
417bAC     keyvs2        klist
417bAC                   kfld                    kywhse
417bAC                   kfld                    kywhdp
417bAC                   kfld                    kydisp
415cA*
415cA*  Define variables
415cA*
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     *
     C                   eval      w1whse = #whse
530aA*
530aA* Get client id.
530aAC                   call      @getcl
530A C                   parm                    client           10
530A C                   parm                    cliloc           10
530AA*
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
500 A*
500 A*   Get employee options.
500 A*
500 AC                   call      'GETUSER'
500 AC                   parm      #user         e$code           10
500 AC                   parm                    e$whse            3 0
500 AC                   parm                    e$emp#            5 0
500 AC                   parm                    e$fnam           15
500 AC                   parm                    e$init            1
500 AC                   parm                    e$lnam           20
500 AC                   parm                    e$whdp            5
500 AC                   parm                    e$styp            1
500 AC                   parm                    e$shft            6
500 AC                   parm                    e$crew            6
500 AC                   parm                    e$nhrs            3 1
500 AC                   parm                    e$rtn             8
500 AC                   parm                    e$bpu             1
500 AC                   parm                    e$lng             2
500 AC                   if        e$rtn <> '*OK'
500 AC                   eval      e$lng = 'EN'
500 AC                   endif
500 A*
     C                   eval      worow = 0
     C                   eval      wocol = 0
     *
     C                   eval      refrsh = *on
     C                   eval      more = *off
     C                   eval      w1whdp = *blanks
700bAC                   eval      needb1 = *off
700bAC                   eval      needb2 = *off
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   exsr      scr02i
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
415aD**                   MOVE '*UPC    '$CBCMD
415aD**                   MOVELW2UPC     $CBBAR    P
415aD**
415aD**                   CALL 'CVTBAR'
415aD**                   PARM           $CBCMD  8
415aD**                   PARM           $CBBAR100
415aD**                   PARM           $CBCOD  30
415aD**                   PARM           $CBDEC  10
415aD**                   PARM           $CBDSC 30
415aD**                   PARM           $CBPOS  30
415aD**                   PARM           $CBTYP  10
415aD**                   PARM           $CBV1  113
415aD**                   PARM           $CBV2  50
415aD**                   PARM           $CBRTN  8
415aD**                   PARM           $CBERM 60
415aD**
415aD**                   SELEC
415aD**         $CBRTN    WHEQ '*OK'
415aD**         $CBTYP    IFEQ 2
415aD**                   MOVEL$CBV2     $CSTR
415aD**                   CALL 'ADJUST'
415aD**                   PARM '*RIGHT  '$CCMD   8
415aD**                   PARM           $CSTR  30
415aD**                   MOVE *BLANKS   WKUPC
415aD**                   MOVE $CSTR     WKUPC
415aD**
415aD**                   ELSE
415aD**
415aD**                   MOVE $CBV1     $EDNUM
415aD**                   Z-ADD3         $EDDEC
415aD**                   CALL 'EDITNA'
415aD**                   PARM           $EDCMD  8
415aD**                   PARM           $EDNUM 110
415aD**                   PARM           $EDDEC  20
415aD**                   PARM           $EDALP 12
415aD**                   PARM           $EDFPS  20
415aD**                   MOVE *BLANKS   $CSTR
415aD**                   MOVEL$CBV2     $CSTR
415aD**                   CALL 'ADJUST'
415aD**                   PARM '*RIGHT  '$CCMD   8
415aD**                   PARM           $CSTR  30
415aD**                   MOVE *BLANKS   WKUPC
415aD**                   MOVE $CSTR     WKUPC
415aD**                   ENDIF
415aD**
415aD**                   OTHER
415aD**                   MOVE *BLANKS   $CSTR
415aD**                   MOVELW2UPC     $CSTR
415aD**                   CALL 'ADJUST'
415aD**                   PARM '*RIGHT  '$CCMD   8
415aD**                   PARM           $CSTR  30
415aD**                   MOVE *BLANKS   WKUPC
415aD**                   MOVE $CSTR     WKUPC
415aD**                   ENDSL
     *
700bDC*                  exsr      scr03i
700bMC                   exsr      scr02bi
     C     endup2        endsr
     *
700bA*----------------------------------------------------------------
700bA*
700bA*  ZZUPD2b  Write breakdown upc
700bA*
700bAC     zzupd2b       begsr

700bA /free
700bA   // breakdown1
700bA   if writeb1 = *on;
700bA     upwhse = itwhse;
720aA     if ssb_ittype = 'S';
720aA       upitem = ssb_ititem;
720aA     else;
700bA       upitem = ititem;
720aA     endif;
700bA     upupc = b1upc;
700bA     upven = 0;
740aA     // if replace was requested remove all upcs for item/uom
740aA     if w2bupcar = 'R';
740aA       uomtype = '1';
740aA       uomcode = itum2;
740aA       exsr UPCReplace;
740aA     endif;
720cA     // is this upc already loaded for this item
720cA     chain (upwhse: upitem: upupc: upven) upc3;
700bA     upvnam = ' ';
700bA     upvitm = itvit#;
700bA     upbran = ' ';
700bA     upuom = w2buom1;
700bA     uputyp = '1';
700bA     Select;
700bA       when b1type = 'UPC-12';
700bA         upctyp = '1';
700bA       when b1type = 'EAN-13';
700bA         upctyp = '2';
700bA       when b1type = 'GTIN';
700bA         upctyp = '3';
700bA       when b1type = 'SCC-14';
700bA         upctyp = '4';
700bA       when b1type = 'SSCC-18';
700bA         upctyp = '5';
700bA     endsl;
720cA     if %found(upc3);
720cA       update uprec3;
720cA     else;
720cD     //write uprec;
720cM       write uprec3;
720cA     endif;
700bA   endif;
700bA   // breakdown2
700bA   if writeb2 = *on;
700bA     upwhse = itwhse;
700bA     upitem = ititem;
700bA     upupc = b2upc;
700bA     upven = 0;
740aA     // if replace was requested remove all upcs for item/uom
740aA     if w2bupcar = 'R';
740aA       uomtype = '2';
740aA       uomcode = itum3;
740aA       exsr UPCReplace;
740aA     endif;
720cA     // is this upc already loaded for this item
720cA     chain (upwhse: upitem: upupc: upven) upc3;
700bA     upvnam = ' ';
700bA     upvitm = itvit#;
700bA     upbran = ' ';
700bA     upuom = w2buom2;
700bA     uputyp = '2';
700bA     Select;
700bA       when b2type = 'UPC-12';
700bA         upctyp = '1';
700bA       when b2type = 'EAN-13';
700bA         upctyp = '2';
700bA       when b2type = 'GTIN';
700bA         upctyp = '3';
700bA       when b2type = 'SCC-14';
700bA         upctyp = '4';
700bA       when b2type = 'SSCC-18';
700bA         upctyp = '5';
700bA     endsl;
720cA     if %found(upc3);
720cA       update uprec3;
720cA     else;
720cD     //write uprec;
720cM       write uprec3;
720cA     endif;
700bA   endif;
700bA /end-free
700bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     *   Get item maintenance options.
     *
     C                   eval      opcode = '*ITEMMNT'
     C     optnky        chain     options                            79
     C                   if        *in79
     C                   clear                   opdata
     C                   endif
     *
     *   Update ITEM FILE.
     *
     C     keyit         chain     piritem                            79
     C                   if        not *in79  and
640aAC                             w3ulen > 0  or
640aAC                             not *in79  and
640aAC                             w3uwdt > 0  or
640aAC                             not *in79  and
640aAC                             w3uhgt > 0  or
640aAC                             not *in79  and
640aAC                             w3calc = 'Y'
     C                   eval      itvit# = w2mfgc
     C                   eval      itulen = w3ulen
     C                   eval      ituwdt = w3uwdt
     C                   eval      ituhgt = w3uhgt
     *
     *  Calculate actual cube according to dimensions entered.
     *
     C                   if        opcdiv = 0
     C                   eval      actcub = 0
     C                   else
     C                   eval      tmpcub = w3ulen * w3uwdt
     C                   mult      w3uhgt        tmpcub
     C     tmpcub        div(h)    opcdiv        actcub
     C                   endif
     *
     *   Use calculated cube if ...
     *      Auto calculate option is 'Y'
     *      and Cube entered is zero.
     *
     C                   if        opcaut = 'Y'  and
     C                             itcube = 0
     C                   eval      itcube = actcub
     C                   endif
     *
     *
     *   Use calculated cube if ...
     *      Recalculate option is 'Y'
     *
     C                   if        w3calc = 'Y'
     C                   eval      itcube = actcub
     C                   endif
     *
     C                   update    itrec
     C                   endif
740aA*  If Replace was requested remove all upc's for this item/uom
740aA /free
740aA   if w2upcar = 'R';
740aA     uomtype = 'N';
740aA     uomcode = itum1;
740aA     exsr UPCReplace;
740aA   endif;
740aA /end-free
     *  Update/Add UPC record.
415cAC                   if        w2upc <> *blanks
417a C     keyupc        chain     upc2                               79
     C                   if        not *in79
     C                   eval      upvitm = w2mfgc
     C                   update    uprec
     C                   else
     C                   eval      upwhse = w1whse
     C                   eval      upitem = w2item
     C                   eval      upupc = wkupc
     C                   eval      upven = 0
     C                   eval      upvnam = *blanks
     C                   eval      upvitm = w2mfgc
     C                   eval      upbran = *blanks
700bA * load new upc fields
700bA /free
700bA   upuom = itum1;
700bA   uputyp = 'N';
700bA   Select;
700bA     when ntype = 'UPC-12';
700bA       upctyp = '1';
700bA     when ntype = 'EAN-13';
700bA       upctyp = '2';
700bA     when ntype = 'GTIN';
700bA       upctyp = '3';
700bA     when ntype = 'SCC-14';
700bA       upctyp = '4';
700bA     when ntype = 'SSCC-18';
700bA       upctyp = '5';
700bA   endsl;
700bA /end-free
     C                   write     uprec
     C                   endif
415cAC                   endif
     *
510aMC                   exsr      scr04i
510aD*R                   EXSR SCR01I
     C                   endsr
510a *----------------------------------------------------------------
510a *
510a *  ZZUPD4   Update for screen 4.
510a *
510a C     zzupd4        begsr
510a C                   eval      error = *off
510a C                   eval      refrsh = *on
510a *
510a *  Update/Add ITEMDEF record.
510a C                   if        w4tie <> *zeros  and
510a C                             w4hi <> *zeros
510a C     keyid         chain     itemdef                            79
510a C                   if        not *in79
510a C                   z-add     w4tie         idtie
510a C                   eval      idhigh = w4hi
510a C                   update    idrec
510a C                   else
510a C                   eval      idwhse = w1whse
510a C                   eval      iditem = w2item
510a C                   eval      idsdef = slsdef
510a C                   z-add     w4tie         idtie
510a C                   eval      idhigh = w4hi
640bD**                   MOVE ITUM1     IDUM
540bMC                   eval      idum = 'N'
510a C                   eval      idpref = *blanks
510a C                   write     idrec
510a C                   endif
510a C                   endif
510a *
     *
640aMC                   exsr      scr05i
640aD*R                   EXSR SCR01I
510a C                   endsr
     *----------------------------------------------------------------
640aA*
640aA*  ZZUPD5   Update for screen 5.
640aA*
640aAC     zzupd5        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     *   Update ITEM FILE.
     *
     C                   if        w5swgt > *zeros
     C     keyit         chain     piritem                            79
     C                   if        not *in79
     C                   eval      itswgt = w5swgt
     C                   update    itrec
     C                   endif
     C                   endif
     *
     C                   exsr      scr01i
     C                   endsr
700aA*----------------------------------------------------------------
700aA*----------------------------------------------------------------
700aA*                     DRI SUBROUTINES
700aA*----------------------------------------------------------------
700aA*----------------------------------------------------------------

700aA*----------------------------------------------------------------
700aA*  clr$license  Clear $license data structure fields
700aA*----------------------------------------------------------------
700aA
700aAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C**                 eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
700aAC                   eval      $liTowhse = w1whse
700aAC                   eval      $liTowhseu = *on
     C                   endsr
700aA
700aA*----------------------------------------------------------------
700aA*  zzzdricop  Call DRICOP
700aA*----------------------------------------------------------------
700aA
700aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C*                  when      $dricommand = '*ITEM'
     C*                  eval      $dridata = $item
     C*                  eval      $dridata2 = $item2
700aAC                   when      $dricommand = '*LICENSE'
700aAC                   eval      $dridata = $license
700aAC                   eval      $dridata2 = $license2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
700aAC                             or $dricommand = '*LICENSE'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C*                  if        zmsflag
     C*                  exsr      zm0105s
     C*                  else
     C*                  exsr      zm0105
     C*                  endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C*                  if        zmsflag
     C*                  exsr      zm0001s
     C*                  else
     C*                  exsr      zm0001
     C***                exsr      zzerrind
     C*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
700aAC                   when      $dricommand = '*LICENSE'
700aAC                   eval      $license = $dridata
700aAC                   eval      $license2 = $dridata2
     C                   endsl

     C*                  eval      zmsflag = *off
     C*                  eval      chk4err = *off
     C     enddricop     endsr
     *
740aA*----------------------------------------------------------------
740aA*  GetCurrStamp  Get current timestamps
740aA*----------------------------------------------------------------

740aAp GetCurrStamp    b
740aAd GetCurrStamp    pi

740aA /free

740aA    getmicrotime(currstampuc:currstampsys);
740aA    ucOffset = %diff(currstampuc: currstampsys: *HOURS);
740aA    currstamploc = currstampsys + %hours(bfcoffset);

740aA /end-free

740aAp GetCurrStamp    e

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Dimensions
Slot
Recalculate
UPC
Warning: Invalid UPC. F10=Override. PgDn=More Info.
No item found. Scan new slot.
Tie/Hi
Shipping Weight
** DESCSP
Dimensiones
Slot
Recalcular
UPC
Aviso: UPC invalido. F10=Pasar sobre. PgDn=Mas Info.
No encontro producto. Escn slot nuevo.
Tie/Hi
Peso del envio
