      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  Note: IF PROGRAM CHANGES, MAKE CHANGES TO PO232 & PO200.
     *
     *  Note: The standard routine DSPSCR was modified for option
     *        *QUICK. This option bypasses displaying the screen
     *        and goes straight to checking the input fields. The
     *        screen will displayed if an error occurs.
     *
     *----------------------------------------------------------------
     *
     *  PO137     Directed PO receiving - GS1/UCI - Change
     *  01 October, 2012
     *  Lynn McMahon
     *  NOTES:
     *  Created using PO132, previous revision comments were removed.
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640  *    10/01/12  LMC  6.40
     *      - Created
640aA*    09/20/12  RH   6.40a
     *      - Enh: Change to use wk field to pass mfg shelf life days
     *        to allow use of other values to be used in calculations
640bA*    10/26/12  LMC  6.40b
     *      - Enh: If catch weight is retrieved from gs1 barcode do
     *        not perform weight edits
     *      - Enh: Disable quantity received not equal to quantity
     *        ordered warning, user is scanning one uci at a time.
     *      - Fix: Wrong indicator s/b *in75
640cA*    11/14/12  LMC  6.40c
     *      - Enh: handle upc check if gtin is not provided but a
     *      valid upc code was scanned in po120.
640dA*    11/15/12  LMC  6.40d
     *      - Fix: Lot warning override was not being seton for f20
640eA*    12/18/12  LMC  6.40e
     *      - Fix: Revised program to set W1EXDT, W1MFDT to zeros if
     *        return from MF200 returned with an error and the user
     *        had previously keyed an invalid date into the screen
     *        expiration or mfg date field.
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
650aA*    03/22/13  LMC  6.50a
     *      - Enh: Add logic for passing parms needed for haccp cross
     *      reference file.
650bA*    05/16/13  LMC  6.50b
     *      - Enh: Added RCVPO transaction.
650cA*    07/12/13  LMC  6.50c
     *      - Enh: Added logic to auto populate the UPC file with GTIN
     *      Rules: The GTIN number cannot already exist assigned to
     *      another item.
650dA*    06/19/13  LMC  6.50d
     *      - Enh: Added parm to pass GTIN for calculating PTI
     *      in PO136/PO236.
     *      - Enh: Add call to CALCPTI
     *      - Fix: Fix Different lot check
     *      NOTE: this enhancement needs to include Program CALCPTI
650eA*    07/16/13  LMC  6.50e
     *      - Enh: Changed display file to PO13701 to auto record
     *      advance on UCI scan.
650fA*    07/22/13  LMC  6.50f
     *      - Enh: Added additional checks for unique license.
     *      LICINFO and LICLOG records stay longer with new cleanup.
     *      We need to check LICLOG before we allow the user to
     *      reuse a license number.
650gA*    07/24/13  LMC  6.50g
     *      - Fix: Added additional edit to make sure GS1 barcode
     *      is scanned. Check to make sure GTIN is retrieved.
650hA*    07/31/13  LMC  6.50h
     *      - Enh: Added Catch weight override to exception processing
650iA*    08/06/13  LMC  6.50i
     *      - Fix: Clear saveqty when license is cancelled.
650jA*    08/06/13  LMC  6.50j
     *      - Enh: Additional logic to edit for upc from screen1.
     *      remove the check from screen2, since we are adding UPC
     *      records on the fly from gs1/uci scanning.
     *      - Added catch weight edits/overrides to screen3.
     *      - Renamed screen format from PO13701 to PO13702.
650kA*    08/13/13  LMC  6.50k
     *      - Enh: Add warning window requiring the user to press F12.
     *      This was added to lock the screen, so the user doesn't
     *      keep scanning, until they resolve the error.
     *      - Enh: Display file renamed to PO13703.
650lA*    09/23/13  LMC  6.50l
     *      - Fix: Lock on chain to POCTYPE, was causing error.
650mA*    11/06/13  LMC  6.50m
     *      - Enh: use production or pack data for manufactured date.
650nA*    10/07/13  LMC  6.50n
     *      - Fix: write pocwexcp everytime
650oA*    11/11/13  LMC  6.50o
     *      - Fix: ERLRNG & ERHRNG were being wiped out when the
     *        a tie/high error was issued, I was using those fields
     *        to write the POCWEXCP file, but when the tie/high error
     *        error occurred it clears the $mdt data structure losing
     *        the value of the fields for the write to the POCWEXCP
     *        file. Moving the value of those fields when they are
     *        populated on the warning to the fields in the POCWEXCP
     *        file to eliminate the dec data error that was occurring.
650pA*    01/16/14  LMC  6.50p
     *      - Fix: SC3 needs to exsr zzuhdr.
     *      - Clear moretoscan and firstuci upon completion of license
650qA*    01/27/14  LMC  6.50q
     *      - Enh: Added f8 to screen3 - for Ti/hi changes.
     *      - Fix: error window should not display on first scan
650rA*    01/29/14  LMC  6.50r
     *      - Enh: Added scanned qty to screen1.
     *      - Enh: Screen format changed to PO13705.
     *      - Enh: Add f20 override for new UPC being added to file
650sA*    03/07/14  LMC  6.50s
     *      - Enh: Added ability to process internal 99 gs1 barcodes
     *      - Fix: Clear saved weight field on license completion.
650tA*    03/10/14  LMC  6.50t
     *      - Enh: Added preferred slot definition to screen display
     *        Renamed screen format from PO13705 to PO13706
650vA*    05/13/14  LMC  6.50v
     *      - Enh: Pass Vendor number to CVTBAR.
     *
650wA*    06/09/14  LMC  6.50w
     *        Pass new blank oss parm to PO236.                       d,
650xA*    07/07/14  LMC  6.50x
     *      - Fix: Do not allow entry of special characters in license
     *             entry field.
650yA*    09/26/14  LMC  6.50y
     *      - Enh: If w1dwgt > 0 need to set cwcalc to 1, in order to
     *             load total weights to the poddtl file, even if
     *             Force CW entry is N and Allow catch weight entry
     *             is never. Weights came from GS1 scanning and should
     *             be updated into the PODTL file.
700aA*    11/11/15  LMC  7.00a
     *      - Fix: left adjust uci scanned. Caused a problem with bulke
     *        uci selection weights.
     *
700bA*    11/23/15  LMC  7.00b
     *      - Enh: Pick slot receiving with uci receiving.
     *        handled similar to cross dock.
     *
700cA*    04/07/16  LMC  7.00c
     *      - Enh: Adding logic for Metric.
700dA*    09/30/16  LMC  7.00d
     *      - Enh: Adding New screen for capturing breakdown UPC.
     *        This screen will display after the verifcation screen.
     *        Since UCI scanning needs to be done before we ask a user
     *        to open a case to scan a breakdown upc.
     *        Don't want to break their uci scanning flow.
710aA*    05/02/17  LMC  7.10a
     *      - Fix - Need to check to make sure old LICINFO record
     *        doesn't exist.
720aA*    07/28/16  LMC  7.20a
     *      - Enh: UCI Tracking.
720bA*    11/28/18  LMC  7.20b
     *      - Fix: When moretoscan is turned on , turn on *in80
     *             otherwise the license edits take place again
     *             and they should only execute on the first time.
740a *    05/22/20  LMC  7.40a
     *      - Enh: Send Vendor to all calls of CVTBAR so that the
     *        new decipher barcode process works.
     *
770aA*   08/27/22  TDC  7.70a
     *      - DockVue: Added update of POSTATUS table when the PO is
     *        updated.
     *      - Added check for the dockvue system option (opdckv)
     *----------------------------------------------------------------
     * YHata's Custom Mods
     *   09/20/12  RH   YHAa
     *     - Calculate pack date for Date senstitive only item using  tion
     *       # of days out - 1. Store in LICINFO code *MFGDTE         tion
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Westside Custom Mods
WSTa *   11/04/13  LMC  WSTa
     *     - Mod 650k is now conditioned for westside only
WSTb *   03/17/14  LMC  WSTb
     *     - Load the earliest prod/pack date from the UCI scan to
     *     wofifo date field
WSTc *   07/08/14  LMC  WSTc
     *     - If date is zero ignore, and use received date.
WSTd *   09/24/14  LMC  WSTd
     *     - If an invalid date is returned do not consider that date
     *     for setting the license date.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  55        Enable function key F17
     *  66        Date Code Decipher check to non display cmd11
     *  88        Lot code entry not allowed. Hide fields.
     *  89        FIFO entered date entry not allowed. Hide fields.
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  File Specs
     *
650eDF*po137fm   cf   e             workstn
650jDF*po13701   cf   e             workstn
650kDF*po13702   cf   e             workstn
650qDF*po13703   cf   e             workstn
650rDF*po13704   cf   e             workstn
650tDF*po13705   cf   e             workstn
700cDF*po13706   cf   e             workstn
700dDF*po13707   cf   e             workstn
700dMFpo13708   cf   e             workstn
     F                                     infds(infds)
     Fpodtl     if   e           k disk
     F                                     rename(pdrec:record)
     Fpoexcp    if   e           k disk
     Fpohdr     uf   e           k disk
     Fwarehs    if   e           k disk
     Funmesr    if   e           k disk
     Foptions   if   e           k disk
     Fupc3      uf a e           k disk
     Fupc2      if   e           k disk    rename(uprec:u2rec)
     Fupc1      if   e           k disk
     F                                     rename(uprec:u1rec)
650cAFupc       if   e           k disk
650cAF                                     rename(uprec:uprecp)
     Fslot2     if   e           k disk
     F                                     rename(slrec:s2rec)
     FLabel2    if   e           k disk
     Fpoctype   uf a e           k disk
     Fpovpck    if   e           k disk
     Fpomfr     o    e             disk
     Fporcv     o  a e           k disk
     Fitmexcp   o    e           k disk
     Fpofifo    o    e           k disk
650hAFpocwexcp  uf a e           k disk    Prefix(cw_) rename(exrec:cwexrec)
770aA*----------------------------------------------------------------
770aA*  Standard SQL variables and constants
770aA*----------------------------------------------------------------
770aA
770aA /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#XDOCK
      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO
     D saveVer#        s                   like($slver#)
     *----------------------------------------------------------------
     *  Convert Barcode Parms
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D a13             s              1    dim(13)
     D desc            s             20    dim(16) ctdata perrcd(1)
     D lbl             s             13    dim(4) ctdata perrcd(1)
     D typ             s             10    dim(1) ctdata perrcd(1)
     D cwt             s             27    dim(3) ctdata perrcd(1)
700dDD*cmdln           s             79    dim(9) ctdata perrcd(1)
700dMD cmdln           s             79    dim(10) ctdata perrcd(1)
650aAD $parms1         s             48    dim(20)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#jordano
      /copy qcopysrc,id#saval
YHAaA /copy qcopysrc,id#yhata
WSTaA /copy qcopysrc,id#westsid

     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
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
     D  $ppo                  22     30
     D  $pseq                 31     35  0
     D  $pitem                36     50
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D                 ds
     D  dspo                   1      9
     D  dslbl                 10     16  0
     D  dsexpd                17     24  0
     D  dsfdis                 1     12
     D  dstdis                13     24
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Constants
     D move1           c                   const('MOVEIN PICK')
     D move2           c                   const('MOVEIN OVERFLOW')
