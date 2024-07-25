      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     ?*----------------------------------------------------------------
     ?*   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     ?*   (630) 562-0375
     ?*----------------------------------------------------------------
     ?*
     ?*  RC140   RF Receive Production GS1 boxes to build Pallet
     ?*  23 June 2014
     ?*  Kenneth Elder
     ?*
     **
     ?*----------------------------------------------------------------
     ?*  Notes
     ?*
     ?*    8 X 20 screens for hand held scanners
     ?*
     *----------------------------------------------------------------
     *  Revisions
     *
     *    06/20/14  KDE  6.50
     *      - Created this as a pallet build process for the new
     *        Production Module.  Started with Program RC180 and
     *        pulled in code and routines from PO237 for UCI
     *        code and GS1 code
700 A*    02/17/16  DLS  7.00
     *      - Changed Pallet Build Adjustment code to P5
700aA*     11/09/16  LMC  7.00a
     *       - UPC file has Database change.
     *       - revise the Production programs to not write anything
     *         to the UPC file.
710 A*    02/02/17  KDE  7.10
     *      - Recompile after adding field in Itemprd
710aA*    02/16/17  KDE  7.10a
     *      - Enh: Correctly calculate Expiration Date from included
     *        date on Production UCI label
710bA*    05/03/17  KDE  7.10b
     *      - Fix: Make several changes to ensure expiration date
     *        is not zeroed during the creation of RCV-PROD slot
710cA*    07/27/17  KDE  7.10c
     *      - Enh: Changes to EPM transaction processing.
     *             Create Lumper Transaction ahead of Putaway
720aA*    08/16/16  LMC  7.20a  reserved
     *      - Enh: UCI Tracking.
750 A*    02/05/21  KDE  7.50
     *      - Fix: Started adding both pounds and kilograms to total received
750aA*    02/17/21  KDE  7.50a
     *      - Enh: Add licadj using code from PO236
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYaA*    07/27/17  KDE  DRYa
     *      - Revised Expiration Calculation routine to send zero
     *        expiration date when Mfg Shelf Life Days is either
     *        zero or Mfg Shelf Life Days is less than combination
     *        of User
     *
     *----------------------------------------------------------------
     ?*  Indicator usage
     ?*
     ?*  01 - 20   FIELD POSITION TO
     ?*  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     ?*  66        Date Code Decipher check to non display cmd11
     ?*  90        VIEW MODE (PROTECT INPUT FIELDS)
     ?*  91        CHANGE MODE (PROTECT KEY)
     ?*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     ?*  98        ERROR ON SCREEN (SOUND BUZZER)
     ?*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     ?*
     ?*----------------------------------------------------------------
     ?*  File Specs
     ?*
     Frc140fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiritem   if   e           k disk
     Flabel     o  a e           k disk
     FLicense   uf a e           k disk
     fslot2     if   e           k disk
     fplined    if   e           k disk
     Foptions   if   e           k disk
     Foptiond   if   e           k disk
     fprdlbhist1uf   e           k disk
     Fupc3      uf a e           k disk
     Fupc2      if   e           k disk    rename(uprec:u2rec)
     Fupc       if   e           k disk
     F                                     rename(uprec:uprecp)
     Fitemprd   if   e           k disk
     Fitemmsc   if   e           k disk
750aAFitemadj   o  a e           k disk
750aAFlicadj    o  a e           k disk    usropn
     ?*----------------------------------------------------------------
     ?*  Table and array definitions
     ?*
     D desc            s             50    dim(50) ctdata perrcd(1)

      *----------------------------------------------------------------
      *  Customer id
      *----------------------------------------------------------------

DRYaA /copy qcopysrc,ID#DAIRYLA

     ?*
     ?*----------------------------------------------------------------
     ?*  DRI parameters
     ?*----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     ?*----------------------------------------------------------------
     ?*  Data Formats
     ?*----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#LICHIST
      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO
     D savever#        s                   like($lnver#)

     ?*----------------------------------------------------------------
     ?*  Convert Barcode Parms
     ?*----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
     ?*------------------------------------------------------------------
     ?* CLCDUR2 parameters
     ?*------------------------------------------------------------------

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
     ?*----------------------------------------------------------------
     ?*  Redefinition data structures
     ?*
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     ?*
     ?*----------------------------------------------------------------
     ?* Data structure
     ?*
     D opdata          ds
     D  optlen               117    117
     ?*----------------------------------------------------------------
     ?*  *SYSTEM  -  System options.
     ?*----------------------------------------------------------------
     ?*
     ?* Fields
     ?*
     ?*    OPEPM   -  Using EPM module (Y,N).
     ?*    OPRF    -  Using RF module (Y,N).
     ?*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     ?*    OPLETD  -  Print letdown labels (Y,N).
     ?*    OPWRNC  -  Perform catch weight variance check (Y,N).
     ?*    OPRG1C  -  Catch weight low variance percentage.
     ?*    OPRG2C  -  Catch weight high variance percentage.
     ?*    OPIMPI  -  Import item fields from host.(Y,N).
     ?*    OPICW   -  Individual catch weight entry (Y,N).
     ?*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     ?*    OPRCDY  -  Number of days to keep receiving logs.
     ?*    OPMPCK  -  Number of days to keep picking logs.
     ?*
     ?* Data structure
     ?*
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
     ?*----------------------------------------------------------------
     ?*  *RCVLBL  -  Receiving options
     ?*
     ?*    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
     ?*    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
     ?*    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
     ?*
     ?*----------------------------------------------------------------
     D rcdata          ds
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
     D  oppchm                24     24
     D  oppmix                25     25
     D  opapck                26     26
     D  opfrcm                27     27
     D  opexck                28     28
     D  opcwen                29     29
     D  opcwtp                30     30
     D  opcwfr                31     31
     D  opipck                32     32
     D  oprupc                33     33
     D  oprups                34     34
     D  oprupf                35     35
     D  optend               117    117
     ?*----------------------------------------------------------------
     ?*  *PICK  -  Picking options
     ?*----------------------------------------------------------------
     ?*
     ?* Fields
     ?*
     ?*    OPNXTP  -  Next pallet number.
     ?*    OPBPCK  -  Bulk pick definition.
     ?*    OPPCUB  -  Maximum cube for PIR.
     ?*    OPFPAL  -  Pallets on fixed fork lift.
     ?*    OPFCUB  -  Maximum cube per fixed pallet.
     ?*    OPFSTP  -  Maximum stops per fixed pallet.
     ?*    OPINCL  -  Include PIR in fixed cube.
     ?*    OPSRCH  -  Number of previous pallets to search for space.
     ?*    OPFBLD  -  Fixed pallet building method.
     ?*                1 = By piece without concern for splitting stop.
     ?*                2 = By stop without splitting stop between plts.
     ?*    OPPBRK  -  Break pallets by aisle (Y,N).
     ?*    OPMPUT  -  Manual Put away (Y,N).
     ?*
     ?* Data structure
     ?*
     D opddta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  opmput                34     34
     D  opdend               117    117
     ?*----------------------------------------------------------------
     ?*  Items zzcnlted for pallet.  Used to reduce proper PAR slots
     ?*  once the pallet is committed and the putaway created
     ?*
650aAd                 ds
650aAd arySel                              dim(150)

650aAD  selDisp                            like(lhdisp)
650aAd                                     overlay(arySel:*next)
650aAD  selLcns                            like(lhlcns)
650aAd                                     overlay(arySel:*next)
650aAD  selQty                             like(lhqty)
650aAd                                     overlay(arySel:*next)
650aAD  selWgt                             like(lhweght)
650aAd                                     overlay(arySel:*next)
650aAD  selGS1                             like(lhGS1)
650aAd                                     overlay(arySel:*next)
     ?*----------------------------------------------------------------
     ?*  Called programs
     ?*
     D @cvtdt          c                   const('CVTDTE')
     D @getsi          c                   const('GETSLOTITM')
     D @fmtit          c                   const('FRMTIT')
     D @addtr          c                   const('ADDSTDTRN')
     ?*----------------------------------------------------------------
     ?*  Called program parameters
     ?*
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     ?*
     ?*   Redefine key
     ?*
     D  $lwhse                19     21  0
     D  $litem                22     36
     D  $lpo2                 37     45
     D  $lrq1                 46     50  0
     D  $lrq2                 51     55  0
     D  $lrq3                 56     60  0
     D  $lrpal                61     63  0
     D  $llott                64     64
     D  $llict                65     65
     ?*
     D  $lpo                  22     30
     D  $lline                31     35  0
     D  $lpitm                36     50
     ?*
     D  $lwhs3                19     21  0
     D  $lpo3                 22     30
     ?*
     D  $lwhs4                19     20p 0
     D  $lpo4                 21     29
     D  $lseq4                30     32p 0
     D  $litm4                33     47
     ?*
     D  $llot                 37     37
     D  $lltrk                38     38
     ?*
     D  $lmfr#                22     32  0
     D  $lmfritem             33     47
     D  $ldakitem             48     62
     ?*
     ?*
     ?*----------------------------------------------------------------
     ?* Misc. work fields
     D $rdata          ds
     D  $rpo                   1      9
     D  $rseq                 10     12p 0
     D  $ritem                13     27
     D  $rlotc                28     57
     D  $rcwgt                58     62p 2
     ?*----------------------------------------------------------------
     ?*
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
     ?*----------------------------------------------------------------
     ?*  Working fields.
     ?*
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8
     ?*----------------------------------------------------------------
     ?*  Data structure for error message parameters
     ?*
     D $mdt            ds
     D  errmsg                 1     50
     ?*
     D  erfld                  1     30
     D  erpo                  31     39
     D  erfrom                31     40
     D  erto                  41     50
     ?*
     D  ermday                 1      2p 0
     D  ermfdt                 3      6p 0
     D  erexdt                 7     10p 0
     D  erltst                11     14p 0
     D  erdday                15     16p 0
     D  eruday                17     18p 0
     ?*
     D  erused                 1      4p 0
     D  erdisd                 5      6p 0
     D  erusrd                 7      8p 0
     D  ersell                 9     12p 0
     ?*
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     ?*
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     ?*
     D  erentd                 1      5p 0
     D  ertod                  6     10p 0
     D                 ds
     D  $ec                    1      2p 0
     ?*----------------------------------------------------------------
     ?*  Message control
     ?*
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
     ?*
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     ?*----------------------------------------------------------------
     ?*  Program info data structure
     ?*
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     ?*----------------------------------------------------------------
     ?*  Workstation exception data structure
     ?*
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     ?*----------------------------------------------------------------
     ?*  Workstation exception redefinition data structure
     ?*
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

     ?*----------------------------------------------------------------
     ?*  Customer id
     ?*----------------------------------------------------------------

      *----------------------------------------------------------
      *  Standard SQL variables and constants
      *----------------------------------------------------------

      *copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D screc         E Ds                  Extname(Scale)