650xA*----------------------------------------------------------------
650xA*  Name constants
650xA*
650xAD valid           c                   const('0123456789 ABCDEFGHI-
650xAD                                     JKLMNOPQRSTUVWXYZabc-
650xAD                                     defghijklmnopqrstuvw-
650xAD                                     xyz')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getsi          c                   const('GETSLOTITM')
     D @fmtit          c                   const('FRMTIT')
650bAD @crtrcv         c                   const('CRTRCVTRN')
     *----------------------------------------------------------------
     *  Called program parameters
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
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *   Redefine key
     D  $lwhse                19     21  0
     D  $litem                22     36
     D  $lpo                  37     45
     D  $lrq1                 46     50  0
     D  $lrq2                 51     55  0
     D  $lrq3                 56     60  0
     D  $lrpal                61     63  0
     D  $llott                64     64
     D  $llict                65     65
     *
     D  $lwhs2                19     21  0
     D  $lwhd2                22     26
     D  $litm2                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lst                  59     60
     D  $lsdef                61     62
     D  $lactv                63     64
     *
     D  $lwhs3                19     20p 0
     D  $lpo3                 21     29
     D  $lseq                 30     32p 0
     D  $litm3                33     47
     D  $lqyr1                48     50p 0
     D  $lqyr2                51     53p 0
     D  $lqyr3                54     56p 0
     D  $lcwte                57     59p 0
     D  $lcwtt                60     64p 2
     D  $lcwta                65     68p 2
     *
     D  $llot                 37     37
     D  $lltrk                38     38
     *
     D  $lmfr#                22     32  0
     D  $lmfritem             33     47
     D  $ldakitem             48     62
     *
     *----------------------------------------------------------------
     *  Working fields.
     *
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     78
     *
     D  erwhse                 1      2p 0
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritm                  1     15
     D  erco#                 16     19p 0
     *
     D  erdisp                16     27
     *
     D  ermday                 1      2p 0
     D  ermfdt                 3      6p 0
     D  erexdt                 7     10p 0
     D  erltst                11     14p 0
     D  erdday                15     16p 0
     D  eruday                17     18p 0
     *
     D  erused                 1      4p 0
     D  erdisd                 5      6p 0
     D  erusrd                 7      8p 0
     D  ersell                 9     12p 0
     *
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     *
     D  erentd                 1      5p 0
     D  ertod                  6     10p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     * Data structure
     *
     *    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
     *    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
     *    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
     *
     D opdata          ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
770aAD  opdckv                50     50
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
     D  optend               117    117
     D  oplpgm                 1     10
     D  opupct                11     13  0
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
     D  opplcn                23     23
     D  opexck                28     28
     D  opcwen                29     29
     D  opcwtp                30     30
     D  opcwfr                31     31
     D  opipck                32     32
     D  oprupc                33     33
     D  oprups                34     34
     D  oprupf                35     35
     *  *SYSTEM  -  System options.
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
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
      /COPY *libl/qcopysrc,C#PGMINFDS
     *----------------------------------------------------------------
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

     *------------------------------------------------------------------
     * CLCDUR2 parameters
     *------------------------------------------------------------------

     D $cdcmd          s              8

     D $cddatein       s              8  0
     D $cdtimein       s              6  0

     D $cdyears        s              3  0
     D $cdmonths       s              3  0
     D $cddays         s              3  0
     D $cdhours        s              3  0
     D $cdminutes      s              3  0
     D $cdseconds      s              3  0

     D $cddateOut      s              8  0
     D $cdtimeOut      s              6  0

     *----------------------------------------------------------------
     *  Variables
     *
     D $ldwgt          s              9  2
     D $lflag          s              1
     D $lord           s              7  0
     D $lum1           s              5
     D $lum2           s              5
     D $lum3           s              5
     D $lven           s             11  0
     D $lvitm          s             15
     D $lvnam          s             40
     D $msgf           s             10
650dAD $pw1pti         s              4  0
     D $unext          s             13  0
650dAD $pbcProdD       s              6  0
     D #bsu1           s              5
     D #bsu2           s              5
     D #bsu3           s              5
     D #msgid          s              7
     D #msgtp          s              7
     D #odesc          s             30
     D #oitem          s             15
     D #opdsc          s             15
     D #osu1           s              5
     D #osu2           s              5
     D #osu3           s              5
     D #oswgt          s              7  2
     D #oswt2          s              7  2
     D #oswt3          s              7  2
     D #otype          s              1
     D #oum1           s              2
     D #oum2           s              2
     D #oum2q          s              3  0
     D #oum3           s              2
     D #oum3q          s              3  0
     D avgwt1          s              7  2
     D avgwt2          s              7  2
     D avgwt3          s              7  2
700dAD b1type          s              7
700dAD b2type          s              7
700dAD b1upc           s                   like(upupc)
700dAD b2upc           s                   like(upupc)
640d D*chk4err         s               n
640dDD*ck4err          s              1
640dMD ck4err          s               n
     D ckupc           s                   like(w1upc)
     D ckexdt          s              8  0
     D clear           s              5  0
     D cmdtkn          s              1
     D CnvWgt          s              9  2
     D comand          s              5  0
     D cwcalc          s              1  0
     D cwovr           s              1
     D date1           s              8  0
     D date16          s              6  0
     D date2           s              8  0
     D date2o          s              6  0
     D date26          s              6  0
     D ddcode          s              1
     D difflot         s               n
     D diffexpd        s               n
770aAD dockvue         s              1n   inz('0')
     D done            s              1
     D dtchk           s              1
     D dtchk2          s              1
     D dtchk3          s              1
     D dtchk4          s              1
     D dtfrmt          s              1  0
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D error           s               n
     D exdtj           s              5  0
     D expd            s              8  0
     D expdj           s              5  0
     D expdwarn        s              1
     D expdovr         s              1
     D exwgt           s              9  2
     D firstuci        s              1
     D firstlot#       s                   like($lnlot)
     D*firstMfrDt      s                   like($lnmfgdate)
     D firstDKtExpDt   s                   like($lnexpdate)
     D*firstMfrExpDt   s                   like($lnmfgexp)
     D*firstGTIN       s                   like($gsGTIN)
     D forevr          s              1
     D full            s              1
     D g$date          s              6  0
     D g$dd            s              2  0
     D g$dw            s              1  0
     D g$jd            s              5  0
     D g$jyd           s              7  0
     D g$mm            s              2  0
     D g$mmwk          s              2  0
     D g$wk7           s              7  0
     D g$yy            s              2  0
     D g$yywk          s              3  0
     D g$yyyy          s              4  0
     D gmwksv          s              2  0
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
     D hvskp           s              1
     D iaflag          s              1
     D iatest          s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D j$date          s              6  0
     D j$dd            s              2  0
     D j$jd            s              5  0
     D j$md            s              3  0
     D j$mm            s              2  0
     D j$tst           s              9  9
     D j$x             s              2  0
     D j$yd            s              7  0
     D j$yywk          s              3  0
     D j$yyyy          s              4  0
     D jdobread        s               n
     D kgs2lbs         c                   2.20462262
     D KiloLbs         s              1
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D kyven#          s             10  0
     D kywhdp          s                   like(slwhdp)
     D lastseq         s                   like($lnseq)
     D lcnsExists      s               n
     D lflag           s              1
     D licinfoupd      s               n
     D lotwarn         s              1
     D lotovr          s              1
     D ltstd6          s              6  0
     D ltstd8          s              8  0
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D mfdtj           s              5  0
     D mfgd            s              8  0
     D mexpd           s              8  0
     D mfgdte          s              8  0
700dAD Needb1          s               n
700dAD Needb2          s               n
700dAD Ntype           s              7
     D moretoscan      s              1
770aAD nostamp         s               z     inz
     D noupc           s              1
     D nxtscr          s              3
     D ocode           s              8
     D oaovr           s              1
     D obovr           s              1
     D ocovr           s              1
     D odovr           s              1
     D oeovr           s              1
     D ofovr           s              1
     D ovrrid          s              1
     D part            s              1
650bAD poppcs          s                   like($lpcs)
650dAd pplot           s             20
650dAd pppti           s              4  0
     D prg1c           s              4  3
     D prg2c           s              4  3
     D qtchk           s              1
     D rcverr          s                   like(error)
650bAD rcvpocomplete   s               n
     D recv            s              1
     D rolldn          s              5  0
     D rollup          s              5  0
WSTbAD savewstfifo     s              8  0
WSTbAD wstfifo         s              8  0
     D savew1mfdt      s                   like(w1mfdt)
     D savew1exdt      s                   like(w1exdt)
650kAD savew1uci       s                   like(w1uci)
     D saveexpd        s                   like(expd)
     D savelotc        s                   like(w1lotc)
650kAD savenxtscr      s                   like(nxtscr)
     D savewgt         s                   like(w1dwgt)
     D saveqty         s                   like(sdqrc1)
     D sclear          s              1
     D sdqrc1          s              5  0
     D sdqrc2          s              5  0
     D sdqrc3          s              5  0
     D sprcv           s              1
     D ssbflg          s              1
     D stop            s              1
     D svcwen          s              1
     D svcwfr          s              1
     D svcwtp          s              1
     D svdwgt          s              9  2
     D svexck          s              1
     D svexdt          s              6  0
     D svhi            s              2  0
650tAD svsdef          s              2
     D svmfdt          s              6  0
700cAD svopwum         s                   like(opwum)
     D svqrc1          s                   like(pdqrc1)
     D svqrc2          s                   like(pdqrc2)
     D svqrc3          s                   like(pdqrc3)
     D svrupc          s              1
     D svtie           s              4  0
     D svupc           s             50
     D t               s              1  0
     D temp10          s             10
     D templcns        s             15
     D tmpwgt          s              9  2
     D today           s              8  0
     D todayo          s              6  0
     D todyj           s              5  0
     D upchk           s              1
     D upchk2          s              1
     D uxflag          s              1
     D vrfycw          s              1
     D uciexists       s               n
650rAD UPCwarn         s              1
650rAD UPCovr          s              1
     D unexta          s             13
     D warn            s              1
     D whse            s              3  0
640aAD wkmday          s              3  0
     D wkwhse          s                   like($pwhse)
     D wodisp          s             12
     D woexdt          s              8  0
     D wofifo          s              8  0
     D woindt          s              8  0
     D womfdt          s              8  0
     D work2           s              2
     D work4           s              4
     D wotcw           s              9  2
700dAD Writeb1         s               n
700dAD Writeb2         s               n
     D wrttyp          s              1
     D wtchk           s              1
     D w1item          s             15
     D w1upc           s                   like(upupc)
     D zmflag          s               n
     D zmsflag         s               n
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D ucilic#         pr                  extpgm('UCILIC#')
      * Input
     D   unext                       13  0 const
     D   uwhse                        3  0 const
650dAD calcpti         pr                  extpgm('CALCPTI')
650dA * Input
650dAD   pGTIN                             like($bcgtin)
650dAD   pLOT                              like(pplot)
650dAD   pPackDate                         like($pmfgdt)
650dAD   pPTI                              like(pppti)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *              *QUICK   - Quick receive
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
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
     C                   parm                    $pupc            20
     C                   parm                    $prsqt            7 0
     c                   parm                    $pexpdt           6 0
     c                   parm                    $pwgt            11 3
     c                   parm                    $pmfgdt           6 0
     c                   parm                    $plot            20
     c                   parm                    $plpn            50
     c                   parm                    $puci           100
     c                   parm                    $pxd              2
650aAc                   parm                    $parms1
650bAC                   parm                    $lsavetrn         7 0
     *                    PARM           $PDEV  10
     *                    PARM           $PFORM 10
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
650bAc                   eval      rcvpocomplete = *off
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
700dAC     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     'CNL'         sccnl
650kAC     nxtscr        caseq     'ERR'         scerr
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
650bA*
650bA*   check to see if po receipt is completed
650bA*   if completed update label/transaction with qty information
650bA*   else just mark them closed. - ended and closed dates
650bAC                   exsr      zzrcvpoclose
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     C     $pcmd         cabeq     '*QUICK  '    skpdsp
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
     c                   if        nxtscr = '01 '
      * if uci scan was passed in from another program don't display screen1
      * unless error occurs
     c                   select
     c
     c                   when      error = *on
     c                   if        moretoscan = *on
     C                   eval      cmdln2 = cmdln(8)
     c                   endif
     c                   write     cmdrec
     C                   exfmt     screen1                              50

     c                   when      moretoscan = *on
     c                   eval      w1lhdg = 'Scan Next UCI Label:'
     C                   eval      cmdln2 = cmdln(8)
     c                   write     cmdrec
     C                   exfmt     screen1                              50

     c                   when      $puci <> ' ' and firstuci <> *on
     c                   eval      w1uci = $puci
     c                   eval      firstuci = *on
     c                   eval      w1lhdg = 'Scan Next UCI Label:'
     c*                  write     cmdrec
     C*                  exfmt     screen1                              50

     c                   when      $puci = ' ' and firstuci <> *on
     c                   eval      w1uci = ' '
     c                   eval      firstuci = *on
     c                   eval      w1lhdg = 'Scan First UCI Label:'
     c                   if        moretoscan = *on
     C                   eval      cmdln2 = cmdln(8)
     c                   endif
     C                   write     cmdrec
     C                   exfmt     screen1                              50
650cAc                   other
650cAc                   write     cmdrec
650cAc                   exfmt     screen1

     c                   endsl
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   eval      cmdln2 = cmdln(7)
     c                   if        error = '1' or
     c                             warn = '1'  or
     c                             cmdtkn = *on
     C                   write     cmdrec
     C                   exfmt     screen2                              50
     c                   endif
     C                   endif
     *
     C                   if        nxtscr = '03 '
     C                   eval      cmdln2 = cmdln(9)
     C                   write     cmdrec
     C                   exfmt     screen3                              50
     C                   endif

700dAC                   if        nxtscr = '04 '
700dAC                   write     cmdrec
700dAC                   exfmt     screen4                              50
700dAC                   endif
     C                   if        nxtscr = 'CNL'
     c                   exfmt     cnlwdw                               50
     C                   endif
     *
WSTaAC                   if        client = westside
650kAC                   if        nxtscr = 'ERR'
650kAc                   exfmt     errwdw                               50
650kAc                   leavesr
650kAC                   endif
WSTaAC                   endif
     *
     C     skpdsp        tag
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       10
     C                   setoff                                       111213
     C                   setoff                                       1415
700dAC                   setoff                                       1718
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       616263
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcpmq
     *
     C                   if        $pcmd = '*QUICK  '
     C                   eval      $pcmd = '*CHANGE '
     C                   endif
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
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzget2
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     *     Setup converted weight field.
     C                   exsr      zzcnvwgt
     C                   exsr      zzchk2
      * is this the first uci label scanned, if so need license entry
     c                   if        moretoscan = *on
     c                   eval      *in80 = *on
     c                   eval      *in15 = *off
650kA /free
WSTaA    if client = westside;
650kA      if error = *on and w1uci <> savew1uci;
650kA        savew1uci = w1uci;
650kA        savenxtscr = nxtscr;
650kA        nxtscr = 'ERR';
650kA      endif;
WSTaA    endif;
650kA /end-free
     c                   else
     c                   eval      *in80 = *off
     c                   if        $pxd = 'XD'
700bAc                             or sprcv = *on
     c                   eval      *in15 = *off
650kA /free
WSTaA    if client = westside;
650kA      if error = *on and w1uci <> savew1uci;
650kA        savew1uci = w1uci;
650kA        savenxtscr = nxtscr;
650kA        nxtscr = 'ERR';
650kA      endif;
WSTaA    endif;
650kA /end-free
     c                   else
     c                   eval      *in15 = *on
     c                   endif
     c                   endif
     C                   endif
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     c                   eval      w1mfdt = savew1mfdt
     c                   eval      w1exdt = savew1exdt
     c                   eval      expd   = saveexpd
     c                   eval      w1lotc = savelotc
     c                   eval      w1dwgt = savewgt
650jAc                   eval      svdwgt = 0
720aAc                   select
720aAc                   when      uputyp = 'N'
     c                   eval      w1qrc1 = saveqty
720aAc                   when      uputyp = '1'
720aAc                   eval      w1qrc2 = saveqty
720aAc                   when      uputyp = '2'
720aAc                   eval      w1qrc3 = saveqty
720aAc                   endsl
     c                   eval      w1avg = 'N'
700cA /free
700cA   select;
700cA     when svopwum = 'KGS'
700cA      or svopwum = 'kgs'
700cA      or svopwum = 'Kgs';
700cA       KiloLbs = 'K';
700cA       W1KgLb  = svopwum;
700cA     other;
700cA       KiloLbs = 'P';
700cA       W1KgLb  = 'Lbs';
700cA   endsl;
700cA   exsr setupcmdln1;
700cA /end-free

WSTbAC                   if        client = westside
WSTbAc                   if        $itflgd <> 'Y'
WSTbAc                   eval      wofifo = savewstfifo
WSTbAC                   endif
WSTbAC                   endif
     C     end03i        endsr
700dA*----------------------------------------------------------------
700dA*
700dA*  Screen 04  initialization
700dA*
700dAC     scr04i        begsr
700dA*
700dA*  This screen will get initiated if receiving options to
700dA*  capture upc's for breakdown is turned on.
700dA*
700dA*  We will display the screen4  if the item has breakdowns
700dA*  defined, and we do not have a UPC record for the breakdown uom
700dA*
700dA /free
700dA   writeb1 = *off;
700dA   writeb2 = *off;
700dA   w1buom1 = ' ';
700dA   w1bupc1 = ' ';
700dA   w1buom2 = ' ';
700dA   w1bupc2 = ' ';
700dA   *in17 = *off;
700dA   *in18 = *off;
700dA   // breakdown 1 is setup on item
700dA   if $itum2 <> ' ';
700dA     Needb1  = *on;
700dA     // do we have a upc loaded for this breakdown uom
700dA     setll ($pwhse: $pitem) upc1;
700dA     dow forevr = forevr;
700dA       reade ($pwhse: $pitem) upc1;
700dA       if %eof(upc1);
700dA         leave;
700dA       endif;
700dA       if upuom = $itum2;
700dA         needb1  = *off;
700dA         leave;
700dA       endif;
700dA     enddo;
700dA   endif;
700dA   // breakdown 2 is setup on item
700dA   if $itum3 <> ' ';
700dA     Needb2  = *on;
700dA     // do we have a upc loaded for this breakdown uom
700dA     setll ($pwhse: $pitem) upc1;
700dA     dow forevr = forevr;
700dA       reade ($pwhse: $pitem) upc1;
700dA       if %eof(upc1);
700dA         leave;
700dA       endif;
700dA       if upuom = $itum3;
700dA         needb2  = *off;
700dA         leave;
700dA       endif;
700dA     enddo;
700dA   endif;
700dA   // need to capture a breakdown upc
700dA   if needb1 = *on or needb2 = *on;
700dA     nxtscr = '04 ';
700dA     exsr zzdft4;
700dA   else;
700dA     wolbl = *blanks;
700dA     woitem = *blanks;
700dA     wodsc1 = *blanks;
700dA     wodsc2 = *blanks;
700dA   endif;
700dA /end-free
700dAC     end04i        endsr
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
     C                   if        moretoscan = *on
     c                   eval      nxtscr = 'CNL'
     C                   goto      endsc1
     c                   endif
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     *
     *   Remove any existing catchweight entry records.
     C                   if        $itcwgt = 'Y'
     C                             or $itcwgt = 'S'
     C                   exsr      zzdlcw
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   if        moretoscan = *on
     c                   eval      nxtscr = 'CNL'
     C                   goto      endsc1
     c                   endif
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     *
     *   Remove any existing catchweight entry records.
     C                   if        $itcwgt = 'Y'
     C                             or $itcwgt = 'S'
     C                   exsr      zzdlcw
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
650kA /free
WSTaA    if client = westside;
650kA        if error = *on;
650kA          savenxtscr = nxtscr;
650kA          nxtscr = 'ERR';
650kA        endif;
WSTaA    endif;
650kA /end-free
     C     error         cabeq     *on           endsc1
     c                   eval      ovrrid = *off
     C                   endif
     c                   if        moretoscan = *on or
     c                             firstuci = *on
     c                   exsr      scr02i
WSTaAc                   if        client = westside
WSTaAc                   else
650kDC*                  eval      nxtscr = '02 '
WSTaDC                   eval      nxtscr = '02 '
WSTaAc                   endif
     c                   endif
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
     C                   if        moretoscan = *on
     c                   eval      nxtscr = 'CNL'
     C                   goto      endsc2
     c                   endif
     C     *loval        setll     record
     C                   eval      nxtscr = '01 '
     C                   eval      $prtn = '*CANCEL '
     C                   eval      lotwarn = *off
650rAC                   eval      UPCwarn = *off
     C                   eval      expdwarn = *off
     C                   eval      lotovr  = *off
650rAC                   eval      UPCovr  = *off
     C                   eval      expdovr  = *off
     *   Remove any existing catchweight entry records.
     C                   if        $itcwgt = 'Y'
     C                             or $itcwgt = 'S'
     C                   exsr      zzdlcw
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = '01 '
     C                   eval      $prtn = '*CANCEL '
     C                   eval      lotwarn = *off
650rAC                   eval      UPCwarn = *off
     C                   eval      expdwarn = *off
     C                   eval      lotovr  = *off
650rAC                   eval      UPCovr  = *off
     C                   eval      expdovr  = *off
     *   Remove any existing catchweight entry records.
     C                   if        $itcwgt = 'Y'
     C                             or $itcwgt = 'S'
     C                   exsr      zzdlcw
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     *     Setup converted weight field.
     C                   exsr      zzcnvwgt
     C                   exsr      zzchk2
650kA /free
WSTaA    if client = westside;
650qA      if moretoscan = *on;
650kA        if error = *on and w1uci <> savew1uci;
650kA          savew1uci = w1uci;
650kA          savenxtscr = nxtscr;
650kA          nxtscr = 'ERR';
650kA        endif;
650qA      endif;
WSTaA    endif;
650kA /end-free
     C     error         cabeq     *on           endsc2
     c                   exsr      zzuci
     C                   endif
     c                   if        moretoscan = *off
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *  Test for F3 - Not allowed - do nothing
     *
     C                   if        *inkc
     C                   if        moretoscan = *on
     c                   eval      nxtscr = 'CNL'
     C                   goto      endsc3
     c                   endif
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = '01 '
     C                   goto      endsc3
     C                   endif
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     *     Setup converted weight field.
     C                   exsr      zzcnvwgt
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     $lrtn         cabeq     '*CANCEL'     endsc3
     C     error         cabeq     *on           endsc3
     C                   endif
650pAC                   exsr      zzuhdr
     C                   eval      nxtscr = 'EOJ'
     c                   eval      $pexpdt = 0
     c                   eval      $pwgt = 0
     c                   eval      $pmfgdt = 0
     c                   eval      $plot = ' '
WSTbAc                   eval      savewstfifo = 0
WSTbAc                   eval      wstfifo = 0
700dAC                   if        $ifrcvmth = '3' and $ittype = ' '
700dAc                   exsr      scr04i
700dAc                   endif
     C     endsc3        endsr
700dA*----------------------------------------------------------------
700dA*
700dA*  SC4  -  Screen 4
700dA*
700dAC     sc4           begsr
700dA*
700dA*  Test for F3 - Exit
700dA*
700daC                   if        *inkc
700dAC     *loval        setll     record
700dAC                   eval      nxtscr = 'EOJ'
700dAC                   eval      $prtn = '*EXIT   '
700dAC                   goto      endsc4
700dAC                   endif
700dA*
700dA*  Test for F5 - Refresh
700dA*
700dAC                   if        *inke
700dAC                   if        $pcmd <> '*VIEW   '
700dAC                   exsr      scr04i
700dAC                   endif
700dAC                   goto      endsc4
700dAC                   endif
700dA*
700dA*  Test for F12 - Previous
700dA*
700dAC                   if        *inkl
700dAC     *loval        setll     record
700dAC                   eval      nxtscr = 'EOJ'
700dAC                   eval      $prtn = '*CANCEL '
700dAC                   goto      endsc4
700dAC                   endif
700dA*  Test for F9  - skip
700dA*
700dAC                   if        *inki
700dAC     *loval        setll     record
700dAC                   eval      nxtscr = 'EOJ'
700dAC                   eval      wolbl = *blanks
700dAC                   eval      woitem = *blanks
700dAC                   eval      wodsc1 = *blanks
700dAC                   eval      wodsc2 = *blanks
700dAc                   eval      $prtn = ' '
700dAC                   goto      endsc4
700dAC                   endif
700dA*
700dA*  Test for other command keys
700dA*
700dAC                   exsr      zzcmd4
700dAC     cmdtkn        cabeq     *on           endsc4
700dA*
700dA*  Some other key pressed.
700dA*
700dA*     Check input and write/update record.
700dA*
700dAC                   if        $pcmd = '*ADD    '  or
700dAC                             $pcmd = '*CHANGE '
700dA
700dAC                   exsr      zzchk4
700dAC     error         cabeq     *on           endsc4
700dAC                   exsr      zzupd4
700dAC     error         cabeq     *on           endsc4
700dAC                   endif
700dA*
700dAC                   eval      nxtscr = 'EOJ'
700dAC     endsc4        endsr
     *----------------------------------------------------------------
     *
     *  SCCNL-  Cancel Warning Window
     *
     C     scCnl         begsr
     *
     *  Test for F12 - Previous
     *
      /free
        if *inkl;
          nxtscr = '01 ';
          leavesr;
        endif;

      /end-free
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmdcnl
     C     cmdtkn        cabeq     *on           endsccnl
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzupdcnl
     c                   if        *inkj
     C                   eval      nxtscr = 'EOJ'
     c                   endif
     C     endsccnl      endsr
650kA*----------------------------------------------------------------
650kA*
650kA*  SCERR-  Error Warning Window
650kA*
650kAC     scErr         begsr
650kA*
650kA*  Test for F12 - Acknowledge Error
650kA*
650kA /free
650kA   if *inkl;
650kA     nxtscr = savenxtscr;
650kA     leavesr;
650kA   endif;
650kA
650kA /end-free
650kA*
650kA*  Some other key pressed.
650kA*
650kA*     Check input and write/update record.
650kA*
650kAC     endscerr      endsr
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
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr
     *----------------------------------------------------------------
     *  GETITEM      Get item info from driitem
     *----------------------------------------------------------------
      /free
        begsr getitem;
          exsr clr$item;

          $itWhse = $pwhse;
          $ititem = $pitem;

          $dricommand = '*ITEM';
          $drisubcmd  = '%GETALL';
          $drisys2upd = 'D';
          ck4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
          if error = *on;
            *in75 = *on;
          endif;
        endsr;
      /end-free

     *----------------------------------------------------------------
     *
     * ************ DO NOT USE  -  USE CLCDUR2 INSTEAD **************
     *                                                                   DOC
     C     gtoj$         begsr
     C                   eval      g$date = g$date
     * SPLIT DATE INTO MONTH, DAY, YEAR FIELDS
     C                   if        dtfrmt = 1
     C                   movel     g$date        g$yy
     C                   move      g$date        work4
     C                   movel     work4         g$mm
     C                   move      work4         g$dd
     C                   else
     C                   movel     g$date        g$mm
     C                   move      g$date        work4
     C                   movel     work4         g$dd
     C                   move      work4         g$yy
     C                   endif
     * CREATE 4 DIGIT YEAR
     C                   move      g$yy          g$yyyy
     C                   if        g$yy >= 60
     C                   movel     '19'          g$yyyy
     C                   else
     C                   movel     '20'          g$yyyy
     C                   endif
     C                   eval      g$jd = 0
     C                   eval      g$mmwk = g$mm - 3
     C                   eval      gmwksv = g$mmwk
     C                   if        g$mmwk < 0
     C                   add       12            g$mmwk
     C                   endif
     C                   if        gmwksv <> 0
     C                   eval(h)   g$jd = g$mmwk * 30.6
     C                   endif
     C                   add       g$dd          g$jd
     C     g$yyyy        sub       1900          g$yywk
     C                   if        g$yywk <> 0
     C                   if        gmwksv < 0
     C                   eval      g$yywk = g$yywk - 1
     C                   endif
     C                   endif
     C                   eval      g$jyd = g$yywk * 365.25
     C                   add       g$jyd         g$jd
     C     g$jd          div       7             g$wk7
     C                   mvr                     g$dw
     C                   endsr
     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #curruser
     C                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr

     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = $emp#
     C                   eval      $uiaddusr = #curruser
     C                   eval      $uiaddpgm  = #pgm
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobnbr
     C                   endsr

700cA*----------------------------------------------------------------
700cA*  setupcmdln1  Setup command line 1
700cA*----------------------------------------------------------------
700cA
700cAC     setupcmdln1   begsr
700cAC                   select
700cA*
700cAC                   when      $itcwgt <> 'N' and $itflgd = 'Y'
700cAc                             and KiloLbs = 'P'
700cAC                   eval      cmdln1 = cmdln(1)
700cA*
700cAc                   when      $itcwgt <> 'N' and $itflgd = 'Y'
700cAc                             and KiloLbs = 'K'
700cAC                   eval      cmdln1 = cmdln(2)
700cA*
700cAC                   when      $itcwgt <> 'N' and $itflgd = 'N'
700cAc                             and KiloLbs = 'P'
700cAC                   eval      cmdln1 = cmdln(3)
700cA*
700cAc                   when      $itcwgt <> 'N' and $itflgd = 'N'
700cAc                             and KiloLbs = 'K'
700cAC                   eval      cmdln1 = cmdln(4)
700cA*
700cAC                   when      $itcwgt = 'N' and $itflgd = 'Y'
700cAC                   eval      cmdln1 = cmdln(5)
700cA*
700cAC                   when      $itcwgt = 'N' and $itflgd = 'N'
700cAC                   eval      cmdln1 = cmdln(6)
700cA*
700cAC                   endsl
700cAc                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   write     msgctl
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
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
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

     *   PIR0105  Invalid slot entered.
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR0105  General message sent back to calling program.
     *
     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ'
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
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
650xA*----------------------------------------------------------------
650xA*   PIR1001  Invalid value entered.
650xA*
650xAC     zm1001        begsr
650xAC                   eval      #msgid = 'PIR1001'
650xAC                   eval      #msgtp = '*DIAG  '
650xAC                   movea     errmsg        $md(1)
650xAC                   exsr      zmpmsg
650xAC                   endsr
     *----------------------------------------------------------------
     *    PIR1008  Date is required.
     *
     C     zm1008        begsr
     C                   eval      #msgid = 'PIR1008'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1009  Date must be > today's date.
     *
     C     zm1009        begsr
     C                   eval      #msgid = 'PIR1009'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1010  Date must be <OR= today's date.
     *
     C     zm1010        begsr
     C                   eval      #msgid = 'PIR1010'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    ZM13250  Item not date sensitive.
     *
     C     zm13250       begsr
     C                   eval      #msgid = 'PO13250'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9999  Generic message - length 78 chars.
     *
     C     zm9999        begsr
     C                   eval      #msgid = 'PIR9999'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PT13019  Warning: Entered catch weight not within +/- range.
     *
     C     zm19          begsr
     C                   eval      #msgid = 'PT13019'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PO23201  Error: UPC code exists for ventor/item.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'PO13701'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
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
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
    AC                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *    PO21001  Multiple qty entered, Catch wt avg must be 'N'
     *
     C     zm2101        begsr
     C                   eval      #msgid = 'PO21001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TF17201
     *
     C     zm3201        begsr
     C                   eval      #msgid = 'TF17201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PO23701  Mixed Lots on License.
     *
     C     zm3701        begsr
     C                   eval      #msgid = 'PO23701'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PO23702  Mixed Expiration Dates on License
     *
     C     zm3702        begsr
     C                   eval      #msgid = 'PO23702'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13226  cannot receive an item, if ready for export.
     *
     C     zm3226        begsr
     C                   eval      #msgid = 'PO13226'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PO13228  Item cannot be accepted - Mfr date
     *
     C     zm3228        begsr
     C                   eval      #msgid = 'PO13228'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13229  Item cannot be accepted - Use by Date
     *
     C     zm3229        begsr
     C                   eval      #msgid = 'PO13229'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13230  Item cannot be accepted - Exp Date
     *
     C     zm3230        begsr
     C                   eval      #msgid = 'PO13230'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13231  Warning: Exp date comes before existing date.
     *
     C     zm3231        begsr
     C                   eval      #msgid = 'PO13231'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13232  Item cannot be accepted - Calc Exp Date
     *
     C     zm3232        begsr
     C                   eval      #msgid = 'PO13232'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13233  Warning: Calc exp date comes before existing date.
     *
     C     zm3233        begsr
     C                   eval      #msgid = 'PO13233'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13234  CW must be zero when Avg = 'Y' for "First time"
     *
     C     zm3234        begsr
     C                   eval      #msgid = 'PO13234'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13243  Item cannot be accepted. # of days out
     *
     C     zm3243        begsr
     C                   eval      #msgid = 'PO13243'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     TF17201  Warning: Quantity received not equal to ordered.
     *
     C     zm7201        begsr
     C                   eval      #msgid = 'TF17201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13202  Info message.
     *
     C     zm7202        begsr
     C                   eval      #msgid = 'PO13202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM04     Slot record does not exist.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'IT13204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      erdisp = w1slot
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM05     Slot is occupied with different item.
     *
     C     zm05          begsr
     C                   eval      #msgid = 'PO13221'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      eritm = slitem
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM06     Slot is a zero slot. It must be verified first.
     *
     C     zm06          begsr
     C                   eval      #msgid = 'PO13227'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
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
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
      /free
        error = *off;
650bA   exsr zzrcvpocheck;
        noupc = *off;
        w1qrc1 = 0;
720aA   w1qrc2 = 0;
720aA   w1qrc3 = 0;
        $pexpdt = 0;
        $pwgt   = 0;
        $pmfgdt= 0;
        $plot  = ' ';
        *in92 = *off;
        *in83 = *off;
        *in84 = *off;
        *in85 = *off;
        *in72 = *off;
        // check to make sure UCI barcode does not already exist
700aA   w1uci = %TrimL(w1uci);
        if w1uci <> ' ';
          exsr clr$uciinfo;

          $uiWhse = $pwhse;
          $uiuci  = w1uci;
          $uiitem = w1item;

          $dricommand = '*UCIINFO';
          $drisubcmd  = '%CHKACTV';
          $drisys2upd = 'D';
          ck4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
          if error;
          endif;
          // if return is *EXIST seton error
          if $drireturn = '*EXIST';
            error = *on;
            errmsg = desc(11);
            exsr zm02;
          endif;
        endif;
        if w1uci = ' ';
            error = *on;
            errmsg = desc(16);
            exsr zm0105;
        endif;
      /end-free
     c                   if        w1uci <> *blanks
      * add the conversion of the UCI barcode
     C                   eval      $cbcmd = '*ALL    '
     C                   eval      $cbbar = w1uci
     c                   clear                   $barcode
     c                   clear                   $barcode2
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
650vDC*                  parm                    $cbven           10 0
650vMC                   parm      $ITVEN#       $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
700cAC                   parm      $pwhse        $cbwhse
     c                   endif
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
      * Load UPC
650gA * if gtin not found, error for invalid barcode scanned
     c                   if        $bcGtinSent
     c                   eval      w1upcd = $bcGtin
700dAc                   eval      ntype = 'GTIN'
     c                   move      $bcgtin       ckupc
     c                   eval      *in92 = *on
640cAc                   else
650sAc                   if        $bcai99sent
650sAc                   else
650gAc                   eval      error = *on
650gAC                   eval      errmsg = 'Invalid Barcode Scanned. '
650gAC                             + 'Scan GS1 barcode.'
650gAC                   exsr      zm9999

640cAC                   movel     w1upcd        $CSTR
640cAC                   call      'ADJUST'
640cAC                   parm      '*RIGHT  '    $CCMD             8
640cAC                   parm                    $CSTR            30
640cAc                   move      $cstr         ckupc
650sAc                   endif
     c                   endif
      * Load Expiration Date
700cAc                   Select
700cMc                   When      $bcExpDSent
700cDc*                  if        $bcExpDSent
     c                   eval      $pexpdt = $bcExpD
     c                   eval      *in83 = *on
700cDc*                  endif
700cAc                   When      $bcSlByDSent
700cAc                   eval      $pexpdt = $bcSlByD
700cAc                   eval      *in83 = *on
700cAc                   endsl
      * Load Manufacturing Date
     c                   if        $bcProdDSent
     c                   eval      $pmfgdt = $bcProdD
     c                   eval      *in84 = *on
WSTcDC*                  if        client = westside
WSTcAC                   if        client = westside and $bcProdD <> 0
WSTbAc                   move      $bcProdD      $cvd6i
WSTbAC                   eval      $cvcmd = '*YMDCMD '
WSTbAC                   call      @cvtdt
WSTbAC                   parm                    $cvtdt
WSTbAC                   move      $cvd8o        expd
WSTbAC                   move      $cvd8o        wstfifo
WSTbAc                   Select
WSTdAc                   when      $cverm <> ' '
WSTdAc                   eval      error = *on
WSTdAC                   eval      errmsg = 'Invalid Barcode Scanned. '
WSTdAC                             + 'Scan GS1 barcode.'
WSTdAC                   exsr      zm9999
WSTbAc                   when      savewstfifo = 0
WSTbAc                   eval      savewstfifo = wstfifo
WSTbac                   when      wstfifo < savewstfifo
WSTbAc                   eval      savewstfifo = wstfifo
WSTbAc                   other
WSTbAc                   endsl
WSTbAc                   endif
650mAc                   else
650mAc                   if        $bcPackDSent
650mAc                   eval      $pmfgdt = $bcPackD
650mAc                   eval      *in84 = *on
WSTcDC*                  if        client = westside
WSTcAC                   if        client = westside and $bcPackD <> 0
WSTbAc                   move      $bcPackD      $cvd6i
WSTbAC                   eval      $cvcmd = '*YMDCMD '
WSTbAC                   call      @cvtdt
WSTbAC                   parm                    $cvtdt
WSTbAC                   move      $cvd8o        expd
WSTbAC                   move      $cvd8o        wstfifo
WSTbAc                   Select
WSTdAc                   when      $cverm <> ' '
WSTdAc                   eval      error = *on
WSTdAC                   eval      errmsg = 'Invalid Barcode Scanned. '
WSTdAC                             + 'Scan GS1 barcode.'
WSTdAC                   exsr      zm9999
WSTbAc                   when      savewstfifo = 0
WSTbAc                   eval      savewstfifo = wstfifo
WSTbac                   when      wstfifo < savewstfifo
WSTbAc                   eval      savewstfifo = wstfifo
WSTbAc                   other
WSTbAc                   endsl
WSTbAc                   endif
650mAc                   endif
     c                   endif
      * Load Catch Weight
700cAc                   select
700cAC                   when      svopwum = 'KGS'
700cAC                             or svopwum = 'kgs'
700cAC                             or svopwum = 'Kgs'
700cAc                   if        $bcPNtkgSent
700cAc                   eval      $pwgt  = $bcPNtkg
700cAc                   eval      *in72 = *on
700cAc                   endif
700cAC                   other
     c                   if        $bcPNtLbSent
     c                   eval      $pwgt  = $bcPNtLb
     c                   eval      *in72 = *on
     c                   endif
700cAc                   endsl
      * Load Lot
     c                   if        $bcLotSent
     c                   eval      $plot   = $bcLot
     c                   eval      *in85 = *on
     c                   endif
720aDc*                  eval      w1qrc1 = 1
     *
     *  UPC not entered.
     *
     C                   if        w1upcd = *blanks
     C                   eval      noupc = *on
     C                   endif
     *
     *  UPC code not on file.
     *
     C                   if        w1upcd <> *blanks
     *
     *  validate upc code if found in our file to make sure it is
     *  for the item selected to receive.
     c     upcky2        chain     upc2
     c                   if        %found(upc2)
720aAc                   select
720aAc                   when      uputyp = 'N'
720aAc                   eval      w1qrc1 = 1
720aAc                   when      uputyp = '1'
720aAc                   eval      w1qrc2 = 1
720aAc                   when      uputyp = '2'
720aAc                   eval      w1qrc3 = 1
720aAc                   other
720aMc                   eval      w1qrc1 = 1
720aAc                   endsl
      * same item - ok
     c                   else
650cA * does the GTIN exist for a different item, if so this is an error
650cA /free
650cA    chain ($pwhse: ckupc) upc;
650cA    if %found(upc);
650cA      //diff item - issueing error
650cA      if upitem <> $pitem;
650cA        error = *on;
650cA        errmsg = desc(13);
650cA        exsr zm0105;
650cA      endif;
650cA    else;
650jA      // but first check to see if we already have a upc code for
650jA      // this item - warn user if we do before adding.
650jA      chain ($pwhse:$pitem) upc2;
650jA      if %found(upc2);
650jA        // warn user that a UPC already exist for this item - verify
650rD        //if svupc <> ckupc;
650rM        if svupc <> ckupc
650rA           or upcovr = *off;
650jA          eval svupc = ckupc;
650jA          eval error = *on;
650jA          errmsg = *blanks;
650jA          exsr zm21;
650rA          upcwarn = *on;
650jA          leavesr;
650jA        endif;
650jA      endif;
650cA      //if doesn't exist need to add if uci receiving
650rD      //if $ifrcvmth = '2';
650rM      if $ifrcvmth = '2'
650rA         and upcovr = *on;
650cA        upwhse = $pwhse;
650cA        upitem = $pitem;
650cA        upupc = ckupc;
650cA        upven = phven;
700dA        // lets add the new fields
700dA        upuom = $itum1;
700dA        uputyp = 'N';
700dA        Select;
700dA          when ntype = 'UPC-12';
700dA            upctyp = '1';
700dA          when ntype = 'EAN-13';
700dA            upctyp = '2';
700dA          when ntype = 'GTIN';
700dA            upctyp = '3';
700dA          when ntype = 'SCC-14';
700dA            upctyp = '4';
700dA          when ntype = 'SSCC-18';
700dA            upctyp = '5';
700dA        endsl;
650cA        write uprec;
650cA      endif;
650cA    endif;
650cA /end-free
      * diff item - issueing error
650cDc*                  eval      error = *on
650cDc*                  eval      errmsg = desc(13)
650cDc*                  exsr      zm0105
     c                   endif
     c                   endif
     *
     *  UPC code must match the first barcode scanned
      * check to make sure GTIN/UPC match previous entries
      /free
        if w1uci <> ' '
           and w1lcns <> ' '
           and moretoscan= *on;
              // Lot code must match the first barcode scanned or warn
650dD     //if $bclot <> savelotc and $bclot <> ' ' and lotovr = *off
650dM     if $bclot <> savelotc and lotovr = *off
             and $bcai99sent = *off;
            error = *on;
            warn = *on;
            lotwarn = *on;
            exsr zm3701;
          endif;
          // assume same lot if no lot found in GS1 and lot was entered on
          // the first recorded scanned, whether it was from gs1 or entered
          if $bclot = ' ' and savelotc <> ' ';
            $plot = Firstlot#;
          endif;
        endif;
      /end-free
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 1 error checking.
     *
     C     zzchk2        begsr
     *   OAOVR = Manufacture date override, Caluclated exp date
     *           comes before existing overflow exp date. (PO13233)
     *   OBOVR = Manufacture date override, Manufacture date entered
     *           is greater than today.(PIR1010)
     *   OCOVR = Expiration date override, Expiration date is greater
     *           than allowed # of days out. (PO13243)
     *   ODOVR = Use by date override, Not enough user/dist days to
     *           sell before expiration date (PO13229)
     *   OEOVR = Mfg date override, Not enough user/dist days to
     *           sell before calculated expiration date (PO13228)
     *   OFOVR = Expiration date override, Expiration date entered
     *           comes before existing overflow exp date. (PO13231)
     *   DDCODE= Invalid Date returned from the Decipher progrmas
     *   CWOVR = Weight error override taken.
     *   DTCHK, QTCHK, WTCHK Flags are used to force F20 for each test
     *   DTCHK2
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C                   eval      error = *off
650bAc                   exsr      zzrcvpocheck
     *
     *  Make sure license doesn't already exist if first scan
     *
     c                   if        *in80 = *off
     c                             and w1lcns <> ' '
     c                             and $pxd <> 'XD'
700bAc                             and sprcv <> *on
     c                   exsr      zzchklcns
     c                   endif
     *
     *  Make sure license is scanned on first scan
     *
     c                   if        *in80 = *off
     c                             and w1lcns = ' '
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     c                   eval      errmsg = desc(12)
     c                   exsr      zm0105
     c                   endif
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
     *  Extract UPC code from entered string.
     *
     C                   if        w1upcd <> *blanks
     C                   eval      $cbcmd = '*UPC    '
     C                   eval      $cbbar = w1upcd
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
740aAC                   parm      $itven#       $cbven           10 0
740aAC                   parm                    $cvtdata
740aAC                   parm                    $cvtdata2
740aAC                   parm      $pwhse        $cbwhse
     *
     C                   movel     $cbv2         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   eval      w1upc = *blanks
     C                   move      $cstr         w1upc
     C                   endif
     *   Do UPC Check
     C                   if        w1upcd <> *blanks  and
     C                             $pupc = *blanks
     C                   if        svupc <> w1upcd
     C                   eval      upchk = *off
     C                   eval      upchk2 = *off
     C                   endif
     *
     C                   if        upchk <> '2'  and
     C                             ovrrid = *on  and
     C                             $cbrtn <> '*INVALID'
     C                   eval      upchk = *on
     C                   endif
     *
     C                   if        upchk <> '1'
     C                   eval      upchk = *on
     *  Moved code to extract UPC code from entered string. see above.
     *  Extract UPC code from entered string.
     *
     C                   select
     *
     C                   when      $cbrtn = '*OK'
     *
     C                   other
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   movel     $cberm        errmsg
     C                   exsr      zm0105
     C                   endsl
     *
     C     error         cabeq     *on           enderr
     C                   endif
     C                   endif
     *
     C                   if        upchk2 = '0'  and
     C                             ovrrid = *on
     C                   eval      ovrrid = *off
     C                   endif
     C                   if        upchk2 <> '2'  and
     C                             ovrrid = *on
     C                   eval      upchk2 = *on
     C                   endif
     *
     C                   if        upchk2 <> '1'
     C                   eval      upchk2 = *on
     *  ERROR - UPC CODE EXISTS FOR ITEM/VENDOR
650jA // remove this check since we edit on screen1
650jDC*                  if        w1upcd <> *blanks  and
650jDC*                            $pupc = *blanks
650jDC*    upcky1        chain(n)  upc1                               79
650jDC*                  if        not *in79  and
650jDC*                            upupc <> w1upc
650jDC*                  eval      error = *on
650jDC*                  eval      *in26 = *on
650jDC*                  eval      *in06 = *on
650jDC*                  eval      errmsg = *blanks
650jDC*                  exsr      zm21
650jDC*                  endif
650jDC*                  endif
     C     error         cabeq     *on           enderr
     C                   endif
     *
     *  Verify normal quantity.
     *
     C                   if        w1qrc1 < 0  or
     C                             w1qrc1 > 99999
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify breakdown 1 unit of measure quantity.
     *
     C                   if        w1qrc2 < 0  or
     C                             w1qrc2 > 99999
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify breakdown 2 unit of measure quantity.
     *
     C                   if        w1qrc3 < 0  or
     C                             w1qrc3 > 99999
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify FIFO (entered) date.
     *
     C                   if        not *in89  and
     C                             w1fifo <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1fifo        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      #msgk = $cvmsg
     C                   goto      enderr
     C                   else
     C                   eval      w1fifo = $cvd6o
     C                   endif
     C                   endif
     *
     *  Verify expiration date.
     *
     C                   if        not *in96  and
     C                             w1exdt = 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
     C                   else
     *
     *  Moved code here to calculate CKEXDT
     *  Verify Expiration date is within parameter (# of days out)     days)
     *  Calculate (Today + # days out)  = CHEXDT                       days)
     *
     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      today         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imoday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     ckexdt        parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   if        w1exdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $cvmsg
     C                   goto      enderr
     C                   else
     C                   eval      w1exdt = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        woexdt
     C                   if        expd <= today
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1009
     C                   endif
     *  Code to calculate CKEXDT was moved from here to above.
     *
     *  Verify Use by date.                                            days)
     *  Calculate (Today + Dist Days)  = DATE1                         days)
     *  Calculate  (Use By - User Days) = DATE2                        days)
     *

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      today         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imdday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     date1         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     date2         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     *
     C                   move      date2         $cvd8i
     C                   eval      $cvcmd = '*CMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        date2o
     *
     C                   endif
     C                   endif
     C                   endif
     ***
     *  Verify Expire date and # of days out                           days)
     *  Allow warning and override                                     days)
     C                   if        expd <> 0
     C                   if        svexdt <> w1exdt
     C                   eval      dtchk = *off
     C                   eval      ocovr = *off
     C                   endif
     *
     C                   if        dtchk = '2'  and
     C                             ovrrid = *on
     C                   eval      ocovr = *on
     C                   eval      dtchk = *on
     C                   endif
     *
     C                   if        dtchk <> '1'
     C                   eval      dtchk = *on
     *
     *   If EXPD > /CKEXDT - Reject.
     *
     C                   if        expd > ckexdt
     C                   eval      error = *on
     C                   eval      dtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erused = w1exdt
     C                   eval      erdisd = $imoday
     C                   exsr      zm3243
     C                   endif
     *
     C     error         cabeq     *on           enderr
     *
     C                   endif
     C                   eval      expd = date2
     C                   endif
     *
     *  Verify Use by date.                                            days)
     C                   if        expd <> 0
     C                   if        svexdt <> w1exdt
     C                   eval      dtchk3 = *off
     C                   endif
     *
     C                   if        dtchk3 = '2'  and
     C                             ovrrid = *on
     C                   eval      odovr = *on
     C                   eval      dtchk3 = *on
     C                   endif
     *
     C                   if        dtchk3 <> '1'
     C                   eval      dtchk3 = *on
     *
     *   If DATE2 <= Date1 - Reject.
     *
     C                   if        date2 <= date1
     C                   eval      error = *on
     C                   eval      dtchk3 = '2'
     C                   eval      warn = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erused = w1exdt
     C                   eval      erdisd = $imdday
     C                   eval      erusrd = $imuday
     C                   eval      ersell = date2o
     C                   exsr      zm3229
     C                   endif
     *
     C     error         cabeq     *on           enderr
     *
     C                   endif
     C                   eval      expd = date2
     C                   endif
     *
     *  Change to use DTCHK4 for override                                  )
     C                   if        svmfdt <> w1mfdt
     C                   eval      dtchk4 = *off
     C                   endif
     *
     C                   if        dtchk4 = '2'  and
     C                             ovrrid = *on
     C                   if        mfgd > today
     C                   eval      obovr = *on
     C                   endif
     C                   if        today > ltstd8
     C                   eval      oeovr = *on
     C                   endif
     C                   eval      dtchk4 = *on
     C                   endif
     C                   if        dtchk4 <> '1'
     C                   eval      dtchk4 = *on
     *
     *
     *  Verify manufacturing date.
     *
     C                   select
     C                   when      $immflg = 'Y'
     C                   if        w1mfdt = 0
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
     C                   else
     C                   if        w1mfdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      #msgk = $cvmsg
     C                   goto      enderr
     C                   else
     C                   eval      w1mfdt = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgd
     C                   if        mfgd > today
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1010
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     *
     C     error         cabeq     *on           enderr
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1exdt

     *
     *  Find the latest acceptable date.: Exp date -Dist days
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        ltstd8

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      ltstd8        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imdday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     ltstd8        parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ltstd8        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        ltstd6

     *
     *   If Today's date is > Latest acceptable date - Reject.
     *
     C                   if        today > ltstd8
     C                   eval      error = *on
     C                   eval      oeovr = *off
     C                   eval      dtchk4 = '2'
     C                   eval      warn = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ermday = $immday
     C                   eval      ermfdt = w1mfdt
     C                   eval      erexdt = w1exdt
     C                   eval      erltst = ltstd6
     C                   eval      erdday = $imdday
     C                   eval      eruday = $imuday
     C                   exsr      zm3228
     C                   eval      w1exdt = *zeros
     C                   eval      expd = *zeros
     C                   endif
     C                   endsl
     *
     *   Save screen fields.
     C     error         cabeq     *on           enderr
     C                   endif
     *
     *  Different expiration dates
      /free
         if moretoscan = *on and expdovr <> *on;
           if $immflg = 'Y';
             if savew1mfdt <> w1mfdt;
               error = *on;
               warn = *on;
               expdwarn = *on;
               exsr zm3702;
             endif;
           else;
             if $itflgd = 'Y';
               if savew1exdt <> w1exdt;
                 error = *on;
                 warn = *on;
                 expdwarn = *on;
                 exsr zm3702;
               endif;
             endif;
           endif;
         endif;
      /end-free
     C     error         cabeq     *on           enderr
     *
     *   Check for ealier expiration dates (optional)                  days)
     *
     *     See if we can skip the check.                               days)
     *
     C                   if        w1exdt = 0  or
     C                             svexck <> '2'  and
     C                             svexck <> '3'
     C                   goto      skpxck
     C                   endif
     *
     *     Set warning check flag.                                     days)
     *
     C                   if        svexdt <> w1exdt
     C                   eval      dtchk2 = *off
     C                   eval      oaovr = *off
     C                   eval      ofovr = *off
     C                   endif
     *
     C                   if        dtchk2 = '2'  and
     C                             ovrrid = *on
     C                   if        $immflg = 'Y'
     C                   eval      oaovr = *on
     C                   else
     C                   eval      ofovr = *on
     C                   endif
     C                   eval      dtchk2 = *on
     C                   goto      skpxck
     C                   endif
     *
     C     dtchk2        cabeq     '1'           skpxck
     *
     *     Do actual check                                             days)
     *
     C                   eval      dtchk2 = *on
     *
     *       Get date range of overflow slots.
     *
     C                   call      'GETEXPD'
     C                   parm      $pwhse        $swhse            3 0
     C                   parm                    #sitem
     C                   parm                    $dfrom            8 0
     C                   parm                    $dto              8 0
     *
     *       If date comes after end of range
     *         Then date can be recevied so skip the rest of the check
     *
     C                   if        expd >= $dto
     C                   goto      skpxck
     C                   endif
     *
     *       Otherwise, see if it's an error or warning.
     *
     *         '1' = Allow Let it go through
     *         '2' = Error (Not Allowed)
     *         '3' = Warning.
     *
     C                   eval      error = *on
     C                   if        $immflg = 'Y'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   else
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif
     C                   eval      errmsg = *blanks
     C                   eval      erentd = expd
     C                   eval      ertod = $dto
     C                   select
     C                   when      svexck = '2'
     C                   eval      dtchk2 = *off
     C                   if        $immflg = 'Y'
     C                   exsr      zm3232
     C                   else
     C                   exsr      zm3230
     C                   endif
     C                   when      svexck = '3'
     C                   eval      dtchk2 = '2'
     C                   eval      warn = *on
     C                   if        $immflg = 'Y'
     C                   eval      oaovr = *on
     C                   exsr      zm3233
     C                   else
     C                   eval      ofovr = *on
     C                   exsr      zm3231
     C                   endif
     C                   endsl
     *
     C     error         cabeq     *on           enderr
     *
     C     skpxck        tag
     *
     *  Different lot - entered manually
      /free
        if w1lotc <> savelotc and moretoscan = *on and difflot = *off
           and $bcai99Sent;
          error = *on;
          warn = *on;
          lotwarn = *on;
          exsr zm3701;
        endif;
      /end-free
     C     error         cabeq     *on           enderr
     *
     *
     *  Always error if catchweight is negative
     *
     C                   if        w1dwgt < 0
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = 'Negative catchweight entered. '
     C                             + 'Catchweight must be greater than zero.'
     C                   exsr      zm9999
     C                   goto      enderr
     C                   endif
     *
     *  See if we need to verify catch weight.
     *
     C     vrfycw        cabeq     *off          skipcw
640bA*
640bA*  If Catch weight is retieved from gs1 scan do not edit
640bA*
640bAC     $bcPNtLbSent  cabeq     *on           skipcw
     *
     *  CW can't be zero if forced entry is selected.
     *
     *    One exception for 'First time only' entry with Avg = 'Y'
     *
     C                   if        svcwfr = 'Y'  and
     C                             w1dwgt = 0
     C                   if        svcwen = '1'  or
     C                             svcwen = '2'  and
     C                             w1avg <> 'Y'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
     C                   exsr      zm0110
     C                   endif
     C                   endif
650sA*  CW can't be zero if uci receiving on catch weight item
650sAC                   if        w1dwgt = 0 and $itcwgt = 'Y' and
650sAc                             $ifucicde = '2'
650sAC                   eval      error = *on
650sAC                   eval      *in25 = *on
650sAC                   eval      *in05 = *on
650sAC                   eval      errmsg = *blanks
650sAC                   movel     desc(4)       errmsg
650sAC                   exsr      zm0110
650sAc                   endif
     *
     *
     *  Verify Catch weight average  (Y/N).
     *
     C                   if        w1avg <> 'Y'  and
     C                             w1avg <> 'N'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm1005
     C                   endif
     *
     *  When 'First time only' entry with Avg = 'Y'
     *    Then catch weight must be zero.
     *
     C                   if        svcwen = '2'  and
     C                             w1avg = 'Y'  and
     C                             w1dwgt <> 0
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm3234
     C                   endif
     *
     *
     *  When more than one qty is entered, catch weight average must be N
     *
     *    One exception for 'First time only' entry with Avg = 'Y'
     *
     C                   select
     C                   when      w1qrc1 <> 0  and
     C                             w1avg = 'Y'  and
     C                             svcwen <> '2'
     C                   if        w1qrc2 <> 0  or
     C                             w1qrc3 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm2101
     C                   endif
     *
     C                   when      w1qrc2 <> 0  and
     C                             w1avg = 'Y'  and
     C                             svcwen <> '2'
     C                   if        w1qrc1 <> 0  or
     C                             w1qrc3 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm2101
     C                   endif
     *
     C                   when      w1qrc3 <> 0  and
     C                             w1avg = 'Y'  and
     C                             svcwen <> '2'
     C                   if        w1qrc1 <> 0  or
     C                             w1qrc2 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm2101
     C                   endif
     *
     C                   endsl
     *
     *  Skip catch weight variance check when ...
     *    "First time only" entry
     *
     C                   if        svcwen = '2'
     C                   goto      skipcw
     C                   endif
     *
     *  Catch weight variance check.
     C                   if        svdwgt <> w1dwgt
     C                   eval      wtchk = *off
     C                   endif
     *
     C                   if        wtchk = '2'  and
     C                             ovrrid = *on