720aAD uprecuom      E ds                  extname(upc) inz(*EXTDFT)

     ?*----------------------------------------------------------------
     ?*  Variables
     ?*
     D $$wohome        s             12
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #oitem          s             15
     D #oswgt          s              7  2
     D #oswt2          s              7  2
     D #oswt3          s              7  2
     D #otype          s              1
     D #oum1           s              2
     D #oum2           s              2
     D #oum2q          s              3  0
     D #oum3           s              2
     D #oum3q          s              3  0
     D #pgmq           s             10
     D @ptrn#          s              7  0
     D @ptask          s              6
     D @pwhse          s              3  0
     D @pwhdp          s              5
     D @pstyp          s              1
     D @pcube          s              9  3
     D @pswgt          s              9  2
     D @ppcs           s              5  0
     D @paisl          s              5  0
     D @pqty1          s              5  0
     D @pqty2          s              5  0
     D @pqty3          s              5  0
     D @prte           s              5
     D @ppo            s              9
     D @pgrp1          s              1
     D @pgrp2          s              1
     D @prtn           s              8
     D @pmsg           s              4
710cAd @pdate          s              8  0
710cAd @pTime          s              6  0
720aAD blank6          s              6
710cAd curtrn#         s              7  0
     D firstlot#       s                   like($lnlot)
     D lotovr          s              1
     D lotwarn         s              1
     D licinfoupd      s               n
     D labelcount      s              3  0
     D labelfound      s               n
     D licComplete     s               n
     D Ok              c                   0
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     D len             s              3  0
     D scaleFound      s               n
     D lastseq         s                   like($lnseq)
750aAD lasttime        s              6  0
     D difflot         s               n
     D diffexpd        s               n
     D #rcvarea        s              6
     D sel             s              3  0
     D curtime         s              6  0
     D curdate         s              8  0
     D unexta          s             13
     D $pindt          s              8  0
     D $pexpd          s              8  0
     D $pbat           s              7  0
     D e               s              2  0
     D pttrn#          s              7  0
     D w1mfdt          s              6  0
     D savew1mfdt      s              6  0
     D savew1exdt      s              6  0
     D w1exdt          s              6  0
     D saveexpd        s                   like(expd)
     D savelotc        s             20
     D zz3item         s             15
     D saveitem        s             15
     D w1lotc          s             20
     d pppti           s              4  0
     d pplot           s             20
     D $emp#           s              5  0
     D w2qt01          s              5  0
     D w2qt02          s              5  0
     D w2qt03          s              5  0
     D $rtn            s              8
     D $shft           s              6
     D $whse           s              3  0
     D $unext          s             13  0
     D $whdp           s              5
     D $styp           s              1
     D moretoscan      s              1
     D w1upcd          s                   like(upupc)
     D UPCwarn         s              1
     D lcnsExists      s               n
     D zmflag          s               n
     D zmsflag         s               n
     D svupc           s             50
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D ck4err          s              1
     D ckupc           s                   like(w1upc)
     D comand          s              5  0
     D enter           s              5  0
     D eof             s              1
     D errflg          s              1
     D error           s               n
     D expd            s              8  0
     D exwgt           s              9  2
     D forevr          s              1
     D help            s              5  0
     D hirng           s              9  2
     D hvskp           s              1
     D iaflag          s              1
     D iatest          s              1
     D kycode          s                   like(opdcod)
     D lflag           s              1
     D lvskp           s              1
     D lwrng           s              9  2
     D mexpd           s              8  0
     D msgk            s              4  0
     D noupc           s              1
     D nxtscr          s              3
     D ocode           s              8
     D ovrrid          s              1
     D prg1c           s              4  3
     D prg2c           s              4  3
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D ssbflg          s              1
     D stop            s              1
     D svcwen          s              1
     D svcwfr          s              1
     D svcwtp          s              1
     D svdwgt          s              7  2
     D svexck          s              1
     D svexdt          s              6  0
     D svmfdt          s              6  0
     D svrupc          s              1
     D s3flag          s              1
     D today           s              8  0
     D warn            s              1
     D wkwhse          s                   like(w1whse)
     D w1whse          s              3  0
     D woexdt          s              8  0
     D wofifo          s              8  0
     D womfdt          s              8  0
     D wotcw           s              9  2
     D wtchk           s              1
     D w1upc           s                   like(upupc)
     D $code           s             10
     D $crew           s              6
     D $ewhdp          s              5
     D $fnam           s             15
     D $init           s              1
     D bfcoffset       s              3  0 inz(0)
     D $lnam           s             20
     D $nhrs           s             31
700aAD CrtUPC          s               n   inz(*off)
710bAd mfgdateHld      s              6  0
720aAD workupc         s                   like(upupc)
750aAD useLicAdj       s               n
750aAD recidnum        s             11p 0
750aAD gaDesc          s             30a
750aAD gaSys           s              1a
750aAD getoptval       s            117a
     ?*----------------------------------------------------------------
     ?*  Prototypes
     ?*----------------------------------------------------------------
     D ucilic#         pr                  extpgm('UCILIC#')
      * Input
     D   unext                       13  0 const
     D   uwhse                        3  0 const
     D calcpti         pr                  extpgm('CALCPTI')
      * Input
     D   pGTIN                             like($bcgtin)
     D   pLOT                              like(pplot)
     D   pPackDate                         like($pmfgdt)
     D   pPTI                              like(pppti)
750aA /copy qcopysrc,p.getoptio

750aAD GetRecId        pr                  extpgm('GETRECID')
750aAD  grWhse                        3s 0 const
750aAD  grFile                       10    const
750aAD  grRecId                      11p 0

750aAD getAdjCode      pr                  extpgm('GETADJCOD')
750aAD  pCode                         2    const
750aAD  pDesc                        30
750aAD  pSys                          1
     ?*----------------------------------------------------------------
     ?*  GS1 results
     ?*
     d $pupc           s             20
     d $prsqt          s              7  0
     d $pqty           s              8  0
     d $p#all          s              5  0
     d $pexpdt         s              6  0
     d $pwgt           s             11  3
     d $pmfgdt         s              6  0
     d $plot           s             20
     d $plpn           s             50
     d $puci           s            100
     d $pxd            s              2
     d $lsavetrn       s              7  0
     d posscode        s              1
     D $parms1         s             48    dim(20)
     ?*----------------------------------------------------------------
     ?*  Parameters
     ?*
     ?*    Input Parameters
     ?*      None
     ?*
     ?*    Returned Parameters
     ?*      None
     ?*
     ?*----------------------------------------------------------------
     ?*  Let the show begin .....
     ?*
     ?*----------------------------------------------------------------
     ?*  Main line
     ?*
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     ?*
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     'CNL'         sccnl
     C                   endcs
     C                   enddo
     ?*
     ?*   Do some clean up before leaving.
     ?*
     C                   exsr      zsclr

     C                   eval      *inlr = *on

     ?*----------------------------------------------------------------
     ?*  adjustQty - Subtract quantity placed on pallet from PAR slot
     ?*----------------------------------------------------------------

     c     adjustQty     begsr

      /free

?      // subtract quantity from PAR slot originally plus adjusted
?      // when label was created.  This data is stored in array
?      // arySel to account for multiple licenses and slots making
?      // up what is scanned for a given item.  I believe a high
?      // percentage of the time there will only be one license
?      // and slot but this covers the base in case

             sel = 1;

             dow sel < 151;

             // jump out once a blank slot is hit.
             if selDisp(sel) = ' ';
                leave;
             endif;

             savever# = $slver#;
             clear $slot;
             $slver# = savever#;

?      // Move fields to slot data structure for quantity adjustment

             $slwhseu = *on;
             $slwhse  = w1whse;

             $slwhdpu = *on;
             $slwhdp = itwhdp;

             $sldispu = *on;
             $sldisp = selDisp(sel);  // par slot

             $saitemu = *on;
             $saitem  = w1item;

             $saqty2  = 0;
             $saqty3  = 0;

             $saqtyu = *on;
             $saqty1 = selQty(sel) * -1;

             $sacwtau = *on;
             $sacwta  = selWgt(sel) * -1;

             $sacodeu = *on;
700 A        $sacode  = 'P5';

             $samemou = *on;
             $samemo  = '';

             $sabyu   = *on;
             $saby    = #user;

             $saemp#u = *on;
             $saemp# = $emp#;

             $sags1u = *on;
             $sags1 = selGS1(sel);

             $saMfgLneu = *on;
             $saMfgLne = $slrlvl;

             $saPrdWgtu = *on;
             $saPrdWgt = $sacwta;

             $saTareWgtu = *on;
             $saTareWgt = 0;

             $saSer#u = *on;
             $saSer# = ' ';

             $saActionU = *on;
             $saAction = 'PBL';
             $saToAreaU = *on;
             $saToArea = 'Slot';

             $dricommand = '*SLOT';
             $drisubcmd  = '%ADJUST';
             $drisys2upd = 'D';
             exsr zzzDriCop;
             if not error;
                // zero verify if status returned as "Z"
                if $slstat = 'Z ';
                   $dricommand = '*SLOT';
                   $drisubcmd  = '%ZEROVFY';
                   $drisys2upd = 'D';
                   exsr zzzDriCop;
                endif;
             endif;

             sel = sel + 1;
             enddo;

      /end-free
     c                   endsr
     ?*----------------------------------------------------------------
     ?*  clr$license  Clear $license data structure fields
     ?*---------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #user
     C                   eval      $lipgm  = #prog
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobn
     C                   eval      $liTowhse = w1whse
     C                   eval      $liTowhseu = *on
     C                   endsr
     ?*----------------------------------------------------------------
     ?*  clr$licinfo  Clear $licinfo data structure fields
     ?*----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
     C                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn

     C                   endsr
     ?*----------------------------------------------------------------
     ?*  clr$slot  Clear $slot data structure fields
     ?*----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr
     ?*----------------------------------------------------------------
     ?*  clr$uciinfo  Clear $uciinfo data structure fields
     ?*----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = $emp#
     C                   eval      $uiaddusr = #user
     C                   eval      $uiaddpgm  = #prog
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobn
     C*                  eval      $uiwhse = lhwhse
     C*                  eval      $uiTowhseu = *on
     C                   endsr
     ?*----------------------------------------------------------------
     ?*  DSPSCR - Display screen
     ?*
     C     dspscr        begsr
     ?*
     ?*   Set ON alarm indicator if error occured
     ?*
     C                   if        error
     C                   eval      *in98 = *on
     C                   endif
     ?*
     ?*   Overlay screen with error messages
     ?*
     C                   exsr      zmdmsg
     ?*
     ?*  Overlay screen with screen to be processed.
     ?*
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     C                   if        nxtscr = '03 '
     C                   exfmt     screen3                              50
     C                   endif
     ?*
     C                   if        nxtscr = 'CNL'
     c                   exfmt     cnlwdw                               50
     C                   endif
     ?*
     ?*   Initialize error indicators and fields
     ?*
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
     ?*
     ?*   Initialize error subfile
     ?*
     C                   exsr      zmcmsg
     ?*
     C                   endsr
      /free
       //---------------------------------------------------------
       // rtvScale - Retrieve the passed in Scale record
       //            Place in SCREC data structure for use
       //---------------------------------------------------------

         begsr rtvScale;

          exec sql
           select *
            into :screc
             from scale
              where scwhse = :lhwhse and scport = :lhport;

          if Sqlstt <> sqlSuccess;
             scaleFound = *off;
             clear screc;
          else;
             scaleFound = *on;
          endif;

         endsr;
      /end-free
     ?*----------------------------------------------------------------
     ?*
     ?*     Screen initialization and wrap-up routines
     ?*
     ?*----------------------------------------------------------------
     ?*
     ?*  Screen 01 initialization
     ?*
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     C                   if        refrsh = *on
     C                   eval      w1uci = *blanks
     c                   movel     *blanks       w1item           15
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  Screen 02 initialization
     ?*
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   exsr      zzfil2
     C     end02i        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  Screen 03 initialization
     ?*
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   if        refrsh = *on
     C                   exsr      zzfil3
     C                   endif
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
     C     end03i        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*              Screen Processing Routines
     ?*
     ?*----------------------------------------------------------------
     ?*
     ?*  SC1  -  Screen 1
     ?*
     C     sc1           begsr
     ?*
     ?*  Test for F3 - Exit
     ?*
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     ?*
     ?*  Test for F5 - Refresh
     ?*
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     ?*
     ?*  Test for F12 - Previous
     ?*
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     ?*
     ?*  Test for other command keys BEFORE verification and update.
     ?*
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     ?*
     ?*  Some other key pressed.
     ?*
     ?*     Check input and write/update record.
     ?*
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     ?*
     ?*  Test for other command keys AFTER verification and update.
     ?*
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     ?*
     C     endsc1        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  SC2  -  Screen 2
     ?*
     C     sc2           begsr
     ?*
     ?*  Test for F3 - Exit
     ?*
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     ?*
     ?*  Test for F5 - Refresh
     ?*
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     ?*
     ?*  Test for F12 - Previous
     ?*
     C                   if        *inkl
     ?*
     ?*  Convert today's date into century format.
     ?*
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     c                   exsr      zzchk1
     C                   eval      refrsh = *on
     c                   eval      nxtscr = '01'
     c                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     ?*
     ?*  Test for other command keys BEFORE verification and update.
     ?*
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     ?*
     ?*  Some other key pressed.
     ?*
     ?*     Check input and write/update record.
     ?*
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     ?*
     ?*  Test for other command keys AFTER verification and update.
     ?*
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     ?*
     C     endsc2        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  SC3  -  Screen 3
     ?*
     C     sc3           begsr
     ?*
     ?*  Test for F10 - Complete Pallet
     ?*
     C                   if        *inkj
     C                   exsr      zzupdTran
     c                   if        error
     C                   goto      endsc3
     c                   endif
     c                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   goto      endsc3
     C                   endif
     ?*
     ?*  Test for F12 - Previous
     ?*
     C                   if        *inkl
     C                   eval      refrsh = *off
     c                   eval      nxtscr = 'CNL'
     C                   goto      endsc3
     C                   endif
     ?*
     ?*  Test for other command keys
     ?*
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     ?*
     ?*  Some other key pressed.
     ?*
     ?*     Check input and write/update record.
     ?*
     ?*
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     ?*
     ?*  Test for other command keys AFTER verification and update.
     ?*
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     ?*
     C     endsc3        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  SCCNL-  Cancel Warning Window
     ?*
     C     scCnl         begsr
     ?*
     ?*  Test for F12 - Previous
     ?*
      /free
        if *inkl;
          nxtscr = '03 ';
          leavesr;
        endif;

      /end-free
     ?*
     ?*  Some other key pressed.
     ?*
     ?*     Check input and write/update record.
     ?*
     c                   if        *inkj
     C                   exsr      zzupdcnl
     ?*
     ?*  Convert today's date into century format.
     ?*
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     c                   eval      refrsh = *on
     C                   eval      nxtscr = '01'
     c                   exsr      scr01i
     c                   endif
     C     endsccnl      endsr
     ?*----------------------------------------------------------------
     ?*
     ?*          SUBROUTINES IN ALPHABETICAL ORDER
     ?*
     ?*----------------------------------------------------------------
     ?*
     ?*  *INZSR  Initialization subrotine
     ?*
     C     *inzsr        begsr
     ?*  Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     ?*
     ?*  Initialize special keys
     ?*
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     ?*
     ?*  Initialize message handling
     ?*
     C                   exsr      zmimsg
     ?*
     ?*   Call user added initialization routine.
     ?*
     C                   endsr
     ?*---------------------------------------------------------------
     ?*
     ?*  SUBROUTINE ZMxxxx  Control message display subfile
     ?*
     ?*    ZMCMSG  Clear message record subfile
     ?*
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     ?*
     ?*    ZMDMSG  Display message record subfile
     ?*
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     ?*
     ?*    ZMIMSG  Initialization necessary for message subfile
     ?*
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     ?*
     ?*    ZMPMSG  Add message record to subfile
     ?*
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf  = #msgf
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
     ?*----------------------------------------------------------------
     ?*
     ?*    ZSCLR   Clear screen
     ?*
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     ?*
     ?*    ZMQMSG  Add message record to subfile from program queue
     ?*
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     ?*----------------------------------------------------------------
     ?*    ZMnnnn  Build and send message nnnn to this program
     ?*----------------------------------------------------------------
     ?*----------------------------------------------------------------
     ?*    DRI0001  Local system caused error
     ?*----------------------------------------------------------------

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

     ?*----------------------------------------------------------------
     ?*    DRI0001s Local system caused error (send to different program)
     ?*----------------------------------------------------------------

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
     C                   endsr
     ?*----------------------------------------------------------------
     ?*      0105s
     ?*
     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   endsr
     ?*
     ?*    ZMSMSG  Send program message to a different program msgq
     ?*
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     ?*----------------------------------------------------------------
     ?*   PIR0202  Code already exists.
     ?*
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*    ZMnnnn  Build and send message nnnn to this program
     ?*----------------------------------------------------------------
     ?*   PT13019  Warning: Entered catch weight not within +/- range.
     ?*
     C     zm19          begsr
     C                   eval      #msgid = 'PT13019'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*   PO23201  Error: UPC code exists for ventor/item.
     ?*
     C     zm21          begsr
     C                   eval      #msgid = 'PO23201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*     PO20001  Warning: Exp date comes before existing date.
     ?*
     C     zm2001        begsr
     C                   eval      #msgid = 'PO20001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*    PO20022  DOCK number must be entered.
     ?*
     C     zm022         begsr
     C                   eval      #msgid = 'PO20022'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*    PO20030  Item or Line must be entered.
     ?*
     C     zm030         begsr
     C                   eval      #msgid = 'PO20030'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*   PIR9999  Generic message - length 78 chars.
     ?*
     C     zm9999        begsr
     C                   eval      #msgid = 'PIR9999'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*   PO23701  Mixed Lots on License.
     ?*
     C     zm3701        begsr
     C                   eval      #msgid = 'PO23701'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*   PIR7971  Error in writing a record.
     ?*
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*   PIR7972  Error in updating a record.
     ?*
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*      0105
     ?*
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*   PIR0110  Value must be > 0.
     ?*
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*   PIR0112  Invalid range entered.
     ?*
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*    PIR1001  Invalid option entered.
     ?*
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*   PIR1005  Value must be 'Y' or 'N'
     ?*
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*    PIR1008  Date is required.
     ?*
     C     zm1008        begsr
     C                   eval      #msgid = 'PIR1008'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*    PIR1009  Date must be > today's date.
     ?*
     C     zm1009        begsr
     C                   eval      #msgid = 'PIR1009'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*     PO13229  Item cannot be accepted.
     ?*
     C     zm3229        begsr
     C                   eval      #msgid = 'PO13229'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*     PO13230  Item cannot be accepted - Exp Date
     ?*
     C     zm3230        begsr
     C                   eval      #msgid = 'PO13230'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*     PO13231  Warning: Exp date comes before existing date.
     ?*
     C     zm3231        begsr
     C                   eval      #msgid = 'PO13231'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*     PO13232  Item cannot be accepted - Calc Exp Date
     ?*
     C     zm3232        begsr
     C                   eval      #msgid = 'PO13232'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*     PO13233  Warning: Calc exp date comes before existing date.
     ?*
     C     zm3233        begsr
     C                   eval      #msgid = 'PO13233'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*     PO13234  CW must be zero when Avg = 'Y' for "First time"
     ?*
     C     zm3234        begsr
     C                   eval      #msgid = 'PO13234'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*     PO13243  Item cannot be accepted. # of days out
     ?*
     C     zm3243        begsr
     C                   eval      #msgid = 'PO13243'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*     TF17201  Warning: Quantity received not equal to ordered.
     ?*
     C     zm7201        begsr
     C                   eval      #msgid = 'TF17201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*   PIR9905  Cursor not in correct position for lookup.
     ?*
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*    PIR1010  Date must be <OR= today's date.
     ?*
     C     zm1010        begsr
     C                   eval      #msgid = 'PIR1010'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*    ZM13250  Item not date sensitive.
     ?*
     C     zm13250       begsr
     C                   eval      #msgid = 'PO13250'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*    PO21001  Multiple qty entered, Catch wt avg must be 'N'
     ?*
     C     zm2101        begsr
     C                   eval      #msgid = 'PO21001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*     PO13226  cannot receive an item, if ready for export.
     ?*
     C     zm3226        begsr
     C                   eval      #msgid = 'PO13226'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*     PO13228  Item cannot be accepted.
     ?*
     C     zm3228        begsr
     C                   eval      #msgid = 'PO13228'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZCHK1   Screen 1 error checking.
     ?*
     C     zzchk1        begsr
     ?*
     C                   eval      error = *off
     C                   eval      errflg = *off
     C                   eval      noupc = *off

     c                   eval      $pexpdt = 0
     c                   eval      $pwgt   = 0
     c                   eval      $pmfgdt= 0
     c                   eval      $plot  = ' '
     c                   eval      *in92 = *off
     c                   eval      *in83 = *off
     c                   eval      *in84 = *off
     c                   eval      *in85 = *off
     c                   eval      *in72 = *off
      *
      /free
        w1lotc = ' ';

        if nxtscr = '03';
           w1uci = w3uci;
        endif;

        setll (w1uci) prdlbhist1;
        reade (w1uci) prdlbhist1;
        if not %equal(prdlbhist1) or %eof(prdlbhist1);
           error = *on;
           errmsg = desc(16);
           exsr zm0105;
        else;
           // ensure the label has not already been scanned to a pallet
           labelfound = *off;
           dow %equal(prdlbhist1) and not %eof(prdlbhist1);
              if lhstat = 'O';
                 unlock prdlbhist1;
                 labelfound = *on;
                 leave;
              else;
                 unlock prdlbhist1;
              endif;
              reade (w1uci) prdlbhist1;
           enddo;
           if not labelfound;