650hAc                   eval      cwovr = *on
     C                   eval      wtchk = *on
     C                   endif
     *
     C                   if        wtchk <> '1'
     C                   eval      wtchk = *on
     *
     *   If catch weight >0,
     *     Calculate total expected catch weight,
     *     Calculate low/high ranges.
     C                   if        w1dwgt <> 0
     C                   eval      lwvar = 0
     C                   eval      hivar = 0
     C                   eval      lwrng = 0
     C                   eval      hirng = 0
     C                   eval      exwgt = 0
     C                   eval      ilvar = 0
     C                   eval      ihvar = 0
     C                   eval      ilrng = 0
     C                   eval      ihrng = 0
     *
     C                   if        w1avg = 'Y'
     C                   eval      exwgt = $itswgt
     C                   eval      wotcw = w1dwgt
     C                   else
     C                   if        svcwen = '2'
     C     pdqor1        mult      $itswgt       exwgt
     C                   else
     C     w1qrc1        mult      $itswgt       exwgt
     C                   endif
     C                   eval      wotcw = w1dwgt
     C                   endif
     *
     **   Iniz. flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     **   Use item variance % if it exists
     C                   if        not *in75
     *
     C                   if        $imrg1c <> 0
     C     $imrg1c       div       100           prg1c
     C                   if        $imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        $imrg2c <> 0
     C     $imrg2c       div       100           prg2c
     C                   if        $imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
     C                   eval      ilvar = $itswgt * prg1c
     C                   endif
     C                   eval      lwrng = exwgt - lwvar
     C                   eval      ilrng = $itswgt - ilvar
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     C                   eval      ihvar = $itswgt * prg2c
     C                   endif
     C     exwgt         add       hivar         hirng
     C     $itswgt       add       ihvar         ihrng
     *
     C                   endif
     *
     *     Check CW variance if CW > 0
     C                   if        w1dwgt <> 0
     C                   exsr      zzchkt
     C                   endif
     *
     *   Save screen fields.
     C     error         cabeq     *on           enderr
     C                   endif
     *
     C     skipcw        tag
     *
     *
     *    Make sure slot is valid.
     *
     C                   if        w1slot <> *blanks
     C     slkey         chain     s2rec                              79
     *
     *      Slot doesn't exist.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm04
     C                   goto      enderr
     C                   endif
     *
     *      Slot occupied by different item.
     *
     C                   if        slstat <> 'Z'  and
     C                             slitem <> ' '  and
     C                             slitem <> $pitem
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm05
     C                   goto      enderr
     C                   endif
     *
     *      Slot is a zero slot.
     *
     C                   if        slstat = 'Z'
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm06
     C                   goto      enderr
     C                   endif
     C                   endif
     *
     *
     *  Warning: Quantity
     *
     C     w1qrc1        add       pdqrc1        svqrc1
     C     w1qrc2        add       pdqrc2        svqrc2
     C     w1qrc3        add       pdqrc3        svqrc3
     *
     *    Accumulate total exceptions to include in qty test.
     C                   exsr      zzttle
     *  Quantity.
     C                   if        sdqrc1 <> w1qrc1  or
     C                             sdqrc2 <> w1qrc2  or
     C                             sdqrc3 <> w1qrc3
     C                   eval      qtchk = *off
     C                   endif
     *
     C                   if        qtchk = '2'  and
     C                             ovrrid = *on
     C                   eval      qtchk = *on
     C                   endif
     *
     C                   if        qtchk <> '1'
     C                   eval      qtchk = *on
     *
640bDC*                  if        svqrc1 <> pdqor1  or
640bDC*                            svqrc2 <> pdqor2  or
640bDC*                            svqrc3 <> pdqor3
640bDC*                  eval      warn = *on
640bDC*                  eval      error = *on
640bDC*                  eval      qtchk = '2'
640bDC*                  eval      *in21 = *on
640bDC*                  eval      *in22 = *on
640bDC*                  eval      *in23 = *on
640bDC*                  eval      *in01 = *on
640bDC*                  exsr      zm7201
640bDC*                  endif
     *
     *   Save screen fields.
     C     error         cabeq     *on           enderr
     *
     C                   endif
     *
     C     enderr        tag
     *
     C                   eval      svdwgt = w1dwgt
     C                   eval      sdqrc1 = w1qrc1
     C                   eval      sdqrc2 = w1qrc2
     C                   eval      sdqrc3 = w1qrc3
     C                   eval      svmfdt = w1mfdt
     C                   eval      svexdt = w1exdt
     C                   eval      svupc = w1upcd
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2x  Screen 2 error checking.
     *
     C     zzchk2x       begsr
     C                   eval      error = *off
650bAc                   exsr      zzrcvpocheck
     *
     C     endck2x       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 1 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
650bAc                   exsr      zzrcvpocheck
650jA*  Always error if catchweight is negative
650jA*
650jAC                   if        w1dwgt < 0
650jAC                   eval      error = *on
650jAC                   eval      *in25 = *on
650jAC                   eval      *in05 = *on
650jAC                   eval      errmsg = 'Negative catchweight entered. '
650jAC                             + 'Catchweight must be greater than zero.'
650jAC                   exsr      zm9999
650jAC                   goto      enderr3
650jAC                   endif
650jA*
650jA*  See if we need to verify catch weight.
650jA*
650jAC     vrfycw        cabeq     *off          skipcw3
650jA*
650jA*  CW can't be zero if forced entry is selected.
650jA*
650jA*    One exception for 'First time only' entry with Avg = 'Y'
650jA*
650jAC                   if        svcwfr = 'Y'  and
650jAC                             w1dwgt = 0
650jAC                   if        svcwen = '1'  or
650jAC                             svcwen = '2'  and
650jAC                             w1avg <> 'Y'
650jAC                   eval      error = *on
650jAC                   eval      *in25 = *on
650jAC                   eval      *in05 = *on
650jAC                   eval      errmsg = *blanks
650jAC                   movel     desc(4)       errmsg
650jAC                   exsr      zm0110
650jAC                   endif
650jAC                   endif
650jA*
650jA*  Verify Catch weight average  (Y/N).
650jA*
650jAC                   if        w1avg <> 'Y'  and
650jAC                             w1avg <> 'N'
650jAC                   eval      error = *on
650jAC                   eval      *in32 = *on
650jAC                   eval      *in12 = *on
650jAC                   eval      errmsg = *blanks
650jAC                   movel     desc(5)       errmsg
650jAC                   exsr      zm1005
650jAC                   endif
650jA*
650jA*  When 'First time only' entry with Avg = 'Y'
650jA*    Then catch weight must be zero.
650jA*
650jAC                   if        svcwen = '2'  and
650jAC                             w1avg = 'Y'  and
650jAC                             w1dwgt <> 0
650jAC                   eval      error = *on
650jAC                   eval      *in25 = *on
650jAC                   eval      *in05 = *on
650jAC                   eval      errmsg = *blanks
650jAC                   exsr      zm3234
650jAC                   endif
650jA*
650jA*
650jA*  When more than one qty is entered, catch weight average must be N
650jA*
650jA*    One exception for 'First time only' entry with Avg = 'Y'
650jA*
650jAC                   select
650jAC                   when      w1qrc1 <> 0  and
650jAC                             w1avg = 'Y'  and
650jAC                             svcwen <> '2'
650jAC                   if        w1qrc2 <> 0  or
650jAC                             w1qrc3 <> 0
650jAC                   eval      error = *on
650jAC                   eval      *in32 = *on
650jAC                   eval      *in12 = *on
650jAC                   eval      errmsg = *blanks
650jAC                   movel     desc(5)       errmsg
650jAC                   exsr      zm2101
650jAC                   endif
650jA*
650jAC                   when      w1qrc2 <> 0  and
650jAC                             w1avg = 'Y'  and
650jAC                             svcwen <> '2'
650jAC                   if        w1qrc1 <> 0  or
650jAC                             w1qrc3 <> 0
650jAC                   eval      error = *on
650jAC                   eval      *in32 = *on
650jAC                   eval      *in12 = *on
650jAC                   eval      errmsg = *blanks
650jAC                   movel     desc(5)       errmsg
650jAC                   exsr      zm2101
650jAC                   endif
650jA*
650jAC                   when      w1qrc3 <> 0  and
650jAC                             w1avg = 'Y'  and
650jAC                             svcwen <> '2'
650jAC                   if        w1qrc1 <> 0  or
650jAC                             w1qrc2 <> 0
650jAC                   eval      error = *on
650jAC                   eval      *in32 = *on
650jAC                   eval      *in12 = *on
650jAC                   eval      errmsg = *blanks
650jAC                   movel     desc(5)       errmsg
650jAC                   exsr      zm2101
650jAC                   endif
650jA*
650jAC                   endsl
650jA*
650jA*  Skip catch weight variance check when ...
650jA*    "First time only" entry
650jA*
650jAC                   if        svcwen = '2'
650jAC                   goto      skipcw3
650jAC                   endif
650jA*
650jA*  Catch weight variance check.
650jAC                   if        svdwgt <> w1dwgt
650jAC                   eval      wtchk = *off
650jAC                   endif
650jA*
650jAC                   if        wtchk = '2'  and
650jAC                             ovrrid = *on
650jAc                   eval      cwovr = *on
650jAC                   eval      wtchk = *on
650j
650jAC                   endif
650jA*
650jAC                   if        wtchk <> '1'
650jAC                   eval      wtchk = *on
650jA*
650jA*   If catch weight >0,
650jA*     Calculate total expected catch weight,
650jA*     Calculate low/high ranges.
650jAC                   if        w1dwgt <> 0
650jAC                   eval      lwvar = 0
650jAC                   eval      hivar = 0
650jAC                   eval      lwrng = 0
650jAC                   eval      hirng = 0
650jAC                   eval      exwgt = 0
650jAC                   eval      ilvar = 0
650jAC                   eval      ihvar = 0
650jAC                   eval      ilrng = 0
650jAC                   eval      ihrng = 0
650jA*
650jAC                   if        w1avg = 'Y'
650jAC                   eval      exwgt = $itswgt
650jAC                   eval      wotcw = w1dwgt
650jAC                   else
650jAC                   if        svcwen = '2'
650jAC     pdqor1        mult      $itswgt       exwgt
650jAC                   else
650jAC     w1qrc1        mult      $itswgt       exwgt
650jAC                   endif
650jAC                   eval      wotcw = w1dwgt
650jAC                   endif
650jA*
650jA**   Iniz. flag used to skip variance check if = *ON.
650jAC                   eval      lvskp = *off
650jAC                   eval      hvskp = *off
650jA**   Use item variance % if it exists
650jAC                   if        not *in75
650jA*
650jAC                   if        $imrg1c <> 0
650jAC     $imrg1c       div       100           prg1c
650jAC                   if        $imrg1c = 99
650jAC                   eval      lvskp = *on
650jAC                   endif
650jAC                   endif
650jA*
650jAC                   if        $imrg2c <> 0
650jAC     $imrg2c       div       100           prg2c
650jAC                   if        $imrg2c = 99
650jAC                   eval      hvskp = *on
650jAC                   endif
650jAC                   endif
650jA*
650jAC                   endif
650jA*
650jAC                   if        prg1c = 0
650jAC     oprg1c        div       100           prg1c
650jAC                   endif
650jAC                   if        prg2c = 0
650jAC     oprg2c        div       100           prg2c
650jAC                   endif
650jA*
650jAC                   if        prg1c > 0
650jAC     exwgt         mult      prg1c         lwvar
650jAC                   eval      ilvar = $itswgt * prg1c
650jAC                   endif
650jAC                   eval      lwrng = exwgt - lwvar
650jAC                   eval      ilrng = $itswgt - ilvar
650jAC                   if        prg2c > 0
650jAC     exwgt         mult      prg2c         hivar
650jAC                   eval      ihvar = $itswgt * prg2c
650jAC                   endif
650jAC     exwgt         add       hivar         hirng
650jAC     $itswgt       add       ihvar         ihrng
650jA*
650jAC                   endif
650jA*
650jA*     Check CW variance if CW > 0
650jAC                   if        w1dwgt <> 0
650jAC                   exsr      zzchkt
650jAC                   endif
650jA*
650jA*   Save screen fields.
650jAC     error         cabeq     *on           enderr3
650jAC                   endif
650jA*
650jAC     enderr3       tag
650jAC                   eval      svdwgt = w1dwgt
650jA*
650jAC     skipcw3       tag
     *
     C     endck3        endsr
700dA*----------------------------------------------------------------
700dA*
700dA*  ZZCHK4   Screen 4 error checking.
700dA*
700dAC     zzchk4        begsr
700dAC                   eval      error = *off
700dA*  at least one UPC must be entered or f9 to skip.
700dAc                   select
700dAc                   when      w1buom1 <> ' ' and
700dAC                             w1bupc1 = ' '  and
700dAc                             w1buom2 <> ' ' and
700dAC                             w1bupc2 = ' '
700dAC                   eval      error = *on
700dAC                   eval      *in17 = *on
700dAc                   eval      errmsg =  'Invalid ' + desc(6)
700dAc                   exsr      zm0105
700dAc                   leavesr
700dAc                   when      w1buom1 <> ' ' and
700dAC                             w1bupc1 = ' '  and
700dAc                             w1buom2 =  ' '
700dAC                   eval      error = *on
700dAC                   eval      *in17 = *on
700dAc                   eval      errmsg =  'Invalid ' + desc(6)
700dAc                   exsr      zm0105
700dAc                   leavesr
700dAc                   when      w1buom2 <> ' ' and
700dAC                             w1bupc2 = ' '  and
700dAc                             w1buom1 =  ' '
700dAC                   eval      error = *on
700dAC                   eval      *in18 = *on
700dAc                   eval      errmsg =  'Invalid ' + desc(6)
700dAc                   exsr      zm0105
700dAc                   leavesr
700dAc                   endsl
700dA*
700dA*  Extract UPC code from entered string.
700dA*
700dA * edit breakdown 1 upc
700dAc                   if        w1buom1 <> ' ' and
700dAC                             w1bupc1 <> *blanks
700dAC                   eval      $cbcmd = '*UPC    '
700dAC                   eval      $cbbar = w1bupc1
700dA*
700dAC                   call      'CVTBAR'
700dAC                   parm                    $cbcmd            8
700dAC                   parm                    $cbbar          100
700dAC                   parm                    $cbcod            3 0
700dAC                   parm                    $cbdec            1 0
700dAC                   parm                    $cbdsc           30
700dAC                   parm                    $cbpos            3 0
700dAC                   parm                    $cbtyp            1 0
700dAC                   parm                    $cbv1            11 3
700dAC                   parm                    $cbv2            50
700dAC                   parm                    $cbrtn            8
700dAC                   parm                    $cberm           60
740aAC                   parm      $itven#       $cbven           10 0
740aAC                   parm                    $cvtdata
740aAC                   parm                    $cvtdata2
740aAC                   parm      $pwhse        $cbwhse
700dA*
700dAC                   movel     $cbv2         $cstr
700dAC                   call      'ADJUST'
700dAC                   parm      '*RIGHT  '    $ccmd             8
700dAC                   parm                    $cstr            30
700dAC                   move      $cstr         b1upc
700dAC                   endif
700dA*   Do UPC Check
700dAC                   if        w1bupc1 <> ' '
700dA*
700dA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700dAC                   select
700dA*
700dAC                   when      $cbrtn = '*OK'
700dAc                   eval      writeb1 = *on
700dAc                   eval      b1type = %trimr($cbdsc)
700dA*
700dAC                   other
700dAC                   eval      error = *on
700dAC                   eval      *in17 = *on
700dAC                   movel     $cberm        errmsg
700dAC                   exsr      zm0105
700dAC                   endsl
700dA*
700dAC     error         cabeq     *on           endck4
700dAC                   endif
700dA*
700dA * edit breakdown 2 upc
700dAc                   if        w1buom2 <> ' ' and
700dAC                             w1bupc2 <> *blanks
700dAC                   eval      $cbcmd = '*UPC    '
700dAC                   eval      $cbbar = w1bupc2
700dA*
700dAC                   call      'CVTBAR'
700dAC                   parm                    $cbcmd            8
700dAC                   parm                    $cbbar          100
700dAC                   parm                    $cbcod            3 0
700dAC                   parm                    $cbdec            1 0
700dAC                   parm                    $cbdsc           30
700dAC                   parm                    $cbpos            3 0
700dAC                   parm                    $cbtyp            1 0
700dAC                   parm                    $cbv1            11 3
700dAC                   parm                    $cbv2            50
700dAC                   parm                    $cbrtn            8
700dAC                   parm                    $cberm           60
740aAC                   parm      $itven#       $cbven           10 0
740aAC                   parm                    $cvtdata
740aAC                   parm                    $cvtdata2
740aAC                   parm      $pwhse        $cbwhse
700dA*
700dAC                   movel     $cbv2         $cstr
700dAC                   call      'ADJUST'
700dAC                   parm      '*RIGHT  '    $ccmd             8
700dAC                   parm                    $cstr            30
700dAC                   move      $cstr         b2upc
700dAC                   endif
700dA*   Do UPC Check
700dAC                   if        w1bupc2 <> ' '
700dA*
700dA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700dAC                   select
700dA*
700dAC                   when      $cbrtn = '*OK'
700dAc                   eval      writeb2 = *on
700dAc                   eval      b2type = %trimr($cbdsc)
700dA*
700dAC                   other
700dAC                   eval      error = *on
700dAC                   eval      *in18 = *on
700dAC                   movel     $cberm        errmsg
700dAC                   exsr      zm0105
700dAC                   endsl
700dA*
700dAC     error         cabeq     *on           endck4
700dAC                   endif
700dA*
700dAC     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKT   Screen 3 error check totals
     *
     C     zzchkt        begsr
     C                   eval      error = *off
     *
     *
     *     Check # of entrys if individual catchweight entry = Y
     *
     *
     *
     *     Compare total catchweight to expected catchweight
     *
     *
     C                   if        lvskp = *off  and
     C                             wotcw < lwrng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   eval      erlrng = lwrng
650oAC                   eval      CW_exrngl = erlrng
     C                   if        hvskp = *on
     C                   eval      erhrng = 0
650oAC                   eval      CW_exrngh = erhrng
     C                   else
     C                   eval      erhrng = hirng
650oAC                   eval      CW_exrngh = erhrng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
     C                   exsr      zm19
     C                   endif
     *
     C                   if        hvskp = *off  and
     C                             wotcw > hirng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   if        lvskp = *on
     C                   eval      erlrng = 0
650oAC                   eval      CW_exrngl = erlrng
     C                   else
     C                   eval      erlrng = lwrng
650oAC                   eval      CW_exrngl = erlrng
     C                   endif
     C                   eval      erhrng = hirng
650oAC                   eval      CW_exrngh = erhrng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
     C                   exsr      zm19
     C                   endif
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKLCNS  Check for active license
     *
     C     zzchklcns     begsr
650xAC                   eval      *in86 = *off
650xAC     valid         check     w1lcns                                 86
650xA*
650xA*  *IN86 = *ON - One of the positions did not have valid value
650xA*
650xAC                   if        *in86
650xAC                   eval      error = *on
650xAC                   eval      *in15 = *on
650xAc                   eval      errmsg= desc(15)
650xAC                   exsr      zm1001
650xAc                   leavesr
650xAc                   endif
     C                   eval      lcnsExists = *off

     *  See if license exists in licactive file.

     C                   exsr      clr$license
     C                   eval      $liToLcnsU = *on
     c                   if        $pxd = ' '
700bAc                             and sprcv = *off
     C                   eval      $liToLcns = w1lcns
     c                   else
     C                   eval      $liToLcns = templcns
     c                   endif
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETLCNS'
     C                   eval      $drisys2upd = 'D'
640dDC*                  eval      chk4err = *on
640dMC                   eval      ck4err = *on
     C                   eval      zmflag  = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      lcnsExists = *off
     C                   eval      error = *off
650fA*
650fA*  Check LICLOG before accepting this license
650fA*
650fAC                   exsr      clr$license
650fAC                   eval      $liToLcnsU = *on
650fAc                   if        $pxd = ' '
700bAc                             and sprcv = *off
650fAC                   eval      $liToLcns = w1lcns
650fAc                   else
650fAC                   eval      $liToLcns = templcns
650fAc                   endif
650fAC                   eval      $liOLcnsU = *on
650fAc                   if        $pxd = ' '
700bAc                             and sprcv = *off
650fAC                   eval      $liOLcns = w1lcns
650fAc                   else
650fAC                   eval      $liToLcns = templcns
650fAc                   endif
650fAC                   eval      $dricommand = '*LICENSE'
650fAC                   eval      $drisubcmd  = '%GETINFO'
650fAC                   eval      $drisys2upd = 'D'
650fAC                   eval      ck4err = *off
650fAC                   exsr      zzzdricop
650fAc* if we get an ok on the return this means it exist - don't use
650fAC                   if        $drireturn = '*OK'
650fAC                   eval      lcnsExists = *on
650fAC                   eval      error = *on
650fAC                   eval      *in15 = *on
650fAc                   eval      errmsg= desc(15)
650fAc                   exsr      zm02
650fAC                   endif
650fA
710aA*
710aA*  Check LICINFO before accepting this license
710aA*
710aAC                   exsr      clr$licinfo
710aAC                   eval      $lnwhse   = $pwhse
710aAc                   if        $pxd = ' '
710aAC                   eval      $lnlcns   = w1lcns
710aAc                   else
710aAC                   eval      $lnlcns   = templcns
710aAc                   endif
710aAC                   eval      $dricommand = '*LICINFO'
710aAC                   eval      $drisubcmd  = '%GET'
710aAC                   eval      $drisys2upd = 'D'
710aAC                   eval      ck4err = *off
710aAC                   exsr      zzzdricop
710aAc* if we get an ok on the return this means it exist - don't use
710aAC                   if        $drireturn = '*OK'
710aAC                             and $liToAisl <> 'OSS'
710aAC                   eval      lcnsExists = *on
710aAC                   eval      error = *on
710aAC                   eval      *in15 = *on
710aAc                   eval      errmsg= desc(15)
710aAc                   exsr      zm02
710aAC                   endif
710aA
     C                   leavesr
     C                   else
     C                   eval      lcnsExists = *on
     C                   eval      error = *on
     C                   eval      *in15 = *on
     c                   eval      errmsg= desc(15)
     c                   exsr      zm02
     C                   endif


     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                             or *inkj
     C                   eval      ovrrid = *on
     c                   if        lotwarn = *on
     C                   eval      difflot = *on