710bA         mfgdateHld = *zeros;
              error = *on;
              errmsg = desc(16);
              exsr zm0105;
           else;
              w1item = lhlitm;
710bA         mfgdateHld = %dec(%subst(lhdtetim:3:6):6:0);
           // get item information record
             exsr zzgeti;
             exsr rtvscale;
           endif;
        endif;

        // make sure the slot exist for the scanned uci.  When label
        // was originally created the qty was plus adjusted into a
        // given slot which must exist to remove the qty once moved
        // to a received slot for putaway
        chain (w1whse:itwhdp:lhdisp) slot2;
        if %found(slot2);
           if slstat <> 'PR';
              error = *on;
              errmsg = desc(20);
              exsr zm0105;
           else;
              if slitem <> ititem;
                 error = *on;
                 errmsg = desc(20);
                 exsr zm0105;
              endif;
           endif;
        else;
           error = *on;
           errmsg = desc(20);
           exsr zm0105;
        endif;

         // Make sure that UCI is associated with a PAR type slot
         if scaleFound;
            chain (lhwhse:scmfgno) plined;
            if %found(plined);
               if inStkAisl <> %subst(lhdisp:1:3);
                  error = *on;
                  errmsg = desc(21);
                  exsr zm0105;
               else;
                  w1lotc = %subst(lhdtetim:1:8) + %char(scmfgno);
               endif;
            else;
               error = *on;
               errmsg = desc(22);
               exsr zm0105;
            endif;
         else;
            error = *on;
            errmsg = desc(23);
            exsr zm0105;
         endif;

        // check to make sure UCI barcode does not already exist
        if w1uci <> ' ' and not error;
          exsr clr$uciinfo;

          w1whse = lhwhse;
          $uiWhse = lhwhse;
          $uiuci  = w1uci;
          $uiitem = lhlitm;
          w1item = lhlitm;

          $dricommand = '*UCIINFO';
          $drisubcmd  = '%CHKACTV';
          $drisys2upd = 'D';
          ck4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
          // if return is *EXIST seton error
          if $drireturn = '*EXIST';
            // if produce item then allow duplicate gs1
710aD   //  chain (lhwhse:lhlitm) itemprd;
710aD   //  if not %found(itemprd);
710aD   //     ipmorp = 'M';
710aD   //  endif;
            if ipmorp = 'M';
               error = *on;
               errmsg = desc(11);
               exsr zm0105;
            endif;
          endif;
        endif;
        if w1uci = ' ' and not error;
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
     ?*
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
     C                   parm                    $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
     c                   endif
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
      * Load UPC
      * if gtin not found, error for invalid barcode scanned
     c                   if        $bcGtinSent
     c                   eval      w1upcd = $bcGtin
     c                   move      $bcgtin       ckupc
     c                   eval      *in92 = *on
     c                   else
     c                   if        $bcai99sent
     c                   else
     c                   eval      error = *on
     C                   eval      errmsg = 'Invalid Barcode Scanned. '
     C                             + 'Scan GS1 barcode.'
     C                   exsr      zm9999

     C                   movel     w1upcd        $CSTR
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $CCMD             8
     C                   parm                    $CSTR            30
     c                   move      $cstr         ckupc
     c                   endif
     c                   endif
      * Load Expiration Date
     c                   if        $bcExpDSent
     c                   eval      $pexpdt = $bcExpD
     c                   eval      *in83 = *on
     c                   endif
      * Load Manufacturing Date
     c                   if        $bcProdDSent
     c                   eval      $pmfgdt = $bcProdD
     c                   eval      *in84 = *on
     c                   else
     c                   if        $bcPackDSent
     c                   eval      $pmfgdt = $bcPackD
     c                   eval      *in84 = *on
     c                   endif
     c                   endif
      * Load Catch Weight
     c                   if        $bcPNtLbSent
     c                   eval      $pwgt  = $bcPNtLb
     c                   eval      *in72 = *on
     c                   endif
      * Load Lot
     c                   if        w1lotc <> ' '
     c                   eval      $plot   = w1lotc
     c                   eval      *in85 = *on
     c                   endif
     ?*
     ?*  UPC not entered.
     ?*
     C                   if        w1upcd = *blanks
     C                   eval      noupc = *on
     C                   endif
     ?*
     ?*  UPC code not on file.
     ?*
     C                   if        w1upcd <> *blanks
     ?*
     ?*  validate upc code if found in our file to make sure it is
     ?*  for the item selected to receive.
     c     upcky2        chain     upc2
     c                   if        %found(upc2)
      * same item - ok
     c                   else
      * does the GTIN exist for a different item, if so this is an error
      /free
         chain (lhwhse: ckupc) upc;
         if %found(upc);
           //diff item - issueing error
           if upitem <> lhlitm;
             error = *on;
             errmsg = desc(13);
             exsr zm0105;
           endif;
         else;
           // but first check to see if we already have a upc code for
           // this item - warn user if we do before adding.
           chain (lhwhse:lhlitm) upc2;
           if %found(upc2);
             // warn user that a UPC already exist for this item - verify
             if %trim(svupc) <> %trim(ckupc);
               eval svupc = ckupc;
               eval error = *on;
               errmsg = *blanks;
               exsr zm21;
               upcwarn = *on;
               leavesr;
             endif;
           endif;
           //if doesn't exist need to add if uci receiving
           if $ifrcvmth = '2';
             upwhse = lhwhse;
             upitem = lhlitm;
             upupc = ckupc;
             upven = 0;
700aA        if CrtUpc = *on;
             write uprec;
700aA        endif;
           endif;
         endif;
      /end-free
     c                   endif
     c                   endif
     ?*
     ?*  UPC code must match the first barcode scanned
      * check to make sure GTIN/UPC match previous entries
      /free
        if w1uci <> ' '
           and w2lic <> ' '
           and nxtscr = '03';
          if lhlitm <> saveitem;
            error = *on;
            errmsg = desc(13);
            exsr zm0105;
          endif;
          if w1lotc <> savelotc and lotovr = *off
             and $bcai99sent = *off;
            error = *on;
            warn = *on;
            lotwarn = *on;
            errmsg = desc(19);
            exsr zm0105;
          endif;
          // assume same lot if no lot found in GS1 and lot was entered on
          // the first recorded scanned, whether it was from gs1 or entered
          if w1lotc = ' ' and savelotc <> ' ';
            $plot = Firstlot#;
          endif;
        endif;
      /end-free
     ?*
     C     endck1        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZCHK2   Screen 2 error checking.
     ?*
     C     zzchk2        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     ?*
     ?*  Make sure license doesn't already exist
     ?*
     c                   if        w2lic <> ' '
     c                   exsr      zzchklcns
     c                   if        error OR lcnsexists
     c                   goto      endck2
     c                   endif
     c                   endif
     ?*
     ?*  Make sure license is scanned on first scan
     ?*
     c                   if        w2lic = ' '
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     c                   eval      errmsg = desc(7)
     c                   exsr      zm0105
     c                   endif
     C     endck2        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZCHK3   Screen 3 error checking.
     ?*
     C     zzchk3        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     ?*
     ?*  Convert today's date into century format.
     ?*
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     c                   eval      zz3item = w1item
     c                   exsr      zzchk1
     c                   if        error = *on or warn = *on
     c                   eval      w1item = zz3item
     c                   endif
     ?*
     C     endck3        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZCHKT   Screen 3 error check totals
     ?*
     C     zzchkt        begsr
     ?*
     ?*     Compare total catchweight to expected catchweight
     ?*
     C                   if        lvskp = *off  and
     C                             wotcw < lwrng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   eval      erlrng = lwrng
     C                   if        hvskp = *on
     C                   eval      erhrng = 0
     C                   else
     C                   eval      erhrng = hirng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
     C                   exsr      zm19
     C                   endif
     ?*
     C                   if        hvskp = *off  and
     C                             wotcw > hirng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   if        lvskp = *on
     C                   eval      erlrng = 0
     C                   else
     C                   eval      erlrng = lwrng
     C                   endif
     C                   eval      erhrng = hirng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
     C                   exsr      zm19
     C                   endif
     ?*
     C                   endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZCMD1   User defined command keys for screen 1.
     ?*
     C     zzcmd1        begsr
     ?*
     ?*  Command keys to check BEFORE verification and update.
     ?*
     C                   if        cmdchk = '*BEFORE '
     ?*
     ?*  Test for F4 - Lookup
     ?*
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     ?*
     C                   other
     ?*
     ?*     Cursor not on a valid lookup field.
     ?*
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     ?*
     ?*  Command keys to check AFTER verification and update.
     ?*
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZCMD2   User defined command keys for screen 2.
     ?*
     C     zzcmd2        begsr
     ?*
     ?*  Command keys to check BEFORE verification and update.
     ?*
     C                   if        cmdchk = '*BEFORE '
     ?*
     ?*  Test for F4 - Lookup
     ?*
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     ?*
     C                   other
     ?*
     ?*     Cursor not on a valid lookup field.
     ?*
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     ?*
     C                   endif
     ?*
     ?*  Command keys to check AFTER verification and update.
     ?*
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZCMD3   User defined command keys for screen 3.
     ?*
     C     zzcmd3        begsr
     ?*
     ?*      F20 - Accept Warning.
     ?*
     C                   if        *inku
     C                   eval      ovrrid = *on
     c                   if        lotwarn = *on
     c                   eval      difflot = *on
     c                   eval      lotovr = *on
     c                   endif
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     ?*
     C     endcm3        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZFIL1   Fill screen 1 fields with info from file.
     ?*
     C     zzfil1        begsr
     ?*
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     ?*
     C                   eval      w1whse = #whse
     ?*
     C                   eval      w1item = *blanks
     c                   eval      saveitem = ' '
     c                   eval      savelotc = ' '
     c                   eval      saveexpd = 0
     c                   eval      w3case = 0
     c                   eval      w3wght = 0
     c                   eval      w1uci = ' '
     ?*
     C                   endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZFIL2   Fill screen 2 fields with info from file.
     ?*
     C     zzfil2        begsr
     ?*
     ?*    Retrieve Item Lot/license plate tracking info.
710cAc                   eval      curtrn# = 0
     c                   eval      w2lic = ' '
     C                   eval      $lcmd = *blanks
     C                   eval      $lprg = #prog
     c                   eval      w2qt01 = lhqty
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w1item
     C                   call      'GETLLP'
     C                   parm                    $lparm
     ?*
     C                   select
     ?*    Lot/license plate tracking values found.
     C                   when      $lrtn = '*OK     '
     C                   if        $llot = 'Y'
     C                   eval      lottrk = '*YES'
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
     ?*
     C                   endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZFIL3   Fill screen 3 fields with info from file.
     ?*
     C     zzfil3        begsr
     ?*
     c                   eval      w3itmd = w2itmd
     c                   eval      w3uci = '               '
     ?*
     C                   endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZGETI   Get item description and pack description.
     ?*
     C     zzgeti        begsr
     ?*
     ?*   Get item
     ?*
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   exsr      zm030
     C                   goto      endgeti
     C                   endif
     ?*
     ?*  Save information about selected item (Item that was sent in)
     ?*
     C                   eval      #otype = ittype
     C                   eval      #oitem = ititem
     C                   eval      #oswgt = itswgt
     C                   eval      #oum1 = itum1
     C                   eval      #oum2 = itum2
     C                   eval      #oum2q = itumq2
     C                   eval      #oswt2 = 0
     C                   if        #oum2q <> 0
     C     itswgt        div(h)    #oum2q        #oswt2
     C                   endif
     C                   eval      #oum3 = itum3
     C                   eval      #oum3q = itumq3
     C                   eval      #oswt3 = 0
     C                   if        #oum3q <> 0
     C     itswgt        div(h)    #oum2q        #oswt3
     C     #oswt3        div(h)    #oum3q        #oswt3
     C                   endif
     ?*
     ?*   Format item description
     ?*
     C                   eval      $iitem = w1item
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         w2itmd
     ?*
     ?*   Get SSB item, if one exists
     ?*
     C                   eval      ssbflg = *off
     C                   if        ittype = ' '
     C                   call      'GETSSB'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
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
     ?*
     C                   if        #brtn = '*FOUND  '
     C                   eval      ssbflg = *on
     C                   endif
     C                   endif
     ?*
     ?*   See if item is an FS-WMS item or not.
     ?*
     C                   move      itdesg        iatest
     C                   if        iatest = '*'
     C                   eval      iaflag = *on
     C                   eval      *in64 = *off
     C                   else
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   endif

     ?*  ... Or department isn't live (this overrides iaflag).

     C                   call      'CHKLIVE'
     C                   parm      itwhse        w1whse
     C                   parm                    itwhdp
     C                   parm                    livestat          8

     C                   if        livestat = '*NOTLIVE'
     C                   eval      *in65 = *off
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   else
     C                   eval      *in65 = *on
     C                   endif
     ?*
     ?*   Get putaway option (Directed or Manual)
     ?*
     C                   eval      kycode = '*PICK   '
     C     opkey2        chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
     ?*
     ?*   Initialize indicator that displays pallet field.
     ?*
     C                   if        opmput = 'Y'
     C                   eval      *in96 = *off
     C                   else
     C                   eval      *in96 = *on
     C                   endif
     ?*
     ?*   Get ITEMMSC record for item.
     ?*
     C     imkey         chain     itemmsc                            79
     C                   if        *in79
     C                   eval      immflg = 'N'
     C                   eval      imdday = 0
     C                   eval      imuday = 0
     C                   eval      immday = 0
     C                   eval      imrg1c = 0
     C                   eval      imrg2c = 0
     C                   endif
710aA /free
710aA      chain (itwhse:ititem) itemprd;
710aA      if not %found(itemprd);
710aA         ipmday = *zeros;
710aA         ipmorp = 'M';
710aA      endif;
710aA /end-free
     ?*
     ?*   Set screen 3 (date/weight) flag.
     ?*
     C                   if        itflgd = 'Y'  or
     C                             immflg = 'Y'
     C                   eval      s3flag = *on
     C                   else
     C                   eval      s3flag = *off
     C                   endif
     ?*
     C                   if        itcwgt = 'Y'
     C                   if        svcwen = '1'  or
     C                             svcwen = '2'
     C                   eval      s3flag = *on
     C                   endif
     C                   endif
     ?*
     ?*  If selected item is a Contract, Alias, SSB item .              . .
     ?*    Then get corresponding Base item.
     ?*
     C                   eval      #bitem = ititem
     C                   eval      #sitem = ititem
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
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
     ?*   Get slot item.
     C                   call      @getsi
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
     C                   parm      ' '           #sitem           15
     C                   parm                    #sityp            1
     C                   parm                    #sdesc           30
     C                   parm                    #spdsc           15
     C                   parm                    #srtn            10
     C                   parm                    #smsg            60
     ?*
     ?*   Get the picking slot for the item.
     ?*
     C                   if        itstyp = 'P'
     C                   eval      $scmd = '*LAST'
     C                   else
     C                   eval      $scmd = '*FIRST'
     C                   endif
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      itwhse        w1whse
     C                   parm                    #sitem
     C                   parm                    $$wohome
     C                   parm      *blanks       $saisl            3
     C                   parm      *zeros        $sloc             3 0
     C                   parm      *zeros        $srlvl            2 0
     C                   parm      *blanks       $shand            2
     C                   parm                    $srtn             8
     ?*
     C     endgeti       endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZINZ    Extra program initialization. Called from *INZSR.
     ?*
     C     zzinz         begsr
     c                   eval      licComplete = *off
     C                   eval      forevr = *on
     C                   eval      $rprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     ?*
     ?*  Define key for PIRITEM file.
     ?*
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1item
     ?*
     C     upcky2        klist
     C                   kfld                    lhwhse
     C                   kfld                    lhlitm
     C                   kfld                    ckupc
     ?*
     ?*     OPTIONS
     ?*
     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    ocode
     ?*
     ?*  Define key for OPTIOND.
     ?*
     C     opkey2        klist
     C                   kfld                    kycode
     C                   kfld                    w1whse
     C                   kfld                    itwhdp
     C                   eval      kycode = '*PICK   '
     ?*
     ?*  Define key for ITEMMSC file.
     ?*
     C     imkey         klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     ?*
     ?*  Convert today's date into century format.
     ?*
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     ?*
     C                   eval      $cvprg = #prog
     C                   eval      #pgmq = #prog
     C                   eval      $rprg = #prog
     ?*
     C                   eval      #pgmq = #prog
     ?*
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse
     ?*
     C                   eval      wkwhse = #whse
     ?*
      * determine if mfr decipher is available to client
     c                   eval      $lcmd = '*OPEN'
     c                   call      'MF200'                              66
     C                   parm                    $lparm
     C                   parm      0             $lexpdat          6 0
     C                   parm      0             $lmfrdat          6 0
     C                   parm                    $lupc            20
     C                   parm      ' '           $ldecvalue       15
     C                   endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZINZ2   Program initialization. Called from main line.
     ?*
     C     zzinz2        begsr
     C                   setoff                                       kckl
     C                   eval      wtchk = *off
     ?*
     ?*   Get screen size being used.
     ?*
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     ?*
     C                   call      'RC160'
     C                   parm      '*OPEN   '    $rcmd             8
     C                   parm                    $rprg            10
     C                   parm      '*INTER  '    $rtype            8
     C                   parm                    w1whse            3 0
     C                   parm                    w1item           15
     C                   parm                    w2qt01
     C                   parm      0             w2qt02            5 0
     C                   parm      0             w2qt03            5 0
     C                   parm      ' '           wopo              9
     C                   parm                    w1ven            11 0
     C                   parm                    w1vnam           40
     C                   parm                    w2vitm           15
     C                   parm      0             $rord             7 0
     C                   parm      *blanks       $rrcod            2
     C                   parm      *blanks       $rrmem           30
     C                   parm                    $rexpd            8 0
     C                   parm      0             $rfifo            8 0
     C                   parm                    w1dev            10
     C                   parm                    w1form           10
     C                   parm                    $rslot           12
     C                   parm      0             $rseq
     C                   parm                    $rrpck            1
     C                   parm                    $rplbl            1
     C                   parm                    w3twgt            9 2
     C                   parm                    $rrq1             5 0
     C                   parm                    $rrq2             5 0
     C                   parm                    $rrq3             5 0
     C                   parm                    $rrpal            3 0
     C                   parm                    $rrtn             8
     C                   parm                    $rmsg             4
     ?*
     C                   eval      lflag = *off
     C                   eval      refrsh = *on
     C                   eval      ocode = '*SYSTEM '
     C                   eval      wkwhse = 0
     C     opkey         chain     options                            79
     C                   eval      sydata = opdata
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw = 'N'
     C                   endif
     C                   exsr      zzinz
     ?*
     c                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZLCNS   Get use generic license option
     ?*
     C     zzlcns        begsr
     ?*
     ?*   Get use generic license option.
     C                   eval      lflag = *off
     C                   eval      svexck = *on
     C                   eval      svcwen = *on
     C                   eval      svcwtp = *on
     C                   eval      svcwfr = 'N'
     C                   eval      svrupc = 'N'
     C                   eval      ocode = '*RCVLBL '
     C                   eval      wkwhse = w1whse
     ?*
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   eval      rcdata = opdata
     C                   if        opplcn = 'Y'
     C                   eval      lflag = *on
     C                   endif
     C                   eval      svexck = opexck
     C                   eval      svcwen = opcwen
     C                   eval      svcwtp = opcwtp
     C                   eval      svcwfr = opcwfr
     C                   eval      svrupc = oprupc
     C                   endif
     ?*
     C                   endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  Create UCI record
     ?*
     C     zzuci         begsr
     ?*
     ?*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