640dDC*                  eval      lotwarn = *off
640dAC                   eval      lotovr = *on
     c                   endif
650rAc                   if        UPCwarn = *on
650rAC                   eval      UPCovr = *on
650rAc                   endif
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     *
     *
     *      F22 - Complete License.
      *
     C                   if        *inkw
     c                   if        saveqty > 0
     C                   eval      cmdtkn = *on
     c                   eval      nxtscr = '03 '
     c                   exsr      scr03i
     c                   endif
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
650qA*
650qA*
650qA*      F8  - Item Tie/High Maintenance.
650qA*
650qAC                   if        *inkh
650qAC                   eval      cmdtkn = *on
650qAC                   eval      whse = $pwhse
650qAC                   call      'IT141'
650qAC                   parm                    whse
650qAC                   parm                    $pitem
650qAC                   endif
650jA*
650jA*      F20 - Accept Warning.
650jA*
650jAC                   if        *inku
650jAC                             or *inkj
650jAC                   eval      ovrrid = *on
650jAC                   else
650jAC                   eval      ovrrid = *off
650jAC                   endif
     C     endcm3        endsr
700dA*----------------------------------------------------------------
700dA*
700dA*  ZZCMD4   User defined command keys for screen 4.
700dA*
700dAC     zzcmd4        begsr
700dAC                   eval      cmdtkn = *off
700dA*
700dAC     endcm4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMDCNL User defined command keys for cancel window warning
     *
     C     zzcmdCnl      begsr
     C     endcmCnl      endsr
     *----------------------------------------------------------------
     *
     *  ZZCNVWGT  Setup converted weight field.
     *
     C     zzcnvwgt      begsr
     *
     *
     * If item options is setup as kgs and user enters kgs no conversion
     * If item options is setup as kgs and user enters lbs need conversion
     * If item options is setup as lbs and user enters lbs no conversion
     * If item options is setup as lbs and user enters kgs need conversion
700cA /free
700cA   select;
700cA     when svopwum = 'KGS'
700cA      or svopwum = 'kgs'
700cA      or svopwum = 'Kgs';
700cA       if KiloLbs = 'K';
700cA         eval cnvwgt = w1dwgt;
700ca       else;
700cA         eval(h) cnvwgt = w1dwgt / kgs2lbs;
700cA       endif;
700cA     other;
700cM       if KiloLbs = 'K';
700cM         eval(h) cnvwgt = w1dwgt * kgs2lbs;
700cM       else;
700cM         eval cnvwgt = w1dwgt;
700cM       endif;
700cA   endsl;
700cA /end-free
     *    If in kilograms mode, convert into pounds for processing.
700cDC*                  if        KiloLbs = 'K'
700cDC*                  eval(h)   cnvwgt = w1dwgt * kgs2lbs
700cDC*                  else
700cDC*                  eval      cnvwgt = w1dwgt
700cDC*                  endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Slot.
     *
     C                   when      row# = 18
     C                   eval      *in13 = *on
     C                   eval      $lcmd = '*BOTH   '
     C                   eval      $lwhs2 = $pwhse
     C                   eval      $lwhd2 = $itwhdp
     C                   eval      $litm2 = $pitem
     C                   eval      $ldisp = *blanks
     C                   eval      $ldesg = $itdesg
     C                   eval      $lst = 'V '
     C                   eval      $lsdef = *blanks
     C                   eval      $lactv = *blanks
     C                   call      'SL900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1slot = $ldisp
     C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
     C                   other
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     *
     *
     *      F8  - Item Tie/High Maintenance.
     *
     C                   if        *inkh
     C                   eval      cmdtkn = *on
     C                   eval      whse = $pwhse
     C                   call      'IT141'
     C                   parm                    whse
     C                   parm                    $pitem
     C                   endif
     *
     *
     *      F9  - Scan Item Catchweight labels.

     C                   if        *inki  and
     C                             ($itcwgt = 'Y'
     C                              or $itcwgt = 'S')
     C                   eval      cmdtkn = *on
     C                   eval      $lcmd = '*CHANGE '
     C                   eval      $lwhs3 = $pwhse
     C                   eval      $lpo3 = $ppo
     C                   eval      $lseq = $pseq
     C                   eval      $litm3 = $pitem
     C                   eval      $lqyr1 = w1qrc1
     C                   eval      $lqyr2 = w1qrc2
     C                   eval      $lqyr3 = w1qrc3
     C                   eval      $lcwte = *zeros
     C                   eval      $lcwtt = *zeros
     C                   eval      $lcwta = *zeros
     C                   call      'CW122'
     C                   parm                    $lparm
     *
     *    Load weight from entry program / Change flag to show not avg.
     C                   eval      w1dwgt = $lcwtt
     C                   eval      w1avg = 'N'
700cA*    If weight is returned, set to default item options UOM mode
700cM*    If weight is returned, force 'pounds' mode.-700c changed and
700cA*    We no longer force the mode to pounds mode.
700cAC                   if        $lcwtt > 0
700cA /free
700cA   select;
700cA     when svopwum = 'KGS'
700cA      or svopwum = 'kgs'
700cA      or svopwum = 'Kgs';
700cA       KiloLbs = 'K';
700cA       W1KgLb  = svopwum;
700cA     other;
700cA       KiloLbs = 'P';
700cA       W1KgLb  = 'Lbs';
700cA   endsl;
700cA   exsr setupcmdln1;
700cA /end-free
     C                   endif
     C                   endif
     *
     *
     *      F11 - Manufacturer code decipher
     *
     c                   if        *inkk and
     c                             not $bcExpDSent and not $bcProdDSent
     C                   eval      $lexpdat = 0
     C                   eval      $lmfrdat = 0
     C                   eval      $lrtn = ' '
      * f11 is only valid on date sensitive items
     c                   If        $itflgd = 'Y' or $immflg = 'Y'
     c                   eval      $lmfr#    = phven
     c                   eval      $lmfritem = pdvitm
     c                   eval      $ldakitem = pditem
     c                   eval      $lupc     = w1upcd
     c                   eval      ddcode = *off
     c                   call      'MF200'                              66
     C                   parm                    $lparm
     C                   parm      0             $lexpdat          6 0
     C                   parm      0             $lmfrdat          6 0
     C                   parm                    $lupc            20
     C                   parm      ' '           $ldecvalue       15
     c                   else
     c                   exsr      zm13250
     c                   endif
      * Set ddcode if date returned is invalid
     c                   if        $lrtn <> *blanks and $lrtn <> 'OK'
     c                   select
     c                   when      $lexpdat = 0 and $lmfrdat = 0
     c                   eval      ddcode = *on
640eAc                   eval      w1exdt = 0
640eAc                   eval      w1mfdt = 0

     c                   when      $lexpdat <> 0
     c                   eval      $cvcmd = '*MDYEDT'
     c                   move      $lexpdat      $cvd6i
     c                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      ddcode= *on
     c                   endif

     c                   when      $lmfrdat <> 0
     c                   eval      $cvcmd = '*MDYEDT'
     c                   move      $lmfrdat      $cvd6i
     c                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      ddcode= *on
     c                   endif
     c                   other
     c
     c                   endsl
     c                   endif
     c                   exsr      zzmfrdates
     C                   eval      w1exdt = $lexpdat
     c                   if        $immflg = 'Y'
     C                   eval      w1mfdt = $lmfrdat
     c                   endif
     c                   endif
     *
     *      F17 - Display receiving log.
     *
     C                   if        *inkr  and
     C                             rcverr = *on
     C                   call      'PO133'
     C                   parm      '*VIEW   '    $mcmd             8
     C                   parm      $pwhse        $mwhse            3 0
     C                   parm      $ppo          $mpo              9
     C                   parm      $pitem        $mitem           15
     C                   parm      *zeros        $mrcdt            8 0
     C                   parm      *zeros        $mrctm            6 0
     C                   parm      *blanks       $mdev            10
     C                   parm      *blanks       $muser           10
     C                   eval      cmdtkn = *on
     C                   endif
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                             or *inkj
     C                   eval      ovrrid = *on
     c                   if        expdwarn = *on
     c                   eval      diffexpd = *on
     c                   eval      expdovr = *on
     c                   endif
     c                   if        lotwarn = *on
     c                   eval      difflot = *on
     c                   eval      lotovr = *on
     c                   endif
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *     ZZCVQY - Convert receive qty's to string for msg display
     *
     C     zzcvqy        begsr
     C                   call      'CVTQTY'
     C                   parm                    $ccmd             8
     C                   parm                    $cprg            10
     C                   parm                    $cqty1            7 0
     C                   parm                    $cqty2            7 0
     C                   parm                    $cqty3            7 0
     C                   parm                    $cum1             2
     C                   parm                    $cum2             2
     C                   parm                    $cum3             2
     C                   parm                    $cqstr           10
     C                   parm                    $custr           17
     C                   parm                    $crtn             8
     C                   parm                    $cerm
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
700dA*----------------------------------------------------------------
700dA*
700dA*  ZZDFT4   Get default values for add.
700dA*
700dAC     zzdft4        begsr
700dA /free
700dA   // setup which fields are displayed
700dA   if needb1 = *on;
700dA     w1bupc1 = ' ';
700dA     w1buom1 = $itum2;
700dA     *in38 = *off;
700dA   else;
700dA     *in38 = *on;
700dA   endif;
700dA   if needb2 = *on;
700dA     w1bupc2 = ' ';
700dA     w1buom2 = $itum3;
700dA     *in39 = *off;
700dA   else;
700dA     *in39 = *on;
700dA   endif;
700dA   cmdln1 = cmdln(10);
700dA /end-free
700dAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1po = pdpo
     C                   eval      w1item = pditem
     C                   eval      w2vitm = pdvitm
     C                   eval      w1whse = $pwhse
     C     w1whse        chain     warehs                             79
     C                   if        not *in79
     C                   eval      w1fdsc = whdesc
     C                   else
     C                   eval      w1fdsc = *blanks
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *    Default FIFO entered date if entry is allowed.
     C                   if        not *in89
     C                   move      today         $cvd8i
     C                   eval      $cvcmd = '*CMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        todayo
     *
     C                   eval      w1fifo = todayo
     C                   else
     C                   eval      w1fifo = 0
     C                   endif
     *    Protect,non-display lot code entry field.
     C                   eval      *in88 = *on
     *    Retrieve Item Lot/license plate tracking info.
     C                   eval      $lcmd = *blanks
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = pditem
     C                   call      'GETLLP'
     C                   parm                    $lparm
     *
     C                   select
     *    Lot/license plate tracking values found.
     C                   when      $lrtn = '*OK     '
     C                   if        $llot = 'Y'
     c                             or $plot <> ' '
     C                   eval      lottrk = '*YES'
     *    Display lot code entry field.
     C                   eval      *in88 = *off
     C                   else
     C                   eval      lottrk = '*NO '
     C                   endif
     C                   if        $lltrk = 'Y'
     C                   eval      lictrk = '*YES'
     C                   else
     C                   eval      lictrk = '*NO '
     C                   endif
     C                   other
     C                   eval      lottrk = '*NO '
     C                   eval      lictrk = '*NO '
     C                   endsl
     *
     C                   eval      w1po = pdpo
     C                   eval      w1item = pditem
     C                   eval      w2vitm = pdvitm
     C                   eval      w1whse = $pwhse
     C     w1whse        chain     warehs                             79
     C                   if        not *in79
     C                   eval      w1fdsc = whdesc
     C                   else
     C                   eval      w1fdsc = *blanks
     C                   endif
     C                   if        $pcmd = '*QUICK  '
     C                   eval      w1qrc1 = pdqor1
     C                   eval      w1qrc2 = pdqor2
     C                   eval      w1qrc3 = pdqor3
     C                   else
     C                   eval      w1qrc1 = 0
     C                   eval      w1qrc2 = 0
     C                   eval      w1qrc3 = 0
     C                   eval      w1exdt = 0
     C                   endif
     C                   eval      w1avg = 'N'
     C                   eval      iatest = *blanks
     C                   eval      iaflag = *off
     C                   eval      w1mfdt = 0
     C                   eval      w1lotc = *blanks
     C                   eval      woexdt = 0
     C                   eval      woindt = 0
     c                   if        moretoscan <> *on
     C                   eval      w1brand = *blanks
     c                   endif
     *
     *   Get Unit of measure fields
     *
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     C                   if        client = saval
     C                   eval      *in63 = *off
     C*   Convert quantity to string.
     C                   eval      $ccmd = '*QTY2STR'
     C                   eval      $cprg = #prog
     C                   eval      $cqty1 = pdqor1
     C                   eval      $cqty2 = pdqor2
     C                   eval      $cqty3 = pdqor3
     C                   exsr      zzcvqy
     C                   eval      woqor = $cqstr
     C*
     C                   else
     C                   eval      *in63 = *on
     C                   eval      woqor = *blanks
     C                   endif
     *
     C                   eval      w1dwgt = 0
     *
     *
     *   Enable/Disable catch weight fields.
     *
     C                   eval      vrfycw = *off
     C                   eval      *in82 = *off
     *
     *     First, see if catch weight entry is allowed.
     *
     C                   if        ($itcwgt <> 'Y'  and
     C                              $itcwgt <> 'S') or
     C                             svcwen = '3'
     C                   eval      *in95 = *on
     C                   eval      vrfycw = *off
     C                   else
     C                   eval      *in95 = *off
     C                   eval      vrfycw = *on
     C                   endif
     *
     *     Then see if we should block entry ...
     *       because catch weight previously entered.
     *
     C                   if        svcwen = '2'  and
     C                             pddwgt <> 0
     C                   eval      *in82 = *on
     C                   eval      *in95 = *on
     C                   eval      vrfycw = *off
     C                   endif
650sA*     if uci receiving and item is catch weight must get catchweigt
650sA*       either from barcode or from entry.
650sAC                   if        $itcwgt = 'Y' and
650sAC                             $ifucicde = '2'
650sAC                   eval      *in95 = *off
650sAC                   eval      vrfycw = *on
650sAC                   endif
     *
     *     Then see what value is to be entered (1=Choice,2=Ttl,3=Avg)
     *
     C                   select
     C                   when      svcwtp = '2'
     C                   eval      *in81 = *on
     C                   eval      w1avg = 'N'
     C                   eval      wocrcv = cwt(2)
     C                   when      svcwtp = '3'
     C                   eval      *in81 = *on
     C                   eval      w1avg = 'Y'
     C                   eval      wocrcv = cwt(3)
     C                   other
     C                   eval      *in81 = *off
     C                   eval      w1avg = 'N'
     C                   eval      wocrcv = cwt(1)
     C                   endsl
     *
     *   Enable/Disable expiration date fields.
     *
     C                   if        $itflgd <> 'Y'
     C                   eval      *in96 = *on
     C                   else
     C                   eval      *in96 = *off
     C                   endif
     *
     *   Get the picking slot for the item.
     *
     *
     C                   if        $itstyp = 'P'
     C                   eval      $scmd = '*LAST'
     C                   else
     C                   eval      $scmd = '*FIRST'
     C                   endif
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      $itwhse       $swhse
     C                   parm                    #sitem
     C                   parm                    woslot
     C                   parm                    $saisl            3
     C                   parm                    $sloc             3 0
     C                   parm                    $srlvl            2 0
     C                   parm                    $shand            2
     C                   parm                    $srtn             8
     *
     C                   eval      w1slot = *blanks
     *
     *   Enable Mfg date and disable Exp date, if Mfg date flag = 'Y'
     *
     C*    imkey         chain     itemmsc                            79
     C                   if        not *in75  and
     C                             $immflg = 'Y'
     C                   eval      *in87 = *off
     C                   eval      *in96 = *on
     C                   else
     C                   eval      *in87 = *on
     C                   endif
640bDC*                  if        *in79
640bMC                   if        *in75
     C                   eval      $immflg = 'N'
     C                   endif
      * load up fields from uci incoming information
      * Expiration Date
     c                   If        not *in96
     c                   if        $pexpdt > 0
     C                   move      $pexpdt       $cvd6i
     C                   eval      $cvcmd = '*YMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1exdt
     c                   endif
     c                   endif
      * Manufacturing Date
     c                   If        $immflg = 'Y'
     c                   if        $pmfgdt > 0
     C                   move      $pmfgdt       $cvd6i
     C                   eval      $cvcmd = '*YMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1mfdt
     c                   endif
     c                   endif
      * Lot
     c                   If        lottrk = '*YES'
     c                   if        $pLot <> ' '
     c                   eval      w1lotc = $plot
     c                   endif
     c                   endif
      * Catch Weight
     c                   If        vrfycw = *on
     c                   if        $pwgt > 0
     c                   eval      w1dwgt = $pwgt
     c                   endif
     c                   endif
      * assume qty1 if uci receiving
720aAc                   select
720aAc                   when      uputyp = 'N'
720aAc                   eval      w1qrc1 = 1
720aAc                   when      uputyp = '1'
720aAc                   eval      w1qrc2 = 1
720aAc                   when      uputyp = '2'
720aAc                   eval      w1qrc3 = 1
720aAc                   other
720aMc                   eval      w1qrc1 = 1
720aAc                   endsl
720aDc*                  eval      w1qrc1 = 1
     c                   eval      *in71 = *on
     c                   eval      *in01 = *off
      * Cross Dock - use temporary license
     c                   if        $pxd = 'XD'
     c                   eval      w1lcns = 'Cross Dock'
     c                   eval      templcns = 'XD' +  #jobnbr
     c                   eval      *in73 = *on
     c                   eval      *in15 = *off
     c                   else
     c                   eval      *in73 = *off
     c                   eval      templcns = ' '
     c                   endif
700bAc                   if        sprcv = *on
700bAc                   eval      w1lcns = 'Pick Slot'
700bAc                   eval      templcns = 'PS' +  #jobnbr
700bAc                   eval      *in73 = *on
700bAc                   eval      *in15 = *off
700bAc                   endif
      * pos cursor to brand if brand is used
     c                   if        *in74 = *off
     c                   eval      *in16 = *on
     c                   else
     c                   eval      *in16 = *off
     c                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C     fileky        chain     record                             79
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     *
     *   If viewing, release record.
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C     *loval        setll     record
     C                   endif
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 1.
     *
     C     zzget2        begsr
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUCI    Write UCI data
     *
     C     zzuci         begsr
     c                   if        $ldecvalue = ' '
     c                   exsr      zzmfrdates
     c                   endif
     C                   if        $immflg = 'Y'
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        womfdt


     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1exdt

     *
     C                   endif
     * add records to uci file
     *
     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.
     *
     C                   eval      $code = #curruser
     C                   eval      $whse = *zeros
     C                   eval      $emp# = *zeros
     C                   eval      $fnam = *blanks
     C                   eval      $init = *blanks
     C                   eval      $lnam = *blanks
     C                   eval      $whdp = *blanks
     C                   eval      $styp = *blanks
     C                   eval      $shft = *blanks
     C                   eval      $crew = *blanks
     C                   eval      $nhrs = 0
     C                   eval      $rtn = *blanks
     C                   call      'GETUSER'
     C                   parm                    $code
     C                   parm                    $whse
     C                   parm                    $emp#
     C                   parm                    $fnam
     C                   parm                    $init
     C                   parm                    $lnam
     C                   parm                    $whdp
     C                   parm                    $styp
     C                   parm                    $shft
     C                   parm                    $crew
     C                   parm                    $nhrs
     C                   parm                    $rtn
      /free
        // need to determine if the licinfo record already exist for
        // this lcns/lot/exp date - keep checking until we find a match
        // or no more licinfo records exist - if no match and no licinfo
        // exist need to write the next available seq# to licinfo.
        // if licinfo record exist - just update the qty and the weight
        select;
          when moretoscan = *on and difflot = *on  or
               moretoscan = *on and diffexpd = *on;
            exsr zzlicinfochk;
          when moretoscan = *on and difflot <> *on and diffexpd <> *on;
            exsr zzlicinfoseq;
        endsl;

        if licinfoupd <> *on and difflot = *on or
           licinfoupd <> *on and diffexpd = *on or
           moretoscan <> *on;
          exsr zzlicinfonew;
        endif;

        exsr clr$uciinfo;
        $uiWhse = $pwhse;
        $uiItem = $pitem;
        $uiuci = w1uci;
        ucilic#($unext: $pwhse);
        unexta = %editc($unext:'X');
        $uiuciLcns = 'U:' + unexta;
700bD   //if $pxd = ' ';
700bM   if $pxd = ' '
700bA      and sprcv = *off;
          $uiLcns = w1lcns;
        else;
          $uiLcns = templcns;
        endif;
        if difflot = *on or
          diffexpd = *on;
          $uiseq = $lnseq;
        else;
          $uiseq = 1;
        endif;
        $uiSerial = $bcSer#;
720aA   if $bcGTin = *blanks;
720aA      $uiaGtin = 0;
720aA   else;
720aA      $uiaGtin   = %DEC($bcGTin:14:0);
720aA   endif;
720aA   $uiaLot    = $bclot;
720aA   $uiaUTyp   = uputyp;
720aA   $uiaSlUTyp = uputyp;
720aA   if saveexpd = 0;
720aA      $uiaExpD   = expd;
720aA   else;
720aA      $uiaExpD = saveexpd;
720aA   endif;
720aA   $uiaEntD   = today;
        // if user entered weight use that/ if uci had weight use that
700cA   // 700c metric changes
        select;
700cD     //when w1dwgt > 0;
700cM     when w1dwgt > 0 and kilolbs = 'P';
            $uiwgtlbs = w1dwgt;
          when $bcPNtLbSent = *on;
            $uiwgtlbs = $bcPNtLb;
          other;
            $uiwgtlbs = 0;
        endsl;
        // Weight KG  - only if uci barcode contained KG
700cA   // 700c metric changes - if item options weight uom = kgs
700cA   select;
700cA     when svopwum = 'KGS'
700cA      or  svopwum = 'kgs'
700cA      or  svopwum = 'Kgs';
700cA       select;
700cA         when w1dwgt > 0 and kilolbs = 'K';
700cA           $uiwgtkgs = w1dwgt;
700cA         when w1dwgt > 0 and kilolbs = 'P';
700cA           $uiwgtkgs = cnvwgt;
700cA         when $bcPNtkgSent = *on;
700cA           $uiwgtkgs = $bcPNtkg;
700cA         other;
700cA           $uiwgtkgs = 0;
700cA       endsl;
700cA     other;
            if $bcPNtKgSent = *on;
              $uiWgtKgs = $bcPntKg;
            else;
              $uiWgtKgs = 0;
            endif;