710aAc*   Calculate Expiration date off either Mfg date or Expiration date sent
710aAc*   in UCI from Manufacturing
710aA /free
710bA         // if value in mfgDateHld then force on mfg date fields
710bA         // This cam occur with Produce item produced since Mfg
710bA         // date is not part of UCI
DRYaA         if client = 'DAIRYLAND';
DRYaA            if ipmday = *zeros;
DRYaA               mfgdateHld =*zeros;
DRYaA            endif;
DRYaA         endif;
710bA         if mfgDateHld <> *zeros and *in84 = *off;
710bA            *in84 = *on;
710bA            $pmfgdt = mfgdateHld;
710bA         endif;
710aA         // use values and indicators set earlier when reading UCI and CVTBAR
710aA                    select;
710aA                       when itflgd='Y' and *in84=*on and $pmfgdt <> *zeros;
710aA                          // Use UCI Mfg Date to calculate Expiration Date
710aA                          expd = %dec(%char(%date($pmfgdt:*ymd) +
710bA                   //            %days(ipmday-imuday) :*iso       0):8:0);
710bA                                 %days(ipmday-imuday-imdday) :*iso0):8:0);
710aA                       when itflgd='Y' and *in83=*on and $pexpdt <> *zeros;
710aA                          // Use UCI Mfg Expiration Date for Dakota
710aA                          // If sent this would already have correct date
710aA                          expd = %dec(%char(%date($pexpdt:*ymd) -
710cM                   //            %days(0):*iso0):8:0);
710cA                                 %days(imuday-imdday):*iso0):8:0);
710aA                       other;
710aA                         // No expiration date is stored for this license
710aA                         expd = *zeros;
710aA                    endsl;
710aA /end-free

710aDC*                  move      today         $cvd6i
710aDC*                  move      today         $cvd8o
710aDC*                  move      $cvd8o        expd
710aDC*                  move      $cvd8o        womfdt

710aDC*                  call      'CLCDUR2'
710aDC*                  parm      '*ADD'        $cdcmd
710aDC*                  parm      expd          $cddatein
710aDC*                  parm      0             $cdtimein
710aDC*                  parm      0             $cdyears
710aDC*                  parm      0             $cdmonths
710aDC*                  parm      immday        $cddays
710aDC*                  parm      0             $cdhours
710aDC*                  parm      0             $cdminutes
710aDC*                  parm      0             $cdseconds
710aDC*                  parm      0             $cddateout
710aDC*                  parm      0             $cdtimeout

710aDC*                  call      'CLCDUR2'
710aDC*                  parm      '*SUB'        $cdcmd
710aDC*                  parm      $cddateout    $cddatein
710aDC*                  parm      0             $cdtimein
710aDC*                  parm      0             $cdyears
710aDC*                  parm      0             $cdmonths
710aDC*                  parm      imuday        $cddays
710aDC*                  parm      0             $cdhours
710aDC*                  parm      0             $cdminutes
710aDC*                  parm      0             $cdseconds
710aDC*    expd          parm      0             $cddateout
710aDC*                  parm      0             $cdtimeout

710aDC*                  eval      $cvcmd = '*CMDMDY '
710aDC*                  move      expd          $cvd8i
710aDC*                  call      @cvtdt
710aDC*                  parm                    $cvtdt
710aDC*                  move      $cvd6o        w1exdt

     ?* add records to uci file
     ?*
     ?*    Get User's employee number to be written to PORCV file
     ?*    if any records are flagged as touched.
     ?*
     C                   eval      $code = #user
     C                   eval      $whse = *zeros
     C                   eval      $emp# = *zeros
     C                   eval      $fnam = *blanks
     C                   eval      $init = *blanks
     C                   eval      $lnam = *blanks
     C                   eval      $whdp = *blanks
     C                   eval      $styp = *blanks
     C                   eval      $shft = *blanks
     C                   eval      $crew = *blanks
     C                   eval      $nhrs = *blanks
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
        select;
          when difflot = *on  or
               diffexpd = *on;
            exsr zzlicinfochk;
          when w1lotc = savelotc;
            exsr zzlicinfoseq;
        endsl;

        if not licinfoupd;
          exsr zzlicinfonew;
        endif;

        exsr clr$uciinfo;
        $uiWhse = w1whse;
        $uiItem = w1item;
        $uiuci = w1uci;
        ucilic#($unext: w1whse);
        unexta = %editc($unext:'X');
        $uiuciLcns = 'U:' + unexta;
        $uiLcns = w2lic;
        if difflot = *on or
          diffexpd = *on;
          $uiseq = $lnseq;
        else;
          $uiseq = 1;
        endif;
        $uiSerial = $bcSer#;
        // if user entered weight use that/ if uci had weight use that
        select;
          when $bcPNtLbSent = *on;
            $uiwgtlbs = $bcPNtLb;
          other;
            $uiwgtlbs = 0;
        endsl;
        // Weight KG  - only if uci barcode contained KG
        if $bcPNtKgSent = *on;
          $uiWgtKgs = $bcPntKg;
        else;
          $uiWgtKgs = 0;
        endif;
        $uiSelTrn# = 0;
        $uiSelLbl# = 0;
        $uiSelOrd = 0;
        $uiSelSeq = 0;
        $uiSelCSeq = 0;
        $uiSelTrax = ' ';
        $uiCrtBy = '1';
720aA   if $bcgtin = *blanks;
720aA      $uiaGtin = 0;
720aA   else;
720aA      $uiaGtin  = %DEC($bcGTin:14:0);
720aA   endif;
720aA   workupc = blank6 + $bcgtin;
720aA   uputyp     = 'N';
720aA   exec sql select * into :uprecuom
720aA            from upc
720aA            where upwhse = :w1whse
720aA              and upITEM = :w1item
720aA              and upupc  = :workupc
720aA            fetch first row only;
720aA   $uiaUTyp  = uputyp;
720aA   $uiaSlUTyp = uputyp;
720aA   $uiaLot   = w1lotc;
720aA   if saveexpd = 0;
720aA      $uiaExpD = expd;
720aA   else;
720aA      $uiaExpD = saveexpd;
720aA   endif;
720aA   $uiaEntD  = today;

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
          error = *on;
          errmsg= desc(11);
          exsr zm02;
          leavesr;
        else;

        // ensure label still available for this pallet
        setll (w1uci) prdlbhist1;
        reade (w1uci) prdlbhist1;
        if not %equal(prdlbhist1) or %eof(prdlbhist1);
           error = *on;
           errmsg = desc(16);
           exsr zm0105;
           leavesr;
        else;
           // ensure the label has not already been scanned to a pallet
           labelfound = *off;
           dow %equal(prdlbhist1) and not %eof(prdlbhist1);
              if lhstat = 'O';
                 lhstat = 'P';
                 update lhhst;
                 labelfound = *on;
                 leave;
              else;
                 unlock prdlbhist1;
              endif;
              reade (w1uci) prdlbhist1;
           enddo;
           if not labelfound;
              error = *on;
              errmsg = desc(16);
              exsr zm0105;
              leavesr;
           endif;
        endif;

          error = *off;
          // add info to array use to reduce PAR slots when putaway
          sel = 1;
          dow sel < 151;
             select;
                when selDisp(sel) = lhdisp and selLcns(sel) = lhlcns
                      and selGS1(sel) = lhGS1;
                   selQty(sel) = selQty(sel) + lhqty;
                   selWgt(sel) = selWgt(sel) + lhweght - lhtare;
                   leave;
                when selDisp(sel) = ' ';
                   leave;
             endsl;
             sel = sel +1;
          enddo;
          // when the array is setting on a blank DISP means we should
          // add existing slot to array.
          if selDisp(sel) = ' ' and sel < 151;
                   selDisp(sel) = lhdisp;
                   selLcns(sel) = lhlcns;
                   selQty(sel) = lhqty;
                   selWgt(sel) = lhweght - lhtare;
                   selGS1(sel) = lhgs1;
          endif;

        endif;

        // save the values from the first scan to be used for the license
        if moretoscan <> *on;
          if immflg = 'Y';
            savew1mfdt = w1mfdt;
          endif;
710bD   //  if $itflgd = 'Y';
710bA     if itflgd = 'Y';
            savew1exdt = w1exdt;
          endif;
          saveexpd = expd;
        endif;
        if ($uiWgtKgs + $uiWgtLbs) <> 0;
750 A      if $uiWgtLbs <> 0;
750 D        //w3wght = w3wght + $uiWgtKgs + $uiWgtLbs;
750 M        w3wght = w3wght + $uiWgtLbs;
750 A      else;
750 M        w3wght = w3wght + $uiWgtKgs;
750 A      endif;
        else;
           w3wght = w3wght + lhweght - lhtare;
        endif;
        w3case  = w3case + 1;
        saveexpd = expd;
        savelotc = w1lotc;
        saveitem = lhlitm;
        moretoscan = *on;
        nxtscr = '03 ';
        $puci = ' ';
        w1uci = ' ';
        ovrrid = *off;
        difflot = *off;
        diffexpd = *off;
        lotwarn = *off;
        UPCwarn = *off;
        lotovr  = *off;
        licinfoupd = *off;

      /end-free
     c
     C     enduci        endsr
     ?*
     ?*  ZZUPDCnl Delete scanned records
     ?*
     C     zzupdCnl      begsr
     C                   eval      error = *off
     ?*   Remove any LICUCI records
      /free
            // unmark Production Labels as being placed on pallet
            exsr zzcnlPallet;

            // Delete LICINFO Records
            exsr zzlicinfocan;

            exsr clr$uciinfo;

            // warehouse
            $uiWhse = w1whse;

            // License
            $uiLcns = w2lic;

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
            w2lic = ' ';
            ovrrid = *off;
            $pexpdt = 0;
            $pwgt = 0;
            $pmfgdt = 0;
            $plot = ' ';
            svdwgt = 0;

710cA       exsr zztrnabort;

         endsr;

      /end-free

     ?*----------------------------------------------------------------
     ?*  zzcnlPallet - Reverse status flag on GS1 where pallet cancel
     ?*----------------------------------------------------------------

     c     zzcnlPallet   begsr

      /free