700cA   endsl;
        $uiSelTrn# = 0;
        $uiSelLbl# = 0;
        $uiSelOrd = 0;
        $uiSelSeq = 0;
        $uiSelCSeq = 0;
        $uiSelTrax = ' ';
        $uiCrtBy = '1';
720aA   // Lets add some more stuff for tracking
720aA   $uiaction = 'RCV';
720aA   $uiaolcns = $uilcns;
720aA   $uialcns = $uilcns;
720aA   $uiaoseq = $uiseq;
720aA   $uiscan = 'Y';

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%ADD';
        $drisys2upd = 'D';
        ck4err = *on;
        zmflag  = *off;
        exsr zzzdricop;
        if error;
          uciExists = *on;
          error = *on;
          errmsg= desc(11);
          exsr zm02;
          leavesr;
        else;
          UciExists = *off;
          error = *off;
        endif;

        // save the values from the first scan to be used for the license
        if moretoscan <> *on;
          if $immflg = 'Y';
            savew1mfdt = w1mfdt;
          endif;
          if $itflgd = 'Y';
            savew1exdt = w1exdt;
          endif;
          saveexpd = expd;
          savelotc = w1lotc;
        endif;
700cD   //savewgt  = savewgt + w1dwgt;
700cM   savewgt  = savewgt + cnvwgt;
        saveqty  = saveqty + 1;
        // scan some more uci barcodes
        // save first scanned lot and dates
        if moretoscan <> *on;
          FirstLot# = w1lotc;
          FirstDktExpdt = expd;
        endif;
        moretoscan = *on;
720bA   *in80 = *on;
        nxtscr = '01 ';
        $puci = ' ';
        w1uci = ' ';
650kA   savew1uci = ' ';
650kA   savew1uci = ' ';
        ovrrid = *off;
        difflot = *off;
        diffexpd = *off;
        lotwarn = *off;
650rA   UPCwarn = *off;
        expdwarn = *off;
        lotovr  = *off;
650rA   UPCovr  = *off;
        expdovr  = *off;
        licinfoupd = *off;

      /end-free
     c
     C     enduci        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq
     C                   kfld                    $pitem
     *
     *  Define partial key for main file.
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     *
     *  Define key for SLOT2 file.
     *
     C     slkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $itwhdp
     C                   kfld                    w1slot
     *
     *  Define key for POHDR file.
     *
     C     phkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     *
     *  Define key for PIRITEM file.
     *
     C     ittkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *
     *  Define partial key for item tie/high definition file.
     *
     C     partk2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *     OPTIONS
     *
     C     opkey         klist
     *                    KFLD           $PWHSE
     C                   kfld                    wkwhse
     C                   kfld                    ocode
     *
     *
     C     povky1        klist
     C                   kfld                    $pwhse
     C                   kfld                    kyven#
     C                   kfld                    kywhdp
     *
     *     UPC
     *
     C     upcky         klist
     C                   kfld                    $pwhse
     C                   kfld                    w1upc
     *
     C     upcky1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    phven
     *
     C     upcky2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    ckupc
     *
     C     upcky3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    w1upc
     C                   kfld                    phven
700dAC     upcky3U       klist
700dAC                   kfld                    $pwhse
700dAC                   kfld                    $pitem
700dAC                   kfld                    w1upc
700dAC                   kfld                    phven
700dAc                   kfld                    uputyp
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     *
     *  Define key for ITEMMSC file.
     *
     C     imkey         klist
     C                   kfld                    $itwhse
     C                   kfld                    $ititem
     *
     *  Define key for LABEL2  file.
     *
     C     lbkey         klist
     C                   kfld                    $rord
     C                   kfld                    $pwhse
     *
     *  Define key for POCTYPE file.
     *
     C     keypoc        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq
     C                   eval      forevr = *on
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $cvprg = #prog
     C                   eval      #pgmq = #prog
     C                   eval      $rprg = #prog
      * determine if mfr decipher is available to client
     c                   eval      $lcmd = '*OPEN'
     c                   call      'MF200'                              66
     C                   parm                    $lparm
     C                   parm      0             $lexpdat          6 0
     C                   parm      0             $lmfrdat          6 0
     C                   parm                    $lupc            20
     C                   parm      ' '           $ldecvalue       15
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcpmq
     *
     C                   setoff                                       kckl
     C                   eval      dtchk = *off
     C                   eval      dtchk2 = *off
     C                   eval      qtchk = *off
     C                   eval      wtchk = *off
     C                   eval      upchk = *off
     C                   eval      upchk2 = *off
     C                   eval      expd = 0
700dAC                   eval      needb1 = *off
700dAC                   eval      needb2 = *off
     *    Setup command display line 2.
     C                   eval      cmdln2 = cmdln(7)
     *
     *   Cannot receive an item, if the PO is ready for export.
     *
     C     phkey         chain(n)  pohdr                              79
     C                   if        not *in79  and
     C                             phstat = '3'
     C                   exsr      zm3226
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   goto      endinz
     C                   endif
     *
     *   Set Move In FIFO flag.
     C                   if        phvnam = 'MOVEIN'  or
     C                             phvnam = move1  or
     C                             phvnam = move2
     C                   eval      *in89 = *off
     C                   else
     C                   eval      *in89 = *on
     C                   endif
     *
     *   Remove any existing catchweight entry records.
     C                   exsr      zzdlcw
     *
     C                   eval      lflag = *off
     C                   exsr      zzxopt
     C                   exsr      zzlcns
     *
     C                   eval      ocode = '*SYSTEM '
     C                   eval      wkwhse = 0
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw = 'N'
770aAC                   eval      opdckv = 'N'
     C                   endif
770aA
770aAc                   if        opdckv = 'Y'
770aAc                   eval      dockvue = *on
770aAc                   else
770aAc                   eval      dockvue = *off
770aAc                   endif
770aA
     *
     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.
     *
     C                   call      'GETUSER'
     C                   parm      #user         $code            10
     C                   parm      0             $whse             3 0
     C                   parm      0             $emp#             5 0
     C                   parm      *blanks       $fnam            15
     C                   parm      *blanks       $init             1
     C                   parm      *blanks       $lnam            20
     C                   parm      *blanks       $whdp             5
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $shft             6
     C                   parm      *blanks       $crew             6
     C                   parm      0             $nhrs             3 1
     C                   parm      *blanks       $rtn              8
     *
     *   Select first screen to display.
     *
     C                   eval      w1upcd = *blanks
     C                   if        $pupc <> *blanks
     C                   eval      *in92 = *on
     *
     *    Left adjust UPC for better and easier viewing.
     C                   move(p)   $pupc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFTNOZ'    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         w1upcd
     C                   endif
     *
     C                   movel     w1upcd        w1upc
     *
     *       Condition function key on display.
     *
     C                   if        $pcmd = '*CHANGE '
     C                   eval      *in55 = *on
     C                   else
     C                   eval      *in55 = *off
     C                   endif
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '  or
     C                             $pcmd = '*QUICK  '
     C                   exsr      scr01i

     *    For Saval ...
     C                   if        client = saval
     C                   eval      kyven# = phven
     C                   eval      kywhdp = $itwhdp

     C     povky1        chain(n)  povpck                             79
     C                   if        not *in79
     *      This will try and create a virtual slot if necessary.

     C                   if        sprcv = '1'
     C                             and $srtn = '*NONE'
     C                   eval      wodisp = povdsp
     C                   exsr      zzvpck

     C                   eval      woslot = $sldisp

     C                   endif

     C                   endif
     C                   endif

     *    For Jordano's ...

     C                   if        client = jordanos

     *      See if the is a special Bread PO.

     C                   if        phven = 3194
     C                   eval      jdobread = *on
     C                   else
     C                   eval      jdobread = *off
     C                   endif

     *      For Bread PO, make sure slot exists for item.
     *      This will try and create a virtual slot if necessary.

     C                   if        jdobread
     C                             and sprcv = '1'
     C                             and $srtn = '*NONE'

     C                   call      'CRTVPICK'
     C                   parm      #prog         $vprg            10
     C                   parm      $pwhse        $vwhse            3 0
     C                   parm      'REF'         $vwhdp            5
     C                   parm      '958A'        $vdisp           12
     C                   parm      #sitem        $vitem           15
     C                   parm      ' '           $vrtn            10
     C                   parm      ' '           $verm            60
     C                   if        $vrtn <> 'VRTPCKCRT'
     C                             and $vrtn <> 'INSLOT'
     C                   eval      error = *on
     C                   eval      errmsg = 'Err: Cannot create pick slot '
     C                                    + '(' + %trim($vrtn) + ')'
     C                   exsr      zm0105s
     C                   goto      endinz
     C                   endif

     C                   eval      woslot = $vdisp

     C                   endif

     C                   endif
     *
     *    Confirm Retail UPC on file before continuing with receiving.
     *
     C                   if        svrupc = 'Y'
     C                   exsr      zzrupc
     C     error         cabeq     *on           endinz
     C                   endif
     *
     C                   endif
     *
     c                   exsr      getitem
700cA * code was moved to subr so it could be used for scr03i
700cAc                   exsr      setupcmdln1
     *
     C                   if        $pcmd = '*VIEW   '
     C                   endif

     C     endinz        endsr
     *----------------------------------------------------------------
     *
     *  ZZDLCW   Delete catchweight entry records.
     *
     C     zzdlcw        begsr
     *
     C                   eval      $lwhs3 = $pwhse
     C                   eval      $lpo3 = $ppo
     C                   eval      $lseq = $pseq
     C                   call      'DELTMPCW'
     C                   parm                    $lparm
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZLCNS   Get use generic license option
     *
     C     zzlcns        begsr
     *
     C                   eval      sprcv = *off
     *   Get use generic license option.
     C                   eval      lflag = *off
     C                   eval      svexck = *on
     C                   eval      svcwen = *on
     C                   eval      svcwtp = *on
     C                   eval      svcwfr = 'N'
     C                   eval      svrupc = 'N'
     C                   eval      ocode = '*RCVLBL '
     C                   eval      wkwhse = $pwhse
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opplcn = 'Y'
     C                   eval      lflag = *on
     C                   endif
     C                   if        $pcmd = '*CHANGES'
     C                   eval      $pcmd = '*CHANGE '
     C                   eval      sprcv = *on
     C                   endif
     C                   eval      svexck = opexck
     C                   eval      svcwen = opcwen
     C                   eval      svcwtp = opcwtp
     C                   eval      svcwfr = opcwfr
     C                   eval      svrupc = oprupc
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *  ZZLICINFOCAN  User cancelled - licinfo needs to be deleted
     *----------------------------------------------------------------

      /free
        begsr zzlicinfocan;

          exsr clr$licinfo;

          $lnwhse  = $pwhse;
700bD     //if $pxd = ' ';
700bM     if $pxd = ' '
700bA        and sprcv = *off;
            $lnlcns  = w1lcns;
          else;
            $lnlcns  = templcns;
          endif;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%DELETEALL';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZLICINFOCHK  Check to see if licinfo exist for this lcnslot/exp
     *----------------------------------------------------------------

      /free
        begsr zzlicinfochk;

          Lastseq  = 1;
          dow forevr = forevr;

          exsr clr$licinfo;

          $lnwhse  = $pwhse;
700bD     //if $pxd = ' ';
700bM     if $pxd = ' '
700bA        and sprcv = *off;
            $lnlcns  = w1lcns;
          else;
            $lnlcns  = templcns;
          endif;
          $lnseq  = lastseq + 1;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
            leave;
          else;
            // compare lot and date fields
            if $lnlot = w1lotc and
               $lnexpdate = expd;
              // add qty and weight, update licinfo
              $lnttllbs = $lnttllbs + w1dwgt;
              //$lnrcvqty = $lnrcvqty + 1;
              $lnseqqty = $lnseqqty + 1;
              $dricommand = '*LICINFO';
              $drisubcmd  = '%CHANGES';
              $drisys2upd = 'D';
              ck4err = *on;
              exsr zzzdricop;
              licinfoupd = *on;
              leave;
            endif;
            eval lastseq = lastseq + 1;
          endif;

        enddo;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZLICINFOSEQ  Used to get the current lnseqqty for accumulator
     *----------------------------------------------------------------

      /free
        begsr zzlicinfoseq;

          exsr clr$licinfo;

          $lnwhse  = $pwhse;
700bD     //if $pxd = ' ';
700bM     if $pxd = ' '
700bA        and sprcv = *off;
            $lnlcns  = w1lcns;
          else;
            $lnlcns  = templcns;
          endif;
          $lnseq  = 1;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
          else;
            // accumulate the lnseqqty field
            $lnseqqty = $lnseqqty + 1;
            $dricommand = '*LICINFO';
            $drisubcmd  = '%CHANGES';
            $drisys2upd = 'D';
            ck4err = *on;
            exsr zzzdricop;
            licinfoupd = *on;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZLICINFONew Update New format of LICINFO
     *----------------------------------------------------------------

      /free
        begsr zzlicinfonew;

          // Write out standard license information
          exsr clr$licinfo;

          $lnwhse  = $pwhse;
700bD     //if $pxd = ' ';
700bM     if $pxd = ' '
700bA        and sprcv = *off;
            $lnlcns  = w1lcns;
          else;
            $lnlcns  = templcns;
          endif;

          if difflot or diffexpd;
            $lnseq = lastseq + 1;
            $lnseqqty = $lnseqqty + 1;
            //$lnrcvqty = 1;
            $lnttllbs = w1dwgt;
          else;
            $lnseq = 1;
            $lnseqqty = 1;
          endif;
          $lnpo = $ppo;
          $lnposeq = $pseq;
          $lnitem = $pitem;
          // LNRCVTYP notes
          // 1 = Manual quantity (original method)
          // 2 = Manual quantity with initial GS1 scan
          // 3 = UCI using Mfg GS1 barcodes
          // 4 = UCI using Internal GS1 barcodes (start with 99)
          // 5 = ASN file

          select;
            when $ifucicde = ' ';
              $lnrcvtyp = '1';
            when $ifucicde = '1';
              $lnrcvtyp = '1';
            when $ifucicde = '2';
              $lnrcvtyp = '3';
            when $ifucicde = '3';
              $lnrcvtyp = '4';
            // don't know exactly what 2 will represent
          endsl;
          $lnrcvtrn# = 0;
          $lnrcvlbl# = 0;

          select;
            when w1fifo <> 0;
              $lnentdate = wofifo;
            when w1mfdt <> 0;
              $lnentdate = womfdt;
            other;
              $lnentdate = woexdt;
          endsl;

          if wofifo > 0;
            $lnenttype = '*FIFODT';
          else;
            if $itflgd = 'Y';
              select;
                when $imuday > 0 or
                     $imdday > 0;
                  if $immflg = 'Y';
                    $lnenttype = '*MFGDTE';
                  else;
                    $lnenttype = '*USEDTE';
                  endif;
                other;
                  $lnenttype = '*EXPDTE';
              endsl;
            else;
              $lnenttype = '*ENTDTE';
            endif;

            $lndateflag = $itflgd;
            $lnmfgflag = $immflg;

            $lnmfgdays = $immday;
            $lnusrdays = $imuday;
            $lndstdays = $imdday;
          endif;

          $lnmfgdate = womfdt;

          if mexpd > 0;
            $lnmfgexp = mexpd;
          endif;

          if wofifo > 0;
            $lnfifodate = wofifo;
          endif;

          if expd > 0;
            $lnexpdate = expd;
          endif;

          if $ldecvalue > ' ';
            $lnmfgcode = $ldecvalue;
          endif;

          $lnavglbs = 0;

          if W1lotc <> ' ';
            $lnlot = w1lotc;
          endif;

          if w1brand <> ' ';
            $lnbrand = w1brand;
          endif;

650dA       // calculate the PTI.
650dA       if $bclot <> ' ' and $bcgtinsent;
650dA         pplot  = %subst($bclot: 1 : 20);
650dA         calcpti ($bcgtin: pplot: $pmfgdt: pppti);
650dA         if pppti > 0;
650dA           $lnlotPTI4 = %editc(pppti:'X');
650dA           $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
650dA         endif;
650dA       endif;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%ADDS';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZmfrdates  Set manufactures dates
     *
     C     zzmfrdates    begsr
     c                   select
     c                   when      $lmfrdat > 0 and $ldecvalue > ' '
     *
     *  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      $lmfrdat      $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgdte

     *  Create mfg expiration date mfgdate + mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      mfgdte        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mexpd         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     *
     *  Calculate Mfg date if mfg exp date is entered
     *
     c                   when      $lexpdat > 0 and $ldecvalue > ' '

     *
     *  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      $lexpdat      $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mexpd
640aAC                   eval      wkmday = $immday
YHAaA*  Use By date -1 to be used as mfg shelf life days
YHAaAC                   if        client = yhata
YHAaAC                   if        $immday = 0
YHAaAC                             and $imoday > 0
YHAaAC                   eval      wkmday = $imoday - 1
YHAaAC                   endif
YHAaAC                   endif

     *  Create mfg date - date mfg exp date - mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      mexpd         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
640aDC*                  parm      immday        $cddays
640aMC                   parm      wkmday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mfgdte        parm      0             $cddateout
     C                   parm      0             $cdtimeout

640aDc*                  if        immday = 0
640aMc                   if        wkmday = 0
     c                   eval      mfgdte = 0
     c                   endif

     c                   when      w1mfdt > 0 and $itflgd = 'Y'
     *
     *  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgdte

     *  Create mfg expiration date mfgdate + mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      mfgdte        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mexpd         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     c                   when      w1exdt > 0

     *
     *  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mexpd
640aAC                   eval      wkmday = $immday
YHAaA*  Use By date -1 to be used as mfg shelf life days
YHAaAC                   if        client = yhata
YHAaAC                   if        $immday = 0
YHAaAC                             and $imoday > 0
YHAaAC                   eval      wkmday = $imoday - 1
YHAaAC                   endif
YHAaAC                   endif

     *  Create mfg date - date mfg exp date - mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      mexpd         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
640aDC*                  parm      immday        $cddays
640aMC                   parm      wkmday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mfgdte        parm      0             $cddateout
     C                   parm      0             $cdtimeout

640aDc*                  if        immday = 0
640aMc                   if        wkmday = 0
     c                   eval      mfgdte = 0
     c                   endif

     c                   endsl
     C                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZRCVPOCHECK check for started RCVPO Transaction
650bA*
650bAC     zzrcvpocheck  begsr
650bA*
650bA*  See if RCVPO transaction is status 2 - start new if needed
650bA*
650bAC                   call      @crtrcv
650bAC                   parm      '*PO'         $lcmdr           10
650bAC                   parm      '*CHECK '     $lsubcmd         10
650bAC                   parm      $pwhse        @lwhse            3 0
650bAC                   parm      0             $lpcs             5 0
650bAC                   parm      0             $lpallets         5 0
650bAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $ppo              9
650bAC                   parm      $itstyp       $litstyp          1
650bAC                   parm      $itwhdp       $litwhdp          5
650bAC                   parm                    $lrtnr           10
650bAC                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZRCVPOCLOSE  Close RCVPO transaction.
650bA*
650bAC     zzrcvpoclose  begsr
650bAc                   if        rcvpocomplete

650bAc                   select
650bAc                   when      $lrq1 > 0
650bAc                   eval      poppcs = $lrq1
650bAc                   when      $lrq2 > 0
650bAc                   eval      poppcs = $lrq2
650bAc                   when      $lrq3 > 0
650bAc                   eval      poppcs = $lrq3
650bAc                   endsl

650bAC                   call      @crtrcv
650bAC                   parm      '*PO'         $lcmdr           10
650bAC                   parm      '*COMPLETE'   $lsubcmd         10
650bAC                   parm      $pwhse        @lwhse            3 0
650bAC                   parm      poppcs        $lpcs             5 0
650bAC                   parm      $lrpal        $lpallets         5 0
650bAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $ppo              9
650bAC                   parm      $itstyp       $litstyp          1
650bAC                   parm      $itwhdp       $litwhdp          5
650bAC                   parm                    $lrtnr           10
650bAc                   else
650bAc                   eval      $lpcs = 0
650bAC                   call      @crtrcv
650bAC                   parm      '*PO'         $lcmdr           10
650bAC                   parm      '*CLOSE'      $lsubcmd         10
650bAC                   parm      $pwhse        @lwhse            3 0
650bAC                   parm      0             $lpcs             5 0
650bAC                   parm      0             $lpallets         5 0
650bAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $ppo              9
650bAC                   parm      $itstyp       $litstyp          1
650bAC                   parm      $itwhdp       $litwhdp          5
650bAC                   parm                    $lrtnr           10

650bAc                   endif
650bAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZRUPC   Verify Retail UPC on file for item.
     *
     C     zzrupc        begsr
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhs3 = $pwhse
     C                   eval      $lpo3 = $ppo
     C                   eval      $lseq = $pseq
     C                   eval      $litm3 = $pitem
     *
     C                   call      'PO245'
     C                   parm                    $lparm
     *
     C                   select
     C                   when      $lrtn = '*EXIT   '  or
     C                             $lrtn = '*CANCEL '
     C                   eval      error = *on
     *
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZTIHI   Get use Preferred or 1st tie hi record.
     *
     C     zztihi        begsr
     *
     *  GET TIE HI, PREFERRED OR 1ST RECORD.
     C                   eval      done = *off
     C                   eval      wotie = 0
     C                   eval      wohi = 0
650tAC                   eval      wosdef = ' '
     C                   eval      svtie = 0
     C                   eval      svhi = 0
650tAC                   eval      svsdef = ' '
     C                   if        svtie = 0  and
     C                             svhi = 0
     C                   eval      svtie = $idtie(1)
     C                   eval      svhi = $idhigh(1)
650tAC                   eval      svsdef = $idsdef(1)
     C                   endif
     c                   do        5             t
     c                   if        $idpref(t) = 'Y'
     C                   eval      wotie = $idtie(t)
     C                   eval      wohi = $idhigh(t)
650tAC                   eval      wosdef = $idsdef(t)
     c                   leave
     c                   endif
     c                   enddo
     C                   if        wotie = 0  and
     C                             wohi = 0
     C                   eval      wotie = svtie
     C                   eval      wohi = svhi
650tAC                   eval      wosdef = svsdef
     C                   endif
      *
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZTTLE   Accumlate total exception quantity.
     *
     C     zzttle        begsr
     *
     C     fileky        setll     poexcp
     C                   dow       forevr = forevr
     C     fileky        reade     poexcp                                 76
     C                   select
     C                   when      *in76
     C                   leave
     *
     C                   other
     C                   add       peqex1        svqrc1
     C                   add       peqex2        svqrc2
     C                   add       peqex3        svqrc3
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    *IN94=Protect & non-display breakdown1 unit of measure
     *    *IN93=Protect & non-display breakdown2 unit of measure
     *
     *
     C                   eval      *in94 = *off
     C                   eval      *in93 = *off
     C                   eval      wolbl = *blanks
     C                   eval      woitem = *blanks
     C                   eval      wodsc1 = *blanks
     C                   eval      wodsc2 = *blanks
     *
     C                   eval      ssbflg = *off
     C                   eval      wolbls = *blanks
     C                   eval      wositm = *blanks
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     *
     C                   if        *in75
     C                   eval      *in94 = *on
     C                   eval      *in93 = *on
     C                   eval      $itdesc = *blanks
     C                   eval      $itpdsc = *blanks
     C                   eval      wopdsc = *blanks
     C                   eval      wolbl = lbl(4)
     C                   movel     desc(7)       woitem
     C     '-'           cat       woitem:1      woitem
     C     $pitem        cat       woitem:1      woitem
     C                   goto      enduom
     C                   else
     C                   eval      wopdsc = $itpdsc
     C                   exsr      zztihi
     *
     *  Save information about selected item (Item that was sent in)
     *
     C                   eval      #otype = $ittype
     C                   eval      #oitem = $ititem
     C                   eval      #odesc = $itdesc
     C                   eval      #opdsc = $itpdsc
     C                   eval      #oswgt = $itswgt
     C                   eval      #oum1 = $itum1
     C                   eval      #oum2 = $itum2
     C                   eval      #oum2q = $itumq2
     C                   eval      #oswt2 = 0
     C                   if        #oum2q <> 0
     C     $itswgt       div(h)    #oum2q        #oswt2
     C                   endif
     C                   eval      #oum3 = $itum3
     C                   eval      #oum3q = $itumq3
     C                   eval      #oswt3 = 0
     C                   if        #oum3q <> 0
     C     $itswgt       div(h)    #oum2q        #oswt3
     C     #oswt3        div(h)    #oum3q        #oswt3
     C                   endif
     *
     *   Get short UOM descriptions for selected item.
     *
     C                   eval      #osu1 = *blanks
     C                   eval      #osu2 = *blanks
     C                   eval      #osu3 = *blanks
     *
     C                   if        $itum1 <> *blanks
     C     $itum1        chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu1 = umshrt
     C                   else
     C                   movel     $itum1        #osu1
     C                   endif
     C                   endif
     *
     C                   if        $itum2 <> *blanks
     C     $itum2        chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu2 = umshrt
     C                   else
     C                   movel     $itum2        #osu2
     C                   endif
     C                   endif
     *
     C                   if        $itum3 <> *blanks
     C     $itum3        chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu3 = umshrt
     C                   else
     C                   movel     $itum3        #osu3
     C                   endif
     C                   endif
     *
     *   Initialize base information.
     *
     C                   eval      #bitem = $ititem
     C                   eval      #sitem = $ititem
     C                   eval      #bityp = $ittype
     C                   eval      #bdesc = $itdesc
     C                   eval      #bpdsc = $itpdsc
     C                   eval      #bum1 = $itum1
     C                   eval      #bum2 = $itum2
     C                   eval      #bum3 = $itum3
     C                   eval      #bsu1 = #osu1
     C                   eval      #bsu2 = #osu2
     C                   eval      #bsu3 = #osu3
     *
     *   Get SSB item, if one exists
     *
     C                   if        $ittype = ' '
     C                   call      'GETSSB'
     C                   parm      $itwhse       $gwhse            3 0
     C                   parm      $ititem       $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm                    #brtn             8
     *
     C                   if        #brtn = '*FOUND  '
     C                   eval      ssbflg = *on
     C                   eval      #bityp = 'S'
     C                   endif
     C                   endif
     *
     *  If selected item is a Contract, Alias, SSB or Breakdown item . . .
     *    Then get corresponding Base item.
     *
     C                   if        $ittype = 'C'  or
     C                             $ittype = 'A'  or
     C                             $ittype = 'S'  or
     C                             $ittype = 'B'
     C                   call      'GETBASE'
     C                   parm      $itwhse       $gwhse
     C                   parm      $ititem       $gitem
     C                   parm      ' '           #bitem
     C                   parm                    #bityp            1
     C                   parm                    #bdesc
     C                   parm                    #bpdsc
     C                   parm                    #bwhdp
     C                   parm                    #bstyp
     C                   parm                    #bum1             2
     C                   parm                    #bum2
     C                   parm                    #bumq2
     C                   parm                    #bum3
     C                   parm                    #bumq3
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum1            2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn
     C                   endif
     *   Get slot item.
     C                   call      @getsi
     C                   parm      $itwhse       $gwhse
     C                   parm      $ititem       $gitem
     C                   parm      ' '           #sitem           15
     C                   parm                    #sityp            1
     C                   parm                    #sdesc           30
     C                   parm                    #spdsc           15
     C                   parm                    #srtn            10
     C                   parm                    #smsg            60
     *
     *   Get short UOM descriptions for base item.
     *
     C                   if        #bum1 <> #oum1
     C     #bum1         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu1 = umshrt
     C                   else
     C                   movel     #bum1         #bsu1
     C                   endif
     C                   endif
     *
     C                   if        #bum2 <> #oum2
     C     #bum2         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu2 = umshrt
     C                   else
     C                   movel     #bum2         #bsu2
     C                   endif
     C                   endif
     *
     C                   if        #bum3 <> #oum2
     C     #bum3         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu3 = umshrt
     C                   else
     C                   movel     #bum3         #bsu3
     C                   endif
     C                   endif
     *
     *
     *   Set indicators to protect breakdown quantities.
     *
     C                   if        $itflg1 = 'N'  and
     C                             ssbflg = *off
     C                   eval      *in94 = *on
     C                   endif
     C                   if        $itflg2 = 'N'  and
     C                             ssbflg = *off  or
     C                             $itflg2 = 'N'  and
     C                             ssbflg = *on  and
     C                             $itum3 = *blanks
     C                   eval      *in93 = *on
     C                   endif
     *
     *   When dealing with an SSB item, the quantity is actually
     *   received into the "normal" screen quantity. If a third
     *   breakdown is allowed, then that will be received into the
     *   breakdown 1 quantity on the screen. The second breakdown
     *   screen quantity is always protected for an SSB item.
     *
     C                   if        $ittype = 'S'  and
     C                             $itflg2 = 'Y'
     C                   eval      *in94 = *off
     C                   endif
     *
     C                   if        $ittype = 'S'
     C                   eval      *in93 = *on
     C                   endif
     *
     *   Create label for selected item
     *
     *     If selected item is a SSB item . . .
     *        Then display the breakdown 1 UOM.
     *        Otherwise use the normal UOM.
     *
     *     Note: Except for the description, the SSB fields
     *           should be identical to its Base item's fields.
     *
     C                   movea     lbl(1)        a13
     C                   if        #otype = 'S'
     C                   movea     #osu2         a13(7)
     C                   else
     C                   movea     #osu1         a13(7)
     C                   endif
     C                   movea     a13           wolbl
     C     wolbl         cat       ')':0         wolbl
     C                   move      ':'           wolbl
     *
     *   Create description for selected item
     *
     C                   movea     typ(1)        a10
     C                   movea     #otype        a10(8)
     C                   movea     a10           temp10
     *
     C     #oitem        cat       temp10:1      woitem
     C     woitem        cat       '-':1         woitem
     C     woitem        cat       #odesc:1      woitem
     *
     *   Create label and description for corresponding item.
     *
     C                   select
     *
     *     If selected item is a Base item . . .
     *        Then display its corresponding SSB item (if any)
     *        Otherwise display nothing.
     *
     C                   when      #otype = ' '
     C                   if        #bityp = 'S'
     C                   movea     lbl(3)        a13
     C                   movea     #bsu2         a13(6)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     C                   endif
     *
     *     If selected item is a Breakdown item . . .
     *        Then display its corresponding Base item.
     *             Note: UOM is not applicable in this situation.
     *
     C                   when      #otype = 'B'
     C                   movea     lbl(2)        a13
     C                   movea     'N/A'         a13(7)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     *
     *     Otherwise . . .
     *        Then display its corresponding Base item w/UOM.
     *             Note: UOM of Base should match UOM of selected item.
     *
     C                   other
     C                   movea     lbl(2)        a13
     C                   movea     #bsu1         a13(7)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     *
     C                   endsl
     *
     *   Determine item number going into slot.
     *
     C                   if        #otype = ' '  or
     C                             #otype = 'B'
     C                   eval      #sitem = #oitem
     C                   endif
     *
     *   Get extend description headings if being used.
     *
     C                   if        uxflag = *off
     C                   else
     C                   if        not *in75
     C                   eval      wodsc1 = $ixdsc1
     C                   eval      wodsc2 = $ixdsc2
     C                   endif
     C                   endif
     *
     *   Initialize unit of measure names for quantity fields.
     *
     C                   if        #otype = 'S'
     C                   eval      w1um1 = #osu2
     C                   else
     C                   eval      w1um1 = #osu1
     C                   endif
     *
     C                   if        not *in94
     C                   if        #otype = 'S'
     C                   eval      w1um2 = #osu3
     C                   else
     C                   eval      w1um2 = #osu2
     C                   endif
     C                   endif
     *
     C                   if        not *in93
     C                   eval      w1um3 = #osu3
     C                   endif
     *
     *   Determine if this item should be put away into warehouse.
     *   An '*' in last position of designation says that the item
     *   will NOT be put away into the warehouse.
     *
     C                   move      $itdesg       iatest
     C                   if        iatest = '*'
     C                   eval      iaflag = *on
     C                   eval      *in64 = *off
     C                   else
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   endif

     *  ... Or department isn't live (this overrides iaflag).

     C                   call      'CHKLIVE'
     C                   parm      $pwhse        $swhse
     C                   parm                    $itwhdp
     C                   parm                    livestat          8

     C                   if        livestat = '*NOTLIVE'
     C                   eval      *in65 = *off
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   else
     C                   eval      *in65 = *on
     C                   endif
     *
     *
     C                   endif
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     c                   if        $ldecvalue = ' '
     c                   exsr      zzmfrdates
     c                   endif
     C     phkey         chain(n)  pohdr                              79
     C                   if        *in79
     C                   eval      phven = 0
     C                   eval      phvnam = *blanks
     C                   endif
     *
     C                   if        $immflg = 'Y'
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        womfdt

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1exdt

     C                   endif
     *
     C                   if        w1upcd <> *blanks and
     C                             w1upc <> *blanks
700dA /free
700dA   select;
700dA     when      w1qrc1 > 0;
700dA       eval      uputyp = 'N';
700dA     when      w1qrc2 > 0;
700dA       eval      uputyp = '1';
700dA     when      w1qrc3 > 0;
700dA       eval      uputyp = '2';
700dA   endsl;
700dA /end-free
700dDC*    upcky3        chain(n)  upc3                               79
700dMC     upcky3U       chain(n)  upc3                               79
     C                   if        *in79
     C                   eval      upwhse = $pwhse
     C                   eval      upitem = $pitem
     C                   eval      upupc = w1upc
     C                   eval      upven = phven
     C                   eval      upvnam = phvnam
     C                   eval      upvitm = pdvitm
     C                   eval      upbran = *blanks