?      // loop through an array that was built as valid GS1
?      // transactions are scanned and placed on pallet.
?      // To get here the user has pressed F10 to cancel the pallet
?      // being built which has marked the GS1 transactions as they
?      // were scanned, therefore we need to open back up to be
?      // allowed for future scans

             sel = 1;

             dow sel < 151;

                // jump out once a blank slot is hit.
                if selDisp(sel) = ' ';
                   leave;
                endif;

                // if this is a product that only includes the GTIN
                // this array can have multiple labels associated.
                // therefore we place the label count in the field
                // labelcount to ensure we loop looking for that many
                // GS1's to unmark which would have been marked as
                // they scanned the boxes
                labelcount = selQty(sel);
                setll (selGS1(sel)) prdlbhist1;
                reade (selGS1(sel)) prdlbhist1;
                dow %equal(prdlbhist1) and not %eof(prdlbhist1);
                   if lhstat ='P';
                      lhstat = 'O';
                      update lhhst;
                      labelcount = labelcount - 1;
                      // look for additional labels if count not zero
                      if labelcount = 0;
                         leave;
                      endif;
                   else;
                      unlock prdlbhist1;
                   endif;
                   reade (selGS1(sel)) prdlbhist1;
                enddo;
                sel = sel + 1;
             enddo;

      /end-free
     c                   endsr
     ?*----------------------------------------------------------------
     ?*  ZZLICINFOCAN  User cancelled - licinfo needs to be deleted
     ?*----------------------------------------------------------------

      /free
        begsr zzlicinfocan;

          exsr clr$licinfo;

          $lnwhse  = w1whse;
          $lnLcns = w2lic;


          $dricommand = '*LICINFO';
          $drisubcmd  = '%DELETEALL';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
          endif;

        endsr;
      /end-free
     ?*----------------------------------------------------------------
     ?*  ZZLICINFOCHK  Check to see if licinfo exist for this lcnslot/exp
     ?*----------------------------------------------------------------

      /free
        begsr zzlicinfochk;

          Lastseq  = 1;
          dow forevr = forevr;

          exsr clr$licinfo;

          $lnwhse  = w1whse;
          $lnlcns  = w2lic;
          $lnseq  = lastseq;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
            lastseq = lastseq - 1;
            leave;
          else;
            // compare lot and date fields
            if $lnlot = w1lotc and
               $lnrcvtyp = '6';
               $lnexpdate = expd;
              // add qty and weight, update licinfo
              $lnttllbs = $lnttllbs + LHWEGHT - lhtare;
              $lnseqqty = $lnseqqty + lhqty;
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
     ?*----------------------------------------------------------------
     ?*  ZZLICINFONew Update New format of LICINFO
     ?*----------------------------------------------------------------

      /free
        begsr zzlicinfonew;

          // Write out standard license information
          exsr clr$licinfo;

          $lnwhse  = w1whse;
          $lnlcns  = w2lic;

          $lnseq = lastseq + 1;
          $lnseqqty = $lnseqqty + 1;
          $lnttllbs = lhweght - lhtare;
          $lnitem = w1item;
          // LNRCVTYP notes
          // 1 = Manual quantity (original method)
          // 2 = Manual quantity with initial GS1 scan
          // 3 = UCI using Mfg GS1 barcodes
          // 4 = UCI using Internal GS1 barcodes (start with 99)
          // 5 = ASN file
          // 6 = Production Module

          $lnrcvtyp = '6';
          $lnrcvtrn# = 0;
          $lnrcvlbl# = 0;

          select;
            when womfdt <> 0;
              $lnentdate = womfdt;
            other;
              $lnentdate = woexdt;
          endsl;

          if wofifo > 0;
            $lnenttype = '*FIFODT';
          else;
710bD    //   if $itflgd = 'Y';
710bA       if itflgd = 'Y';
              select;
                when imuday > 0 or
                     imdday > 0;
710bD    //       if immflg = 'Y';
710bA             if immflg = 'Y' or ipmday <> 0;
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

710bD    //   $lndateflag = $itflgd;
710bA       $lndateflag = itflgd;
            $lnmfgflag = immflg;

            $lnmfgdays = immday;
            $lnusrdays = imuday;
            $lndstdays = imdday;
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

            // calculate the PTI.
            if w1lotc <> ' ' and $bcgtinsent;
              pplot  = %subst(w1lotc: 1 : 20);
              calcpti ($bcgtin: pplot: $pmfgdt: pppti);
              if pppti > 0;
                $lnlotPTI4 = %editc(pppti:'X');
                $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
              endif;
            endif;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%ADDS';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
          endif;

        endsr;
      /end-free
     ?*----------------------------------------------------------------
     ?*  ZZLICINFOSEQ  Used to get the current lnseqqty for accumulator
     ?*----------------------------------------------------------------

      /free
        begsr zzlicinfoseq;

          exsr clr$licinfo;

          $lnwhse  = w1whse;
          $lnlcns  = w2lic;
          $lnseq  = 1;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
          else;
            // accumulate the lnseqqty field
            // if NOT updating transaction#
            // and label #
            $lnrcvtyp = '6';
            if not licComplete;
               $lnseqqty = $lnseqqty + 1;
               $lnttllbs = $lnttllbs + lhweght - lhtare;
            else;
               $lnRcvtrn# = curtrn#;
               $lnRcvlbl# = lblbl#;
               $lnrcvqty = w3case;
            endif;
            $dricommand = '*LICINFO';
            $drisubcmd  = '%CHANGES';
            $drisys2upd = 'D';
            ck4err = *on;
            exsr zzzdricop;
          endif;

        endsr;
      /end-free
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZUPD1   Update for screen 1.
     ?*
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   exsr      zzlcns
     C                   eval      refrsh = *on

      *  clear pallet build array
      *  This array is used to reduce PAR slots once pallet build
      *  is committed on screen three.
     c                   eval      sel=1
     c                   dow       sel < 151
     c                   eval      selDisp(sel) = ' '
     c                   eval      selLcns(sel) = ' '
     c                   eval      selQty(sel) = 0
     c                   eval      selWgt(sel) = 0
     c                   eval      sel = sel +1
     c                   enddo

     C                   exsr      scr02i
     C     endup1        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZUPD2   Update for screen 2.
     ?*
     C     zzupd2        begsr
     ?*
     C                   eval      error = *off

710cAc                   exsr      zzcrttran
     c                   exsr      zzuci
     C                   exsr      scr03i
     ?*
     C     endup2        endsr
     ?*----------------------------------------------------------------
     ?*
     ?*  ZZUPD3   Update for screen 3.
     ?*
     C     zzupd3        begsr
     C                   eval      error = *off
     ?*
     c                   exsr      zzuci
     c                   if        not error
     c                   eval      w3uci = ' '
     c                   endif
     ?*
     C     endup3        endsr
     ?*----------------------------------------------------------------
     ?*  ZZCHKLCNS  Check for active license
     ?*
     C     zzchklcns     begsr
     C                   eval      lcnsExists = *off

     ?*  See if license exists in licactive file.

     C                   exsr      clr$license
     C                   eval      $liToLcnsU = *on
     C                   eval      $liToLcns = w2lic
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = '*OK'
     C                             and $liToAisl =  'OSS'
     C                             or $drireturn = 'INVLDLCNS'
     C*                  if        error
     C                   eval      lcnsExists = *off
     C                   eval      error = *off
     ?*
     ?*  Check LICLOG before accepting this license
     ?*
     C                   exsr      clr$license
     C                   eval      $liToLcnsU = *on
     C                   eval      $liToLcns = w2lic
     C                   eval      $liOLcnsU = *on
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETINFO'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *off
     C                   exsr      zzzdricop
     c* if we get an ok on the return this means it exist - don't use
     C                   if        $drireturn = '*OK'
     C                             and $liToAisl <> 'OSS'
     C                   eval      lcnsExists = *on
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     c                   eval      errmsg= desc(18)
     c                   exsr      zm02
     C                   endif

     C                   leavesr
     C                   else
     C                   eval      lcnsExists = *on
     C                   eval      error = *on
     C                   eval      *in15 = *on
     C                   eval      *in35 = *on
     c                   eval      errmsg= desc(18)
     c                   exsr      zm02
     C                   endif


     C                   endsr
710cA*----------------------------------------------------------------
710cA*  ZZTRNABORT  Abort/Undo a transaction.
710cA*----------------------------------------------------------------
710cA
710cAC     zztrnabort    begsr
710cA
710cA*    If this replenishment was created by this program then,
710cA*    remove transaction completely. Otherwise just reset
710cA*    transaction
710cA
710cAC                   call      'ADJTRAN2'
710cAC                   parm      '*ABORT'      @pcmd
710cAC                   parm      #prog         @pprg
710cAC                   parm      '*BATCH'      @ptype
710cAC                   parm      curtrn#       @ptrn#
710cAC                   parm      ' '           @ptask
710cAC                   parm      0             @pwhse
710cAC                   parm      ' '           @pwhdp
710cAC                   parm      ' '           @pstyp
710cAC                   parm      0             @pcube
710cAC                   parm      0             @pswgt
710cAC                   parm      0             @ppcs
710cAC                   parm      0             @paisl
710cAC                   parm      0             @pqty1
710cAC                   parm      0             @pqty2
710cAC                   parm      0             @pqty3
710cAC                   parm      ' '           @prte
710cAC                   parm      ' '           @ppo
710cAC                   parm      ' '           @pgrp1
710cAC                   parm      ' '           @pgrp2
710cAC                   parm      0             @pdate
710cAC                   parm      0             @ptime
710cAC                   parm      #user         @puser
710cAC                   parm      ' '           @prtn
710cAC                   parm      ' '           @pmsg
710cA
710cAC                   endsr
710cA
     ?*----------------------------------------------------------------
     ?*  ZZCRTTRAN     Create LUMPER/PALLET BUILD TRANSACTION
     ?*----------------------------------------------------------------

     C     zzcrttran     begsr
710cD *
     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd
     C                   parm      #prog         @pprg
     C                   parm      '*BATCH'      @ptype
     C                   parm      0             @ptrn#
     C                   parm      'LUMPPD'      @ptask
     C                   parm      w1whse        @pwhse
     C                   parm                    @pwhdp
     C                   parm                    @pstyp
     C                   parm      0             @pcube
     C                   parm      0             @pswgt
     C                   parm      0             @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      'K'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      0             @pdate
     C                   parm      0             @ptime
     C                   parm      #user         @puser
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
710cAc                   eval      curtrn# = @ptrn#

     C     endcrttran    endsr

     ?*----------------------------------------------------------------
     ?*  ZZCRTPUTA     Create Putaway TRANSACTION
     ?*----------------------------------------------------------------

     C     zzcrtputa     begsr

     ?*    Put license into RCV slot for Repack Item

710cDC                   exsr      zzurcvSlot
     c                   eval      @ptrn# = curtrn#