700dA * load new upc fields
700dA /free
700dA   select;
700dA     when      w1qrc1 > 0;
700dA       eval      upuom = $itum1;
700dA       eval      uputyp = 'N';
700dA     when      w1qrc2 > 0;
700dA       eval      upuom = $itum2;
700dA       eval      uputyp = '1';
700dA     when      w1qrc3 > 0;
700dA       eval      upuom = $itum3;
700dA       eval      uputyp = '2';
700dA   endsl;
700dA   Select;
700dA     when ntype = 'UPC-12';
700dA       upctyp = '1';
700dA     when ntype = 'EAN-13';
700dA       upctyp = '2';
700dA     when ntype = 'GTIN';
700dA       upctyp = '3';
700dA     when ntype = 'SCC-14';
700dA       upctyp = '4';
700dA     when ntype = 'SSCC-18';
700dA       upctyp = '5';
700dA   endsl;
700dA /end-free
     *
     *   Add record
     *
     C                   write     uprec                                78
     C                   if        *in78
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup3
     C                   endif
     C                   endif
     C                   endif
     *
     C                   eval      $rven = phven
     C                   eval      $rvnam = phvnam
     *
     *   Call receiving program, if this is a replenishment type
     *   of transfer.(Customer order# blank)
     *
     C                   if        w1exdt = 0
     C                   eval      $rexpd = 0
     C                   else
     C                   eval      $cvcmd = '*MDYCMD '
     C                   eval      $rexpd = expd
     C                   endif
WSTbA*
WSTbA*    skip the validte fifo if client westside and wofifo > 0
WSTbA*
WSTbAC                   if        client = westside and wofifo > 0
WSTbAC                   else
     *
     *    Validate FIFO date if a MoveIn P/O. Otherwise, set to zero.
     *
     C                   if        w1fifo <> 0  and
     C                             not *in89
     *
     C                   move      w1fifo        $cvd6i
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        wofifo
     C                   else
     C                   eval      wofifo = *zeros
     C                   endif
WSTbAC                   endif
     *
     C                   exsr      zzzcw
     *
     *   If not a FSWMS item, don't put away only update PODTL
     *
     C                   if        iaflag = *on
     C                   eval      $rpo = $ppo
     C                   eval      $rseq = $pseq
     C                   eval      $rslot = w1slot
     *
     C                   call      'RC161'
     C                   parm      '*RECEIV1'    $rcmd             8
     C                   parm                    $rprg            10
     C                   parm      '*INTER  '    $rtype            8
     C                   parm                    w1whse
     C                   parm                    w1item
     C                   parm                    w1qrc1
     C                   parm                    w1qrc2
     C                   parm                    w1qrc3
     C                   parm                    $rpo              9
     C                   parm                    $rven            11 0
     C                   parm                    $rvnam           40
     C                   parm                    w2vitm           15
     C                   parm      0             $rord             7 0
     C                   parm      *blanks       $rrcod            2
     C                   parm      *blanks       $rrmem           30
     C                   parm                    $rexpd            8 0
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $rslot           12
     C                   parm                    $rseq             5 0
     C                   parm                    $rrpck            1
     C                   parm                    $rplbl            1
     C                   parm                    w1twgt            9 2
     C                   parm                    $rrq1             5 0
     C                   parm                    $rrq2             5 0
     C                   parm                    $rrq3             5 0
     C                   parm                    $rrpal            3 0
     C                   parm                    $rrtn             8
     C                   parm                    $rmsg             4
     C                   if        $rrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endup3
     C                   endif
     C                   goto      jmpup1
     C                   endif
     *
     *   If not a FSWMS item, don't put away only update PODTL
     *
     C                   if        livestat = '*NOTLIVE'
     C                             and not jdobread
     C                   eval      $lflag = lflag
     C                   eval      $lcmd = '*CHANGE '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lpo = $ppo
     C                   eval      $litem = $pitem
     C                   eval      $lrq1 = w1qrc1
     C                   eval      $lrq2 = w1qrc2
     C                   eval      $lrq3 = w1qrc2
     C                   eval      $lrpal = 1
     C                   eval      $lum1 = w1um1
     C                   eval      $lum2 = w1um2
     C                   eval      $lum3 = w1um3
     C                   eval      $lord = $rord
     C                   eval      $lseq# = $pseq
     C                   eval      $lcwgt = w1dwgt
     C*                  eval      wofifo = 0
     * Move mfg or expire or fifo date to keyed in date field
     * to send to PO236
     C                   eval      woindt = 0
     C                   select
     C                   when      w1fifo <> 0
     C                   eval      woindt = wofifo
     C                   when      w1mfdt <> 0
     C                   eval      woindt = womfdt
     C                   other
     C                   eval      woindt = woexdt
     C                   endsl
700bAc                   if        sprcv = *ON
700bAc                   eval      w1lcns = templcns
700bAc                   endif
     *
     C                   call      'PO236'
     C                   parm                    $lparm
     C                   parm                    $lum1
     C                   parm                    $lum2
     C                   parm                    $lum3
     C                   parm                    $lord
     C                   parm                    $lflag            1
     C                   parm                    $lseq#            5 0
     C                   parm                    $lven
     C                   parm                    $lvnam
     C                   parm                    $lvitm
     C                   parm                    $rexpd
     C                   parm                    $pdev
     C                   parm                    $pform
     C                   parm                    $lcwgt            9 2
     C                   parm                    avgwt1
     C                   parm                    avgwt2
     C                   parm                    avgwt3
     C                   parm                    w1lotc
     C                   parm                    woindt
     C                   parm                    wofifo
     C                   parm                    w1upc
     c                   parm                    $ldecvalue
     C                   parm      mexpd         $lmfgex           8 0
     C                   parm      mfgdte        $lmfgdt           8 0
650bAC                   parm      $plpn         $llpn            50
650bAC                   parm                    w1lcns
650bAC                   parm                    w1brand
650bAC                   parm                    $parms1
650bAC                   parm                    $lsavetrn
650dAC                   parm                    $bcGtin
650dAc                   parm      $bcProdd      $pbcProdD
650dAc                   parm                    $bclot
650dAc                   parm                    $pw1pti
650wAc                   parm      ' '           $losscode         1
     C                   eval      $prtn = $lrtn
     C                   eval      $pmsg = $lmsg
     C                   if        $lrtn = '*OK     '
     c                   eval      $ldecvalue  = ' '
     c                   eval      $lmfgex = 0
     c                   eval      $lmfgdt = 0
     c                   eval      mexpd     = 0
     c                   eval      mfgdte   = 0
650pAc                   eval      moretoscan = *off
650pAc                   eval      firstuci = *off
650pAC                   eval      wolbl = *blanks
650pAC                   eval      woitem = *blanks
650pAC                   eval      wodsc1 = *blanks
650pAC                   eval      wodsc2 = *blanks
650pAc                   eval      $puci = ' '
650pAc                   eval      w1uci = ' '
650pAc                   eval      w1lcns= ' '
650pAc                   eval      templcns = ' '
650pAc                   eval      saveqty  = 0
650sAc                   eval      svdwgt = 0
650sAc                   eval      savewgt= 0
     c                   endif
     C                   call      'MOVMSGP'
     C                   parm                    $pprg
     C                   goto      jmpup1
     C                   endif
     *
     *   Try to put-away the item received.
     *
     C                   eval      $rpo = $ppo
     C                   eval      $rseq = $pseq
     C                   eval      $rslot = w1slot
     C                   eval      rcverr = *off
     *
     *   Set command to send.
     C                   select
     C                   when      phvnam = 'MOVEIN'
     C                   eval      $rcmd = '*RECEIV1'
     C                   eval      $rfifo = wofifo
     C                   when      phvnam = move1
     C                   eval      $rcmd = '*MOVEINP'
     C                   eval      $rfifo = wofifo
     C                   when      phvnam = move2
     C                   eval      $rcmd = '*MOVEINO'
     C                   eval      $rfifo = wofifo
     C                   when      sprcv = '1'
     C                   eval      $rcmd = '*SPRECV '
     C                   eval      $rfifo = 0
     C                   other
     C                   eval      $rcmd = '*RECEIV1'
     C                   eval      $rfifo = 0
WSTbAC                   if        client = westside
WSTbAC                   eval      $rfifo = wofifo
WSTbAC                   endif
     C                   endsl
     C                   call      'RC160'
     C                   parm                    $rcmd
     C                   parm                    $rprg
     C                   parm      '*INTER  '    $rtype
     C                   parm                    w1whse
     C                   parm                    w1item
     C                   parm                    w1qrc1
     C                   parm                    w1qrc2
     C                   parm                    w1qrc3
     C                   parm                    $rpo
     C                   parm                    $rven
     C                   parm                    $rvnam
     C                   parm                    w2vitm
     C                   parm      0             $rord
     C                   parm      *blanks       $rrcod
     C                   parm      *blanks       $rrmem
     C                   parm                    $rexpd
     C                   parm                    $rfifo            8 0
     C                   parm                    $pdev
     C                   parm                    $pform
     C                   parm                    $rslot
     C                   parm                    $rseq
     C                   parm                    $rrpck
     C                   parm                    $rplbl
     C                   parm                    w1twgt
     C                   parm                    $rrq1
     C                   parm                    $rrq2
     C                   parm                    $rrq3
     C                   parm                    $rrpal
     C                   parm                    $rrtn
     C                   parm                    $rmsg
     *  If error, then do not update transfer order file.
     C                   if        $rrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      rcverr = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endup3
     C                   else
     C                   add       $rrq1         $prsqt
     C                   add       $rrq2         $prsqt
     C                   add       $rrq3         $prsqt
     *
     C                   eval      $lflag = lflag
     C                   if        lflag = *off
     C                   eval      $lcmd = '*LICONLY'
     C                   else
     C                   eval      $lcmd = '*CHANGE '
     C                   endif
     C                   if        sprcv = *on
     C                   eval      $lcmd = '*STUFFIT'
     C                   endif
     C                   eval      $lwhse = $pwhse
     C                   eval      $lpo = $ppo
     C                   eval      $litem = $pitem
     C                   eval      $lrq1 = $rrq1
     C                   eval      $lrq2 = $rrq2
     C                   eval      $lrq3 = $rrq3
     C                   eval      $lrpal = $rrpal
     C                   eval      $lum1 = w1um1
     C                   eval      $lum2 = w1um2
     C                   eval      $lum3 = w1um3
     C                   eval      $lord = $rord
     *    Lot tracking item - Pass single char flag to license entry pgm
     C                   if        lottrk = '*YES'
     C                   eval      $llott = 'Y'
     C                   else
     C                   eval      $llott = 'N'
     C                   endif
     *    Lic.tracking item - Pass single char flag to license entry pgm
     C                   if        lictrk = '*YES'
     C                   eval      $llict = 'Y'
     C                   else
     C                   eval      $llict = 'N'
     C                   endif
     C                   eval      $lseq# = $pseq
     C                   eval      $lcwgt = w1dwgt
WSTbA* if westside don't clear wofifo
WSTbAC                   if        client = westside and wofifo > 0
WSTbAc                   else
     C                   eval      wofifo = 0
WSTbAc                   endif
700bA *
700bAc                   if        sprcv = *ON
700bAc                   eval      w1lcns = templcns
700bAc                   endif
     *
     C                   call      'PO136'
     C                   parm                    $lparm
     C                   parm                    $lum1
     C                   parm                    $lum2
     C                   parm                    $lum3
     C                   parm                    $lord
     C                   parm                    $lflag            1
     C                   parm                    $lseq#            5 0
     C                   parm                    $lven
     C                   parm                    $lvnam
     C                   parm                    $lvitm
     C                   parm                    $rexpd
     C                   parm                    $pdev
     C                   parm                    $pform
     C                   parm                    $lcwgt            9 2
     C                   parm                    avgwt1
     C                   parm                    avgwt2
     C                   parm                    avgwt3
     C                   parm                    w1lotc
     C                   parm                    womfdt
     C                   parm                    wofifo
     C                   parm                    w1upc
     c                   parm                    $ldecvalue
     C                   parm      mexpd         $lmfgex           8 0
     C                   parm      mfgdte        $lmfgdt           8 0
     C                   parm      $plpn         $llpn            50
     C                   parm                    w1lcns
     C                   parm                    w1brand
650aAC                   parm                    $parms1
650bAC                   parm                    $lsavetrn
650dAC                   parm                    $bcGtin
650dAc                   parm      $bcProdd      $pbcProdD
650dAc                   parm                    $bclot
650dAc                   parm                    $pw1pti
     C                   if        $rrtn = '*OK     '
     C                   eval      $prtn = $rrtn
     C                   eval      $pmsg = $rmsg
     c                   eval      $ldecvalue  = ' '
     c                   eval      $lmfgex = 0
     c                   eval      $lmfgdt = 0
     c                   eval      mexpd     = 0
     c                   eval      mfgdte   = 0
650pAc                   eval      moretoscan = *off
650pAc                   eval      firstuci = *off
700dAc                   if        $ifrcvmth <> '3' or $ittype <> ' '
650pAC                   eval      wolbl = *blanks
650pAC                   eval      woitem = *blanks
650pAC                   eval      wodsc1 = *blanks
650pAC                   eval      wodsc2 = *blanks
700dAc                   endif
650pAc                   eval      $puci = ' '
650pAc                   eval      w1uci = ' '
650pAc                   eval      w1lcns= ' '
650pAc                   eval      templcns = ' '
650pAc                   eval      saveqty  = 0
650sAc                   eval      svdwgt = 0
650sAc                   eval      savewgt= 0
650bAc                   eval      rcvpocomplete = *on
     *  If no error was found then send message to calling program.
     C                   call      'MOVMSGP'
     C                   parm                    $pprg
     C                   endif
     C                   endif
     *
     *    Write records to POMFR file.
     *    Note: RC160 returns batch number in $RORD field which is
     *          used as first part of the LBKEY.
     *
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        $rexpd > 0
     C                   eval      pmwhse = $pwhse
     C                   eval      pmpo = $ppo
     C                   eval      pmseq = $pseq
     C                   eval      pmitem = $pitem
     C                   eval      pmexpd = $rexpd
     C                   if        w1mfdt <> 0
     C                   move      w1mfdt        $cvd6i
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      pmmfgd = $cvd8o
     C                   else
     C                   eval      pmmfgd = 0
     C                   endif
     C                   eval      pmtrn# = lbtrn#
     C                   eval      pmlbl# = lblbl#
     C                   write     pmrec
     *
     *      Write record to item exception file for date override.
     *
      * add additional exception if date decipher error
     c                   if        ddcode = *on
     C                   eval      exerid = 'DD-CODE'
     C                   eval      exwhse = lbwhse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      dspo = lbpo
     C                   eval      dslbl = lblbl#
     C                   eval      dsexpd = $dto
     C                   eval      exfdis = dsfdis
     C                   eval      extdis = dstdis
     C                   eval      exgdte = lbsdte
     C                   eval      exgtim = lbstim
650 A*
650 AC                   if        lbqpck > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
     C                   z-add     lbqpck        exqty
650 AC                   endif
650 A*
     C                   eval      extask = 'RCV'
     C                   eval      exgby = #user
     C                   eval      exesta = '1 '
     C                   write     exrec
     C                   eval      ddcode = *off
     c                   endif
     C                   if        oaovr = *on  or
     C                             obovr = *on  or
     C                             ocovr = *on  or
     C                             odovr = *on  or
     C                             oeovr = *on  or
     C                             ofovr = *on
     C                   eval      exwhse = lbwhse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      dspo = lbpo
     C                   eval      dslbl = lblbl#
     C                   eval      dsexpd = $dto
     C                   eval      exfdis = dsfdis
     C                   eval      extdis = dstdis
     C                   eval      exgdte = lbsdte
     C                   eval      exgtim = lbstim
650 A*
650 AC                   if        lbqpck > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
     C                   z-add     lbqpck        exqty
650 AC                   endif
650 A*
     C                   eval      extask = 'RCV'
     C                   eval      exgby = #user
     C                   select
     C                   when      oaovr = *on
     C                   eval      exerid = 'OA-DOVR'
     C                   when      obovr = *on
     C                   eval      exerid = 'OB-DOVR'
     C                   when      ocovr = *on
     C                   eval      exerid = 'OC-DOVR'
     C                   when      odovr = *on
     C                   eval      exerid = 'OD-DOVR'
     C                   when      oeovr = *on
     C                   eval      exerid = 'OE-DOVR'
     C                   when      ofovr = *on
     C                   eval      exerid = 'OF-DOVR'
     C                   other
     C                   eval      exerid = 'EXPDOVR'
     C                   endsl
     C                   eval      exesta = '1 '
     C                   write     exrec
     C                   eval      oaovr = *off
     C                   eval      obovr = *off
     C                   eval      ocovr = *off
     C                   eval      odovr = *off
     C                   eval      oeovr = *off
     C                   eval      ofovr = *off
     C                   endif
     *
     C                   endif
     C                   if        lflag = *off
     C                   exsr      zzurcv
     C                   endif
     C                   endif
     C                   enddo
     *  Move screen fields to record fields
     *
     *    Write records to POFIFO file.
     C                   if        w1fifo <> 0
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   eval      pffifo = wofifo
     C                   eval      pflbl# = lblbl#
     C                   write     pfrec
     C                   endif
     C                   enddo
     C                   endif
650hA* catch weight override exception
650hAC                   if        cwovr = *on
650hAC     lbkey         setll     label2
650hAC                   eval      stop = *off
650hAC                   dou       stop = *on
650hAC     lbkey         reade     label2                                 79
650hAC                   if        *in79
650hAC                   eval      stop = *on
650hAc                   leave
650hAC                   else
650hAC                   if        lbqpck > 999
650hAC                   eval      exqty = 999
650hAC                   else
650hA*
650hAC                   z-add     lbqpck        exqty
650hAC                   endif
650hAC                   endif
650hA*
650hAC                   eval      exwhse = lbwhse
650hAC                   eval      exwhdp = lbwhdp
650hAC                   eval      exstyp = lbstyp
650hAC                   eval      exitem = lbitem
650hAC                   eval      dspo = lbpo
650hAC                   eval      dslbl = lblbl#
650hAC                   eval      dsexpd = 0
650hAC                   eval      exfdis = dsfdis
650hAC                   eval      extdis = dstdis
650hAC                   eval      exgdte = lbsdte
650hAC                   eval      exgtim = lbstim
650hAC                   eval      extask = 'RCV'
650hAC                   eval      exgby = #user
650hAC                   select
650hAC                   when      cwovr = *on
650hAC                   eval      exerid = 'CW-OVR '
650hAC                   endsl
650hAC                   eval      exesta = '1 '
650hAC                   write     exrec
650hA * load new file pocwexcp
650hA /free
650nD   //chain ($pwhse: lblbl#) pocwexcp;
650nD   //cw_exwhse = $pwhse;
650nD   //cw_expo = $ppo;
650nD   //cw_exseq = $pseq;
650nD   //cw_exitem = $pitem;
650hA   cw_exwhse = lbwhse;
650hA   cw_expo = lbpo;
650hA   cw_exseq = lbseq;
650hA   cw_exitem = lbitem;
650hA   cw_extrn# = lbtrn#;
650hA   cw_exlbl# = lblbl#;
650hA   cw_exwgt = W1DWGT;
650oD   //cw_exrngl = erlrng;
650oD   //cw_exrngh = erhrng;
650hA   cw_exgdte = lbsdte;
650hA   cw_exgtim = lbstim;
650hA   cw_exrg1c = prg1c * 100;
650hA   cw_exrg2c = prg2c * 100;
650hA   cw_exswgt = exwgt;
650hA   select;
650hA     when $imrg1c > 0;
650hA       cw_exrg1w = 'I';
650hA     when oprg1c > 0;
650hA       cw_exrg1w = 'S';
650hA     other;
650hA       cw_exrg1w = 'P';
650hA   endsl;
650hA   select;
650hA     when $imrg2c > 0;
650hA       cw_exrg2w = 'I';
650hA     when oprg2c > 0;
650hA       cw_exrg2w = 'S';
650hA     other;
650hA       cw_exrg2w = 'P';
650hA   endsl;
650nD   //if %found(pocwexcp);
650nD     //update cwexrec;
650nD   //else;
650hA     write cwexrec;
650nD   //endif;
650hA /end-free
650hAC                   enddo
650hAC                   eval      cwovr = *off
650hAC                   endif
     *
     *   Move key values to parameters
     *
     C     jmpup1        tag
     C                   eval      $pseq = pdseq
     C                   eval      $pitem = pditem
     C     endup3        endsr
700dA*----------------------------------------------------------------
700dA*
700dA*  ZZUPD4   Write breakdown upc
700dA*
700dAC     zzupd4        begsr

700dA /free
700dA   // breakdown1
700dA   if writeb1 = *on;
700dA     upwhse = $pwhse;
700dA     upitem = $pitem;
700dA     upupc = b1upc;
700dA     upven = phven;
700dA     upvnam = phvnam;
700dA     upvitm = $itvit#;
700dA     upbran = $imbrnd;
700dA     upuom = w1buom1;
700dA     uputyp = '1';
700dA     Select;
700dA       when b1type = 'UPC-12';
700dA         upctyp = '1';
700dA       when b1type = 'EAN-13';
700dA         upctyp = '2';
700dA       when b1type = 'GTIN';
700dA         upctyp = '3';
700dA       when b1type = 'SCC-14';
700dA         upctyp = '4';
700dA       when b1type = 'SSCC-18';
700dA         upctyp = '5';
700dA     endsl;
700dA     write uprec;
700dA   endif;
700dA   // breakdown2
700dA   if writeb2 = *on;
700dA     upwhse = $pwhse;
700dA     upitem = $pitem;
700dA     upupc = b2upc;
700dA     upven = phven;
700dA     upvnam = phvnam;
700dA     upvitm = $itvit#;
700dA     upbran = $imbrnd;
700dA     upuom = w1buom2;
700dA     uputyp = '2';
700dA     Select;
700dA       when b2type = 'UPC-12';
700dA         upctyp = '1';
700dA       when b2type = 'EAN-13';
700dA         upctyp = '2';
700dA       when b2type = 'GTIN';
700dA         upctyp = '3';
700dA       when b2type = 'SCC-14';
700dA         upctyp = '4';
700dA       when b2type = 'SSCC-18';
700dA         upctyp = '5';
700dA     endsl;
700dA     write uprec;
700dA   endif;
700dA   $prtn = ' ';
700dA /end-free
700dAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDCnl Delete scanned records
     *
     *----------------------------------------------------------------
     C     zzupdCnl      begsr
     C                   eval      error = *off
     *   Remove any LICUCI records
      /free
        if moretoscan = *on;
          if *inkj;
            // Delete LICINFO Records
            exsr zzlicinfocan;

            exsr clr$uciinfo;

            // warehouse
            $uiWhse = $pwhse;

            // License
700bD       //if $pxd = ' ';
700bM       if $pxd = ' '
700bA        and sprcv = *off;
              $uiLcns = w1lcns;
            else;
              $uiLcns = templcns;
            endif;

            $dricommand = '*UCIINFO';
            $drisubcmd  = '%CANCEL';
            $drisys2upd = 'D';
            ck4err = *on;
            zmflag  = *off;
            exsr zzzdricop;
            if error;
            endif;
            moretoscan = *off;
            $puci = ' ';
            w1uci = ' ';
            w1lcns = ' ';
            templcns = ' ';
            ovrrid = *off;
            $pexpdt = 0;
            $pwgt = 0;
            $pmfgdt = 0;
            $plot = ' ';
650iA       saveqty = 0;
650sA       svdwgt = 0;
650sA       savewgt= 0;
          endif;
        endif;

      /end-free
     *
     *   Move key values to parameters
     *
     C     endupCnl      endsr
     *----------------------------------------------------------------
     *
     *  ZZUHDR   Update HDR record.
     *
     C     zzuhdr        begsr
     C                   eval      error = *off
     C                   eval      full = *on
     C                   eval      part = *off
     C                   eval      recv = *off
     C     partky        setll     podtl                              79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     partky        reade     podtl                                  79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   if        pdqrc1 < pdqor1
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc2 < pdqor2
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc3 < pdqor3
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc1 > 0
     C                   eval      recv = *on
     C                   endif
     *
     C                   if        pdqrc2 > 0
     C                   eval      recv = *on
     C                   endif
     *
     C                   if        pdqrc3 > 0
     C                   eval      recv = *on
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   if        recv = *off
     C                   eval      full = *off
     C                   eval      part = *off
     C                   endif
     *
     C     phkey         chain     pohdr                              79
     C                   if        not *in79
     C                   if        part = *on
     C                   eval      phstat = *on
     C                   endif
     C                   if        full = *on
     C                   eval      phstat = '2'
     C                   endif
     C                   if        part = *off  and
     C                             full = *off
     C                   eval      phstat = *off
     C                   endif
     C                   update    phrec
770aA*
770aA*   Update the POSTATUS file for a change to POHDR
770aA*   Check for DockVue system option
770aA*
770aA /free
770aA   // Set status for DockVue
770aA   if dockvue;
770aA     exec sql update postatus
770aA                 set posstat = :phstat,
770aA                     posupdts = current_timestamp
770aA               where poswhs = :phwhse
770aA                 and pospo  = :phpo;
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql insert into postatus
770aA                values (:phwhse, :phpo, :phstat,
770aA                        current_timestamp, :nostamp);
770aA     endif;
770aA   endif;
770aA /end-free
770aA*
     C                   endif
     *
     *   Remove any existing catchweight entry records.
     C                   if        $itcwgt = 'Y'
     C                             or $itcwgt = 'S'
     C                   exsr      zzdlcw
     C                   endif
     *
     C     endhdr        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *   Move key values to parameters
     *
     C     endup2        endsr
     *---------------------------------------------------------------
     *
     *  ZZURCV   Update PORCV file.
     *
770aA*---------------------------------------------------------------
     C     zzurcv        begsr
     *
     *   Add record to PORCV.
     *
     C                   eval      porwhs = $pwhse
     C                   eval      porpo = $ppo
     C                   eval      porseq = $pseq
     C                   eval      pordte = today
     C                   time                    portim
     C                   eval      porusr = #user
     C                   eval      pordev = #job
     C                   eval      poremp = $emp#
     C                   eval      portrn = lbtrn#
     C                   eval      porlic = *blanks
     C                   eval      porlbl = lblbl#
     C                   eval      poract = 'R'
     C                   eval      poredt = 0
     C                   eval      poreti = 0
     C                   write     porrec                               49
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZVPCK   Create virutial pick slot.
     *
     C     zzvpck        begsr
     *    code pulled from SL270 ****

     *  Use DRI interface to do everything, including creating VSlot.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $itwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = wodisp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = $ititem
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%CRTVPICK'
     C                   eval      $drisys2upd = 'D'
640dDC*                  eval      chk4err = *on
640dMC                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   if        $slwhsee = '1'
     C                   eval      *in21 = *on
     C                   endif
     C                   if        $slwhdpe = '1'
     C                   eval      *in22 = *on
     C                   endif
     C                   if        $sldispe = '1'
     C                   eval      *in23 = *on
     C                   endif
     C                   if        $sliteme = '1'
     C                   eval      *in24 = *on
     C                   endif
     C                   endif


     C     endvpk        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      uxflag = *off
     C                   eval      ocode = '*ITEMMNT'
     C                   eval      wkwhse = $pwhse
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opxdsc = 'Y'
     C                   eval      uxflag = *on
     C                   endif
700cA*    We will set the default for lbs/kgs from the option file
700cA /free
700cA   // save the field for later use, the opdata field gets changed
700cA   svopwum = opwum;
700cA   select;
700cA     when opwum = 'KGS'
700cA      or opwum = 'kgs'
700cA      or opwum = 'Kgs';
700cA       KiloLbs = 'K';
700cA       W1KgLb  = opwum;
700cA     other;
700cA       KiloLbs = 'P';
700cA       W1KgLb  = 'Lbs';
700cA   endsl;
700cA /end-free
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZCW    Calculate catch weight
     *
     *
     *  Action Table
     *
     *   VRFYCW  SVCWEN  SVCWTP  W1AVG  POCTYP  Action
     *   ------  ------  ------  -----  ------  --------------------
     *     Y       1       1       N       -    CW = Calc1
     *
     *     Y       1       1       Y       -    CW = Calc2
     *
     *     Y       1       2       -       -    CW = Calc1
     *
     *     Y       1       3       -       -    CW = Calc2
     *
     *     Y       2       1       N       -    CW = Calc1
     *                                          Write POCTYP = 'T'
     *
     *     Y       2       1       Y       -    CW = Calc3
     *                                          Write POCTYP = 'A'
     *
     *     Y       2       2       -       -    CW = Calc1
     *                                          Write POCTYP = 'T'
     *
     *     Y       2       3       -       -    Not allowed
     *
     *     N       1       -       -       -    Not allowed
     *
     *     N       2       -       -       T    None
     *
     *     N       2       -       -       A    CW = Calc3
     *
     *     N       3       -       -       -    None
     *
650yA*     Y       3  GS1 Catchweights     -    CW = Calc1
650yA*                $ifrcvmth = '2'
     *  Keys:
     *
     *   SVCWEN - 1=Every time, 2=First time only, 3=Never
     *   SVCWTP - 1=Choice, 2=Total, 3=Average
     *   Calc1  - Entered weight
     *   Calc2  - Qty * Entered weight
     *   Calc3  - Qty * Item weight
     *
     *----------------------------------------------------------------
     C     zzzcw         begsr
     *
     C                   eval      w1twgt = 0
     C                   eval      avgwt1 = 0
     C                   eval      avgwt2 = 0
     C                   eval      avgwt3 = 0
     C                   eval      cwcalc = 0
     C                   eval      wrttyp = ' '
     *
     *   Get POCTYPE record.
     *
     C                   if        svcwen = '2'
650lMC     keypoc        chain(n)  poctype                            79
650lDC**   keypoc        chain     poctype                            79
     C                   if        *in79
     C                   eval      poctyp = 'T'
     C                   endif
     C                   endif
     *
     *   Determine what needs to be done based on table.
     *
     C                   select
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'N'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'Y'
     C                   eval      cwcalc = 2
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '2'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '3'
     C                   eval      cwcalc = 2
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'N'
     C                   eval      cwcalc = 1
     C                   eval      wrttyp = 'T'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'Y'
     C                   eval      cwcalc = 3
     C                   eval      wrttyp = 'A'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '2'
     C                   eval      cwcalc = 1
     C                   eval      wrttyp = 'T'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '3'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '1'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '2'  and
     C                             poctyp = 'T'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '2'  and
     C                             poctyp = 'A'
     C                   eval      cwcalc = 3
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '3'
     *
650yAC                   when      vrfycw = *on  and
650yAC                             w1dwgt > 0    and
650yAc                             $ifrcvmth = '2'
650yAC                   eval      cwcalc = 1
     *
     C                   endsl
     *
     *   Calculate catch weight.
     *
     C                   select
     *
     *     Straight total.
     *
     C                   when      cwcalc = 1
     C                   eval      w1twgt = w1dwgt
     C     w1dwgt        div       w1qrc1        avgwt1
     *
     *     Entered quantity * Entered weight.
     *
     C                   when      cwcalc = 2
     C     w1dwgt        mult      w1qrc1        w1twgt
     C                   z-add     w1dwgt        avgwt1
     *
     *     Entered quantity * Item weight.
     *
     C                   when      cwcalc = 3
     *
     *       Normal qty for non-SSB items.
     *
     C                   if        w1qrc1 > 0  and
     C                             #otype <> 'S'
     C     #oswgt        mult      w1qrc1        w1twgt
     C                   eval      avgwt1 = #oswgt
     C                   endif
     *
     *       Normal qty for SSB items.
     *
     C                   if        w1qrc1 > 0  and
     C                             #otype = 'S'
     C     #oswt2        mult      w1qrc1        w1twgt
     C                   eval      avgwt1 = #oswt2
     C                   endif
     *
     *       Brk1 qty for non-SSB items.
     *
     C                   if        w1qrc2 > 0  and
     C                             #otype <> 'S'
     C     #oswt2        mult      w1qrc2        tmpwgt
     C                   add       tmpwgt        w1twgt
     C                   eval      avgwt2 = #oswt2
     C                   endif
     *
     *       Brk1 qty for SSB items.
     *
     C                   if        w1qrc2 > 0  and
     C                             #otype = 'S'
     C     #oswt3        mult      w1qrc2        tmpwgt
     C                   add       tmpwgt        w1twgt
     C                   eval      avgwt2 = #oswt3
     C                   endif
     *
     *       Brk2 qty for non-SSB items.
     *
     C                   if        w1qrc3 > 0  and
     C                             #otype <> 'S'
     C     #oswt3        mult      w1qrc3        tmpwgt
     C                   add       tmpwgt        w1twgt
     C                   eval      avgwt3 = #oswt3
     C                   endif
     *
     C                   endsl
     *
     *   Write POCTYPE record.
     *
     C                   if        wrttyp <> ' '
     C     keypoc        chain     poctype                            79
     C                   if        not *in79
     C                   eval      poctyp = wrttyp
     C                   update    pocrec
     C                   else
     C                   eval      pocwhs = $pwhse
     C                   eval      pocpo = $ppo
     C                   eval      pocseq = $pseq
     C                   eval      poctyp = wrttyp
     C                   write     pocrec                               78
     C                   endif
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $dridata = $xdock
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
     C                   endsl


     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
720aAC                             or $dricommand = '*UCIINFO'
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

640dDC*                  when      chk4err and %error
640dMC                   when      ck4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      zm0105
640dDC*                  when      chk4err and $drireturn = 'VRTPCKCRT'
640dMC                   when      ck4err and $drireturn = 'VRTPCKCRT'

640dDC*                  when      chk4err and $drireturn <> '*OK'
640dMC                   when      ck4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   exsr      zm0001s
     C                   when      zmflag
     C                   exsr      zm0001
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $xdock = $dridata
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

640dDC*                  eval      chk4err = *off
640dMC                   eval      ck4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Normal quantity
Breakdown 1 quantity
Breakdown 2 quantity
Catch weight
Average
UPC code
* * INVALID ITEM * *
Number of pallets
F7 only for c/w's
Tie/Hi Qty on Pallet
UCI Barcode
Scan/Enter License
Different Item
Different GTIN/UPC
License
Scan UCI Barcode
**
Item (
Base (
SSB (
Item  . . . .
**
(Type ' ')
**
Catch weight (Ttl or Avg) .
Catch weight (Total)  . . .
Catch weight (Average)  . .
**  CMDLN - Command display line
F7=Kilograms  F8=Tie/Hi  F9=Cwgt Entry  F11=Mfr Code
F7=Pounds  F8=Tie/Hi  F9=Cwgt Entry  F11=Mfr Code
F7=Kilograms  F8=Tie/Hi  F9=Cwgt Entry
F7=Pounds  F8=Tie/Hi  F9=Cwgt Entry
F8=Tie/Hi  F11=Mfr Code
F8=Tie/Hi
F3=Exit  F5=Refresh  F12=Cancel  F20=Accept warning
F3=Exit F5=Refresh F12=Cancel F20=Accept warning  F22=Complete License
F8=Tie/Hi  F12=Cancel
F9=Skip