710cD *
     C                   call      'ADJTRAN2'
     C                   parm      '*CREATE '    @pcmd
     C                   parm      #prog         @pprg
     C                   parm      '*BATCH'      @ptype
     C                   parm                    @ptrn#
     C                   parm      'PUTPD '      @ptask
     C                   parm      w1whse        @pwhse
     C                   parm                    @pwhdp
     C                   parm                    @pstyp
     C                   parm      lbcube        @pcube
     C                   parm      lbswgt        @pswgt
     C                   parm      lbqpck        @ppcs
     C                   parm      1             @paisl
     C                   parm      1             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      'K'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      0             @pdate
     C                   parm      0             @ptime
     C                   parm      #user         @puser
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg

     ?*  Update/Create License

      /free
                         chain (w1whse:w2lic) license;
                         litrn# = curtrn#;
                         if %found(license);
                         update lirec;
                         else;
      /end-free
     ?*     Record not found. Try adding record.
     ?*
     C                   eval      liwhse = w1whse
     C                   eval      lilcns = w2lic
     C                   write     lirec
     C                   endif

     c                   eval      licComplete = *on
     C                   exsr      zzlicInfoSeq
     c                   eval      licComplete = *off

     C                   endsr
500dA*----------------------------------------------------------------
500dA*  ZZTRNIDLE   Start and IDLE transaction.
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnidle     begsr

710tA *   For Production defined employees in file PLABCSTLNE the
710tA *   system will always put them on their default task instead
710tA *   of IDLE.  The reason for this is to spread their cost at
710tA *   end of day instead of between operations going to indirect.
710tA *   This routine only gets called when a Close transaction is
710tA *   called from MRC instead of the CRTSTRT, and therefore no new
710tA *   task.
710tA *
710tA /free
710tA        exec sql select lctask into :@ptask
710tA                  from pLabCstLne
710tA                    where lcucde=:#User;
710tA        if sqlStt <> sqlSuccess;
710tA           @pTask = 'IDLE';
710tA        endif;
710tA /end-free
     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #prog         @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      w1whse        @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr
     ?*----------------------------------------------------------------
     ?*  ZZUPDTRAN     Update Putaway Transaction with all product
     ?*----------------------------------------------------------------

     C     zzUpdTran     begsr
      *
      *        Update transaction record.
      *
     C                   call      'ADJTRAN2'
     C                   parm      '*INCTTL'     @pcmd
     C                   parm      #prog         @pprg
     C                   parm      '*BATCH'      @ptype
     C                   parm      curtrn#       @ptrn#
     C                   parm      ' '           @ptask
     C                   parm      0             @pwhse
     C                   parm      ' '           @pwhdp
     C                   parm      ' '           @pstyp
     C                   parm      lbcube        @pcube
     C                   parm      lbswgt        @pswgt
     C                   parm      lbqpck        @ppcs
     C                   parm      1             @paisl
     C                   parm      1             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      ' '           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      0             @pdate
     C                   parm      0             @ptime
     C                   parm      #user         @puser
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg

     C                   call      'ADJTRAN2'
     C                   parm      '*CLOSE '     @pcmd
     C                   parm      #prog         @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      curtrn#       @ptrn#
     C                   parm      ' '           @ptask
     C                   parm      0             @pwhse
     C                   parm      ' '           @pwhdp
     C                   parm      ' '           @pstyp
     C                   parm      lbcube        @pcube
     C                   parm      lbswgt        @pswgt
     C                   parm      lbqpck        @ppcs
     C                   parm      1             @paisl
     C                   parm      1             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      ' '           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      0             @pdate
     C                   parm      0             @ptime
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
710 Ac                   exsr      zzTrnIdle
710 Ac                   exsr      zzCrtPuta
     C                   endsr
     ?*---------------------------------------------------------------
     ?*
     ?*  zzurcvSlot   Put license into RCV slot
     ?*
     C     zzurcvSlot    begsr

     C                   move      today         curdate
     C                   move      today         $pindt

     ?*  Get batch number for labels.

     C                   call      'PIRBAT#'
     C                   parm      *zeros        $pbat

     ?*  Get transaction number.

     C                   call      'PIRTRN#'
     C                   parm                    pttrn#
     c                   eval      curtrn# = pttrn#

     ?*  Create label record for Normal qty.

     C                   clear                   lbrec
     C                   eval      lbwhse = w1whse
     C                   eval      lbwhdp = itwhdp
     C                   eval      lbaisl = *blanks
     C                   eval      lbloc = *zeros
     C                   eval      lbrlvl = *zeros
     C                   eval      lbhand = *blanks
     C                   eval      lbpseq = *zeros
     C                   eval      lbstyp = *blanks
     C                   eval      lbqryf = *zeros
     C                   eval      lbdisp = *blanks
     C                   movel     '*MANUAL'     lbdsp2
     C                   eval      lbitem = w1item
     C                   eval      lbseq = *zeros
     C                   eval      lbpbat = $pbat
     C                   eval      lbpo = *blanks
     C                   eval      lbord = 0
     C                   eval      lbqalc = w3case
     C                   eval      lbqpck = w3case
     C                   eval      lbtie = *zeros
     C                   eval      lbhigh = *zeros

     ?*        Create label record for Normal qty.

     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = itum1
     C                   eval      lbucub = itcube
     C     lbucub        mult      w3case        lbcube
     C                   eval      lbuwgt = w3wght
     C     lbuwgt        mult      w3case        lbswgt
     ?*
     C                   eval      lbtrn# = curtrn#
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbgrp1 = 'K'
     C                   eval      lbgrp2 = *blanks
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = curdate
     C                   time                    lbstim
     C                   eval      lbrdte = curdate
     C                   write     lbrec

     ?*  Put license into a RCV slot

     C                   eval      #rcvArea = 'PROD'

     C                   exsr      clr$slot
     C                   eval      $saemp#u = *on
     C                   eval      $saemp# = $emp#
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = itwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = w1item
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slrlvlu = *on
     C                   eval      $slstyp = itstyp
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = expd

     c                   eval      $saitemu = *on
     c                   eval      $saitem = w1item
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = w3case
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'PRD'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = curtrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = lblbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = w2lic
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea

     c                   eval      $saFrmLcnsU = *on
     c                   eval      $saFrmLcns = lhlcns
     c                   eval      $saoLcnsU = *on
     c                   eval      $saoLcns = lhlcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%RCVIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmsflag  = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   goto      endurcvslot
     c                   else
      /free
750aA    exsr zzgetdatetime;
750aA    iawhse = $slwhse;
750aA    iaitem = $slitem;
750aA    iadate = curdate;
750aA    iatime = curtime;
750aA    iaby   = #user;
750aA    iawhdp = $slwhdp;
750aA    iadisp = $sldisp;
750aA    iacwta = w3wght;
750aA    iaqty1 = w3case;
750aA    iaqty2 = 0;
750aA    iaqty3 = 0;
750aA    iaudte = 0;
750aA    iautim = 0;
750aA    iacode = 'P5';
750aA    iamemo = 'Production Mod Receipt';
750aA    write iarec;
750aA    exsr wrtlicadj;
      /end-free
      *  when successful remove quantity from PAR slot
     c                   exsr      adjustQty
     C                   endif

     C     endurcvslot   endsr
     *----------------------------------------------------------------
     *  zzgetdatetime  Get current date & time
     *----------------------------------------------------------------
     *
     C     zzgetdatetime begsr

     C                   time                    curtime

     C                   if        curtime < lasttime or curdate = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr
750aA*---------------------------------------------------------------
750aA*
750aA*  WRTLICADJ  Write LICADJ record.
750aA /free
750aA  begsr wrtlicadj;
750aA   monitor;
750aA     GetOptions(%editc(iawhse:'X'): '*ADJUST': '002': '001': getoptval);
750aA     if getoptval = 'Y';
750aA       useLicAdj = *on;
750aA     else;
750aA       useLicAdj = *off;
750aA     endif;
750aA   on-error;
750aA     useLicAdj = *off;
750aA   endmon;
750aA
750aA   // If option not on, do nothing.
750aA   if useLicAdj = *off;
750aA     leavesr;
750aA   endif;
750aA
750aA   // If file not open, open it.
750aA   if not %open(licadj);
750aA     open LicAdj;
750aA   endif;
750aA
750aA   // Get unique adjustment record id.
750aA   GetRecId(iawhse: 'LICADJ': recidnum);
750aA
750aA   // Get adjustment code description/system.
750aA   GetAdjCode(iacode: gaDesc: gaSys);
750aA
750aA   adjwhs = iawhse;
750aA   adjnbr = %char(recidnum);
750aA   adjparent = *blanks;
750aA   adjcode = iacode;
750aA   adjcsys = gaSys;
750aA   adjitem = iaitem;
750aA   adjaqty1 = iaqty1;
750aA   adjaqty2 = iaqty2;
750aA   adjaqty3 = iaqty3;
750aA   adjcqta = iacwta;
750aA   adjwhdp = iawhdp;
750aA   adjdisp = iadisp;
750aA   adjaisl = $slaisl;
750aA   adjloc = $slloc;
750aA   adjrlvl = $slrlvl;
750aA   adjhand = $slhand;
750aA   adjstat = 'A';
750aA   adjmemo = iamemo;
750aA   adjlcns = w2lic;
750aA   adjaddts = %timestamp();
750aA   adjadduc = %timestamp();
750aA   adjaddcpgm = #prog;
750aA   adjaddjpgm = #prog;
750aA   adjaddemp = *zero;
750aA   adjaddcusr = #user;
750aA   adjaddjusr = #user;
750aA   adjaddjob = #job;
750aA   adjaddnbr = #jobn;
750aA   adjexpflag = *blank;
750aA   adjdrislot = *blanks;
750aA   adjdrilic = *blanks;
750aA
750aA   write adjrec;
750aA
750aA  endsr;  // wrtlicadj
750aA /end-free
     ?*----------------------------------------------------------------
     ?*  zzzdricop  Call DRICOP
     ?*----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $dridata = $lichist
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
     C*                  eval      $dridata2 = $uciinfo2
720aMC                   eval      $dridata2 = $uciinfo2
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
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error and ck4err = *on
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   select
     C                   when      zmsflag
     C                   exsr      zm0105s
     C                   when      zmflag
     C                   exsr      zm0105
     C                   endsl

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   exsr      zm0001s
     C                   when      zmflag
     C                   exsr      zm0001
     C*                  exsr      zzerrind
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $lichist = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
     C*                  eval      $uciinfo2 = $dridata2
720aMC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      ck4err = *off
     C     enddricop     endsr
     ?*----------------------------------------------------------------*********
     ?*
     ?*  COMPILE TIME TABLES
     ?*
**
Normal quantity
Breakdown 1 quantity
Breakdown 2 quantity
Catch weight
Average
UPC code
Number of pallets
* * INVALID ITEM * *
F7 only for c/w's
Tie/Hi Qty on Pallet
UCI Barcode
Scan/Enter Litense
Different Item
Different GTIN/UPC
License
GS1 Issue(NF or DUP)
GS1 not Production
License issue
Warn: Different Lot
Slot not found
UCI not PAR stock
UCI MFG line NV
UCI Scale Port NV
