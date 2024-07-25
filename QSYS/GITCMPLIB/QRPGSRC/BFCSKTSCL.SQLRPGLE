     H copyright('(c) Copyright BFC Software, Inc - 2003')
     H dftactgrp(*NO)
     H actgrp('BFCSKTSCL')
     H optimize(*NONE)
     H decedit(*JOBRUN)
     H truncnbr(*NO)
     H option(*srcstmt : *nodebugio)

     F*----------------------------------------------------------------
     F*   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*----------------------------------------------------------------
     F*
     F*  BFCSKTSCL   Client program for Toledo Scales
     F*  08 January 2014
     F*  Kenneth Elder
     F*
     F*  Revisions
     F*
650 AF*    01/08/14  KDE  6.50
     F*      - Created.
700 AF*    04/10/15  KDE  7.00
     F*      - Changed to work with Box Breaker application which
     F*        allows user to break case into eaches to brk dwn 1 uom
700A F*    10/03/2015 KDE 7.00A
     F*      - Changed to update screen weight in manual screen mode
     F*        to reflect changing scale weight as user applies more
     F*        weight.  The logic prior to this change was to only
     F*        change weight when scale is coming off zero and gets
     F*        stable.  This will allow for produce house to build
     F*        weight for fixed fruit tray or something similar
700b F*     11/03/2015 KDE 7.00b
     F*      - Changed to record Production as P3 adjustment code
     F*        instead of P1.
700c F*     11/18/2015 DLS 7.00c
     F*      - Changed inlsts to 20a
700d F*     10/06/2016 KDE 7.00d
     F*      - Changed to write error to scale record if item used that
     F*        has no UPC defined in cross reference and either option
     F*        is not checked to create on the fly or the item is not
     F*        purely numeric.
700e *     11/08/16  KDE  7.00e
     *       - Include SQL compile parms within SQL Set in Calcs
700f *     11/09/16  LMC  7.00f
     *       - UPC file has Database change.
     *       - revise the Production programs to not write anything
     *         to the UPC file.
710 A*     02/02/17  KDE  7.10
     *       - File change ITEMPRD so recompiled
     *       - File change CUSTMAST so recompiled
     *       - Add code to accept Tare weight with Manual label
     *       - Add code to override scale mfg line with what is in Work Order
710aA*     03/08/17  KDE  7.10a
     *       - Do not create UCISPLITS records for MultiDay RM UCI.  The Multi
     *         Day UCI is placed in SCUCI.  The code is changed to ignore if
     *         SCDISP has MULTIDAY.  It should only add to UCISPLITS when
     *         Box Breaker transaction
     F*
710bA*     06/08/17  TAB  7.10b
     *       - Made mod to Box Breaker side that will get the UOM UPC when doing
     *         a breakdown. ***In order for this mod to work UPC file with UOM
     *                         needs to be in place****
     *
710cA*     06/29/17  TAB  7.10c
     *       - FIX: When checking the UPC xref file it finds the first UPC record
     *         for the item. Even if it exists it goes through the logic of checking
     *         for non numeric data, but does not send the message to the user
     *         because of what was changed in mod 7.10d below.
     *         The change now loops through the UPC file for a numeric UPC code for
     *         item. If no valid UPC is found then it will send the message.
     *
710dA*     07/03/17  KDE  7.10d
     *       - FIX: Corrected code that was suppose to return a non numeric error
     *         if a valid upc record was found without all numeric data.  The change
     *         from 710c should work better since it will search until it finds a valid
     *         numeric upc but this mod will be a catch all in case it reaches this
     *         point going forward and return an error.
     *
710eA*     07/11/17  KDE  7.10e
     *       - Enh: Changed to create Box Breaker transactions so they
     *         include a case sequence number in PRDLBHIST and UCISPLITS
     *         to differ between non unique case uci's
     *       - Enh: Correct reade issue from mod 7.10c.  %found should not
     *         be used with reade.  Should use %equal
     *
710fA*     08/10/17  KDE  7.10f
     *       - Fix: Return error and no updates when Prod slots missing
     *
710GA*     08/16/17  KDE  7.10G
     *       - Fix: Not reading item record when required for BXB
     *
720 A*     01/18/18  KDE  7.20
     *       - Enh: Added capability to add WIP item transactions to LIN
     *         slot instead of a PAR slot as production
     *
720aA*     11/14/18  LMC  7.20a
     *       - Enh: uci tracking - reserved                           IN
     *      - Enh:  Populate parms in DRIUCIINFO for new
     *              fields/new file uciinfoexa file.
     *
730aA*     01/30/19  KDE  7.30a
     *       - Enh: Recompile due to PWRKORD change
730bA*     02/15/19  KDE  7.30b
     *       - Fix:  Change how component determined
740 A*     03/03/20  KDE  7.40
     *       - Enh:  Change label generating code for Item only
     *         label generator.  No inventory or anything else updated
740aA*     03/11/20  KDE  7.40a
     *       - Enh:  Fix value too small error and return errors for weight
     *         beyond 99,999 pounds and error when weight minus scale weight
     *         is negative
740bA*    07/01/20  LMC  7.40b
     *     - We have changed our internal gs1 labels to use AI code 98
     *       instead of AI code 01.
740cA*     08/12/20  KDE  7.40c
     *       - Enh:  Changed to work with latest version of software for Toledo
     *         scales and keep code to still work with older version as well
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTRPGMOD MODULE(*) SRCFILE(*)
     *
     *    CRTPGM PGM(*) MODULE(*) ACTGRP(BTS)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     H bnddir('QC2LE':'QUSAPIBD':'PIRVBNDDIR':'BFCBND')

     F*----------------------------------------------------------------
     F*  File Specs
     F*----------------------------------------------------------------

     FScale     uf   e           k disk
     F                                     prefix(s)
     FPlined    if   e           k disk
     Fpiritem   if   e           k disk
710 AfpWrkord   if   e           k disk
     fitemprd   if   e           k disk
     Foptions   if   e           k disk
     Fitemmsc   if   e           k disk
     Fcustmast  if   e           k disk
700 Afucisplits uf a e           k disk
     Fupc       uf a e           k disk    rename(uprec:uprecxrf)
     F                                     prefix(xr)
710bDF**upc2      if   e           k disk
710bAFupc5      if   e           k disk
     Fbfcscllog O    E           K Disk

     D*----------------------------------------------------------------
     D*  Arrays
     D*----------------------------------------------------------------
     D A9              S              1A   Dim(9)
     D A14             S              1A   Dim(14)
520aAD A18             S              1A   Dim(18)
     *
     *  Data Structure to hold previous log buffer to prevent
     *     repeating command from scale server
     *
     D                 ds
     D aryBuffer                   6144    dim(6)
     D  prvSnd                     1024a   overlay(aryBuffer:*next)
     D  prvRcv                     1024a   overlay(aryBuffer:*next)
     D  prvSel                     1024a   overlay(aryBuffer:*next)
     D  prvCl1                     1024a   overlay(aryBuffer:*next)
     D  prvCl2                     1024a   overlay(aryBuffer:*next)
     D  prvOpn                     1024a   overlay(aryBuffer:*next)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

700 A*----------------------------------------------------------------
700 A*  Convert Barcode Parms
700 A*----------------------------------------------------------------

700 A /COPY *libl/qcopysrc,C#CVTPARMS
700 A /COPY *libl/qcopysrc,C#BARCODE

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#PROD
700 A /COPY *libl/qcopysrc,C#LICINFO
700 A /COPY *libl/qcopysrc,C#UCIINFO
     D saveVer#        s                   like($ppver#)

     *------------------------------------------------------------------
     *  Socket prototypes, constants and variables and Data Q Prototyp
     *------------------------------------------------------------------
500cA /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,$SocketsH
      /copy qcopysrc,$SignalH

     D lhhst         E Ds                  Extname(PrdlbHist)

     D usleep          pr            10u 0 extproc('usleep')
     D  Interval                     10u 0 value

     D gethostbyname   PR              *   extproc('gethostbyname')
     D host_name                       *   value options(*string)

     D qrcvdtaq        PR                  extpgm('QRCVDTAQ')
     D  dqname                       10
     D  dqlib                        10
     D  dqlen                         5  0
     d  dqdata                     1024
     d  dqwait                        5  0
     d  dqorder                       2
     d  dqkeylen                      3  0
     d  dqkey                        15
     d  dqsnd                         3  0
     d  dqsndinfo                    50

740 AD pirgtin#        pr                  extpgm('PIRGTIN#')
740 A * Input
740 AD   unext                       14    const
740 AD   uwhse                        3  0 const

700 AD ucilic#         pr                  extpgm('UCILIC#')
700 A * Input
700 AD   unext                       13  0 const
700 AD   uwhse                        3  0 const

      *------------------------------------------------------------------
      * Buffers ...
      *------------------------------------------------------------------

     D  BufferDef      S           1024a
     D  BufferSize     C                   Const(%Len(BufferDef))
415aAD  BufferDefO     S             70a
415aAD  BufferSizeO    C                   Const(%Len(BufferDefO))

      * #BufferInDS - Incoming request stream...
     D  #BufferInDS    DS
     D   #sBufferIn                        Like(BufferDef)
     D   #BufferIn                    1a   Dim(BufferSize)
     D                                     Overlay(#sBufferIn)
      *
      * #BufferPrvDS - Previous buffer to prevent blowing out log file
     D  #BufferPrvDS   DS
     D   prvBuffer                         Like(BufferDef)
      *
      * #BufferWrkDS - Incoming request string - work fields
     D  #BufferWrkDS   DS
     D   #sBufferWrk                       Like(BufferDef)
      *
      * #BufferShlDS - Previous Send Request saved
     D  #BufferShlDS   DS
     D   #sBufferShl                       Like(BufferDef)
      *
      * #BufferODS - outgoing request string and stream...
     D  #BufferOutDS   DS
     D   #sBufferOut                       Like(BufferDefO)
     D   #BufferOut                   1a   Dim(BufferSizeO)
     D                                     Overlay(#sBufferOut)
      *
     D  csvrecinds     ds
     D   csvrecin                          like(bufferdef)
     D   csvaryin                     1a   dim(buffersize)
     D                                     Overlay(CSVRecIn)
      *
     D  #RQRecord      DS
     D   #RQData               1   1000
     D   #RQMsg             1001   1024
     D   #RQRRN                1     10  0
     D   #RQType              11     11
      *
      *  #RSRecord is the general container for outgoing responses...
     D  #RSRecord      DS          1024
     D   #RSRec                1   1024
     D   #RSData               1   1000
     D   #RSMsg             1001   1024
     D   RecOut                       1    Dim(1024) Overlay(#RSRec)

     D  #RIRecord      DS          1024
     D   RecInFld              1   1024
     D   RecIn                        1    DIM(1024) Overlay(RecInFld)
     D  RecInLen       S              5P 0 Inz(0)
     D  x              S              5P 0 Inz(0)

      *  definitions used to lookup host ip by dns name
     D p_hostent       S               *
     D hostent         DS                  Based(p_hostent)
     D h_name                          *
     D h_aliases                       *
     D h_addrtype                    10I 0
     D h_length                      10I 0
     D h_addr_list                     *
     D p_h_addr        S               *   Based(h_addr_list)
     D h_addr          S             10U 0 Based(p_h_addr)

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D scalerc       E Ds                  Extname(Scale)

      *------------------------------------------------------------------
      * Table and array definitions
      *------------------------------------------------------------------
     D A11             S              1    DIM(11)
     D A12             S              1    DIM(12)
     D A80             S              1    DIM(80)

     D Buf             S              1    DIM(1024)
     D  #AmtRecd       S             10i 0 Inz(0)
     D  CRLFPos        S              5P 0 Inz(0)
     D  Start          S              5P 0 Inz(0)

     *----------------------------------------------------------------
     *  Production Label Parms
     *----------------------------------------------------------------

     d lcmd            s              8
     d llset           s              6
     d llfmt           s              8
     d lcwhse          s              3
     d lnote1          s             50
     d lnote2          s             50
     d lnote3          s             50
     d lnote4          s             50
     d lnote5          s             50
     d lnote6          s             50
740aDd*lgs1            s             48
740aMd lgs1            s             50
     d lform           s             10

      *------------------------------------------------------------------
      * Misc. Variables
      *------------------------------------------------------------------
700 AD $code           s             10
700 AD $crew           s              6
700 AD $emp#           s              5  0
700 AD $fnam           s             15
700 AD $init           s              1
700 AD $lnam           s             20
700 AD $nhrs           s             31
     d $perrmsg        s             60
     D $pstring        s           1024
700 AD $shft           s              6
700 AD $rtn            s              8
700 AD $styp           s              1
700 AD $unext          s             13  0
700 AD $whdp           s              5
700 AD $whse           s              3  0
     D AINumb          S              3P 0
710cAD Bad_UPC         s               n   inz(*off)
500cAD bfcoffs         s              3  0 inz(0)
     D bfcoffset       s              3  0 inz(0)
     d carSent         s             20    inz(' ')
415bAD CheckDigit      S              1S 0
415bAD CheckRem        S              5S 0
700 AD ckupc           s             20
     D cmdSent         s              1    inz(' ')
650aAD connectAgain    s               n   inz(*off)
     D CurChar2        s              1
     D CurrentTime     S               z
500cAD CurrStamploc    s               z
500cAD CurrStampsys    s               z
500cAD CurrStampuc     s               z
415aAD CurTime         s              6  0
510aAD deccnt          S              2  0
     D DecOut          s             30  9
     D demowgt         s              9  3
415cAD DigitDiv        S              5P 0
415bAD DigitSum        S              5P 0
     D DisplayMin      S              5p 0
650aAD donotprint      s               n   inz(*off)
     D Duration        S             10U 0 Inz(1)
     D ElapsedMin      S              5p 0
     D ElapsedSec      S              5p 0
700 AD Error           S               n
500cAD ExpStamp        s               z
650aAD firstConnect    s               n   inz(*off)
     D forever         c                   const('1')
700 Ad frmItem         s             15
700 Ad frmType         s              1
700 Ad frmUom          s              2
500cAD FromStamp       s               z
710cAD Good_UPC        s               n   inz(*off)
510aAD gs1ser          S             15
700 Ad hldLcns         s             12
700 AD hldseq          s              2  0
     D i               s             10P 0
     D incomingWgt     s              9  0
     D incomingTare    s              9  0
     d ip              s             10U 0
     D LastTime        S               z
     D Left            s             21
     D loopCnt         s              5  0
     D manualweight    s              7  2
     D manualTare      s              7  2
     d mfglne          s              2  0
     D Non_Num_Posn    S              2  0 Inz(*Zero)
     D Numbers         C                   '0123456789'
     D Numberss        C                   ' 0123456789'
     D offOfZero       s               n   inz(*off)
500cAD oldeststamp     s               z
     d OutSideIP       s             13    inz(' ')
700 Ad pCaseWgt        s              9  3
     d pcust           s             46
     d pcustlen        s              3  0
     D popcode         s              8
500cAD pos1            s              5s 0
500cAD pos2            s              5s 0
500cAD pos3            s              5s 0
500cAD pos4            s              5s 0
     d prdSlot         s             12
650aAD prtLabel        s               n   inz(*off)
     d pWgt            s              6
     d pWgt2           s              8  2
     D qtytoprint      s              4  0
     d reprint         s               n
     D returnStatus    S             10I 0
     D Right           s              9
650aAD scaleAlive      s               n   inz(*off)
650aAD ScaleFound      s               n   inz(*off)
     d ScaleWrk        s             13    inz(' ')
650aAD shutdown        s               n   inz(*off)
     D Side            s              5
     D Sign            s              1  0
     D sq              c                   Const('''')
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     D sqlupdstr       s            300
     D Stable          s               n   inz(*off)
     D StartTime       S               z   Inz(*Sys)
     D StrIn           s             32
     D strLimit        s              4  0
     D Temp1A          S              1
415bAD Temp1N          S              1S 0
510aAD Temp18A         S             18
720aAD today           s              8  0
     d TodayJul        s              5
500cAD ToStamp         s               z
     D trynum          s              3  0
500cAD ts              s               z
700 AD unexta          s             13
650aAD updWght         s               n   inz(*off)
     D Value           s                   like($pstring)
510aAD wgtext          S             11  0
500cAD whse            s              3p 0
     d wkCrtProdErr    s             15
     d wkError         s               n
     d wklblc          s              4  0
     d wkRerr2         s             50
     D woexdt          s              8  0
     D wofifo          s              8  0
     D womfdt          s              8  0
     D WriteRequested  s               n   inz(*off)
     d wrkIso          s               d
     d wrkGtin         s             14
     D X2              s              3  0
710bAD UPumcd          S              1

     *----------------------------------------------------------------
     *  *PROD  -  Production Option Settings
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPLBRP  -  Reprint production labels
     *    OPLBDL  -  Delete Production labels
     *    OPVARM  -  Use Variable Measure for generated GTIN
     *    OPIMPGTIN  Import GTIN's from Customer
     *    OPGENGTIN  Generate GTIN's from customer item number
     *    OPPRDDTE-  Include Production date in GS1
     *    OPPCKDTE-  Include Package date in GS1
     *    OPEXPDTE-  Include Expiration Date in GS1
     *    OPNETLBS-  Include Net pounds in GS1
     *    OPLBSDEC-  Number of decimals for Net pounds
     *    OPNETKG -  Include Net kilograms in GS1
     *    OPKGDEC -  Number of decimals for Net kilograms
     *
     *----------------------------------------------------------------

     D opdata          ds
     D  oplbrp                 1      1
     D  oplbdl                 2      2
     D  opvarm                 3      3
     D  opimpgtin              4      4
     D  opgengtin              5      5
     D  opprddte               6      6
     D  oppckdte               7      7
     D  opexpdte               8      8
     D  opnetlbs               9      9
     D  oplbsdec              10     10  0
     D  opnetkg               11     11
     D  opkgdec               12     12  0
     D  optend               117    117

     D  dqdata         s           1024
417bAD  dqkeylen       s              3  0 inz(36)
     D  dqlen          s              5  0
417bAD  dqorder        s              2
     D  dqwait         s              5  0
     d  dqname         s             10
     d  dqlib          s             10

417bADdqkey            ds            17
417bAD dqwhse                         3p 0
417bAD dqScale                       15

417bADoutkey           ds            20
417bAD otwhse                         3p 0
417bAD otScale                       15
     D otStation                      2
     D otDemo                         1

700cADLabelky          ds            25
417bAD inlblc                         5p 0
700c D inlsts                        20

      *------------------------------------------------------------------
      * Definitions to support the Signal Timeout for Socket API
      *------------------------------------------------------------------
     D init_signals    PR
     D got_alarm       PR
     D   signo                       10I 0 value

     D tConnect        PR            10I 0
     D   sock                        10I 0 value
     D   addr                          *   value
     D   size                        10I 0 value
     D   timeout                     10I 0 value

     D tRecv           PR            10I 0
     D   sock                        10I 0 value
     D   data                          *   value
     D   size                        10I 0 value
     D   timeout                     10I 0 value

     D tSend           PR            10I 0
     D   sock                        10I 0 value
     D   data                          *   value
     D   size                        10I 0 value
     D   timeout                     10I 0 value

     D*--------------------------------------------------------------------
     D @Cvtdt          C                   Const('CVTDTE')
     D $Cvtdt          ds
     D $Cvcmd                         8
     D $Cvprg                        10
     D $Cvd6i                         6
     D $Cvd8i                         8
     D $Cvd6o                         6  0
     D $Cvd8o                         8  0
     D $Cvsto                        18
     D $Cvrtn                         8
     D $Cverm                        60
     D $Cvmsg                         4

      *------------------------------------------------------------------
      * Constants ...
      *------------------------------------------------------------------
     D   CR            C                   Const(x'0D')
     D   CRLF          C                   Const(x'0D25')
     D   EOF           C                   Const(x'00')
     D   LF            C                   Const(x'25')

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *------------------------------------------------------------------
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0
      *----------------------------------------------------------------
      *  Message control
      *------------------------------------------------------------------
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
      *----------------------------------------------------------------
      *  Program info data structure
      *------------------------------------------------------------------
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*     $PIPADDR Host IP Address
     C*      $PPORT  Connecting port to use.
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *entry        PLIST
     C                   PARM                    $PIPADDR         32
     C                   PARM                    $PPORT           15 5

      /free
700eA       // Set SQL default parms
700eA       exec sql
700eA         set Option Commit=*none, Dlyprp=*Yes,
700eA                    Closqlcsr = *ENDMOD;
      /end-free

     C*----------------------------------------------------------------
     C*  Main line
     C*------------------------------------------------------------------

     C* Initialize values.

     c                   exsr      Init

     C* Loop until shutdown transaction received

     c                   dow       forever = forever

     C                   Exsr      RDSocket

     c                   if        connectAgain and not shutdown
     c*                  eval      #iWork = close(#socket1)
     c                   exsr      clearScale
     c                   exsr      ConnSocket
     c                   endif

     c                   if        shutdown
     c                   exsr      clearScale
     c                   leave
     c                   endif

     C                   EndDo
     C                   Eval      *INLR = *ON

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

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

700 A*----------------------------------------------------------------
700 A*  clr$uciinfo  Clear $uciinfo data structure fields
700 A*----------------------------------------------------------------

700 AC     clr$uciinfo   begsr
700 AC                   eval      savever# = $uiver#
700 AC                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
700 AC                   eval      $uiver# = savever#
700 AC                   eval      $uiaddemp = $emp#
700 AC                   eval      $uiaddusr = #user
700 AC                   eval      $uiaddpgm  = #prog
700 AC                   eval      $uiaddjob  = #job
700 AC                   eval      $uiaddnbr = #jobn
700 AC                   endsr

700 A*----------------------------------------------------------------
700 A*  cvtBarCode  Convert Bar Code for ALL AI information
700 A*----------------------------------------------------------------

700 AC     cvtBarcode    begsr
700 A * add the conversion of the UCI barcode
700 AC                   eval      $cbcmd = '*ALL    '
700 AC                   eval      $cbbar = lhuci
700 Ac                   clear                   $barcode
700 Ac                   clear                   $barcode2
700 A*
700 AC                   call      'CVTBAR'
700 AC                   parm                    $cbcmd            8
700 AC                   parm                    $cbbar          100
700 AC                   parm                    $cbcod            3 0
700 AC                   parm                    $cbdec            1 0
700 AC                   parm                    $cbdsc           30
700 AC                   parm                    $cbpos            3 0
700 AC                   parm                    $cbtyp            1 0
700 AC                   parm                    $cbv1            11 3
700 AC                   parm                    $cbv2            50
700 AC                   parm                    $cbrtn            8
700 AC                   parm                    $cberm           60
700 AC                   parm                    $cbven           10 0
700 AC                   parm                    $cvtdata
700 AC                   parm                    $cvtdata2
700 Ac                   eval      $barcode = $cvtdata
700 Ac                   eval      $barcode2 = $cvtdata2
700 A* if gtin not found, error for invalid barcode scanned
700 Ac                   if        not $bcGtinSent
700 Ac                             and not $bcai99sent
700 Ac                   eval      pCaseWgt = 0
700 AC                   goto      endcvtb
700 Ac                   endif
700 A * Load Catch Weight
700 Ac                   if        not error
700 A
700 Ac                   if        $bcPNtLbSent
700 Ac                   eval      pCaseWgt  = $bcPNtLb
700 Ac                   endif
700 A
700 Ac                   if        $bcPNtKgSent
700 Ac                   eval      pCaseWgt = $bcPNtKg * 2.20462
700 Ac                   endif
700 A
700 A * Load UPC
700 A * if gtin not found, error for invalid barcode scanned
700 Ac                   eval      $cstr = *blanks
700 Ac                   if        $bcGtinSent
700 AC                   movel     $bcgtin       $CSTR
700 AC                   call      'ADJUST'
700 AC                   parm      '*RIGHT  '    $CCMD             8
700 AC                   parm                    $CSTR            30
700 Ac                   move      $cstr         ckupc
700 Ac                   endif
700 Ac                   endif
700 A /free
700 A                    chain(n) (lhwhse:ckupc) upc;
700 A                    if %found(upc);
700 A                       frmItem = upitem;
700 A                       chain (upwhse:upitem) piritem;
700 A                       if %found;
700 A                          frmType = ittype;
700 A                          frmUom = itum1;
700 A                       else;
700 A                          frmType = '*';
700 A                          frmUom = '**';
700 A                       endif;
700 A                    else;
700 A                       frmItem = '*NF';
700 A                       frmType = '*';
700 A                       frmUom = '**';
700 A                    endif;
700 A /end-free
700 A
700 AC     endcvtb       endsr

500cA*----------------------------------------------------------------
500cA*  buildGS1   Build the GS1 string for given label
500cA*----------------------------------------------------------------
500cA
500cAC     buildGS1      begsr
      /free

           // get production item information
           chain (lhwhse:lhlitm) itemprd;
           if not %found(itemprd);
              ipmorp = 'P';
730bA         ipprdflg='R';
           endif;
           // GTIN
740gD      //lhgs1 = '01' + %subst(Temp18A:5:14);
740gM      lhgs1 = '98' + %subst(Temp18A:5:14);

           // include only GTIN and Lot number for produce items
           if ipmorp = 'M' or (scuci <> *blanks and scdisp<>*blanks)
740 A             or scwo='GENERATEITEM';
           // Production date if selected
           if opprddte = 'Y';
              lhgs1 = %trim(lhgs1) + '11' + %subst(lhdtetim:3:6);
              womfdt = %dec(
                  %subst(lhdtetim:1:4) +
                    %subst(lhdtetim:6:2) +
                      %subst(lhdtetim:9:2):8:0);
           endif;

           // Package date if selected
           if oppckdte = 'Y';
              lhgs1 = %trim(lhgs1) + '13' + %subst(lhdtetim:3:6);
           endif;

           // Expiration Date selected
           if opexpdte = 'Y';
              lhgs1 = %trim(lhgs1) + '17' +
                  %subst(%char(Expstamp):3:2) +
                    %subst(%char(Expstamp):6:2) +
                      %subst(%char(Expstamp):9:2);
              woexdt = %dec(
                  %subst(%char(Expstamp):1:4) +
                    %subst(%char(Expstamp):6:2) +
                      %subst(%char(Expstamp):9:2):8:0);
           endif;

           // if net pounds selected
           if opnetlbs = 'Y';
              eval deccnt=oplbsdec;
              if deccnt = 0;
                 wgtext = lhweght - lhtare;
              else;
                 if deccnt = 1;
                    wgtext = (lhweght-lhtare) * 10;
                 else;
                    if deccnt = 2;
                       wgtext = (lhweght-lhtare) * 100;
                    else;
                       if deccnt = 3;
                          wgtext = (lhweght-lhtare) * 1000;
                       endif;
                    endif;
                 endif;
              endif;
              lhgs1 = %trim(lhgs1) + '32' + %editc(deccnt:'X')
                     + %subst(%editc(wgtext:'X'):6:6);
           endif;

           // if net kilograms selected
           if opnetkg = 'Y';
              eval deccnt=opkgdec;
              if deccnt = 0;
                 wgtext = lhweght - lhtare;
              else;
                 if deccnt = 1;
                    wgtext = (lhweght-lhtare) * 10;
                 else;
                    if deccnt = 2;
                       wgtext = (lhweght-lhtare) * 100;
                    else;
                       if deccnt = 3;
                          wgtext = (lhweght-lhtare) * 1000;
                       endif;
                    endif;
                 endif;
              endif;
              lhgs1 = %trim(lhgs1) + '31' + %editc(deccnt:'X')
                     + %subst(%editc(wgtext:'X'):6:6);
           endif;
           endif;  // Meat only, not produce

              // include unique serial number for meat products
              if ipmorp = 'M' or scuci <> *blanks
                     or scwo='GENERATEITEM';
                 lhgs1 = %trim(lhgs1) + '21' + gs1ser;
              else;
                 // only include GTIN and Lot number for produce
                 lhgs1 = %trim(lhgs1) + '10' + %subst(%trim(gs1ser):1:10);
              endif;

      /end-free
     c                   endsr

500cA*----------------------------------------------------------------
500cA*  chkDTAQ    Check Data Queue for shutdown Request
500cA*----------------------------------------------------------------
500cA
500cAC     chkDTAQ       begsr

     c                   eval      reprint = *off
     c                   eval      dqdata = ' '
     c                   eval      dqname = 'SCALES'
     c                   eval      dqlib = '*LIBL'
     c                   eval      dqkeylen = 15
     c                   eval      dqwait = 0
     c                   eval      dqScale = otScale
     c                   eval      dqwhse = otWhse
      /free
             // write current time so SCLSTAT knows if this process quits
             // communicating it can force a not communicating and force the
             // to exit the scale process until this has been resolved
             // --- If Timezone/400 is used ensure that both GUI users and
             // user running socket process are both setup and using same
             // Timezone.  Otherwise the scale screens will not reflect
             // correct communicating status due to time difference.
              currstamploc = %timestamp();
              exec sql
               update SCALE
                set scsktts = :currstamploc
               where scsta = :otStation;
      /end-free

     C                   call      'QRCVDTAQ'
     C                   parm                    dqname
     C                   parm                    dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
     C                   parm                    dqwait
417bAC                   parm      'EQ'          dqorder
417bAC                   parm                    dqkeylen
417bAC                   parm                    dqkey
     c                   parm                    dqsnd             3 0
     c                   parm                    dqsndinfo        50

     c                   if        dqlen <> 0
      *  if *shutdown record requested then close this socket client
     c                   if        %trim(dqdata) = '*shutdown'
     c                   eval      shutdown = *on
     c                   goto      endrcvdtaq
     c                   endif
      *  if *manual print manually weighed labels
     c                   if        %subst(dqdata:1:7) = '*manual'
     c                   eval      prtlabel = *on
     c                   exsr      manualLabel
     c                   eval      prtlabel = *off
     c                   goto      endrcvdtaq
     c                   endif
      *  if *demo set the scale weight for demo port per user clicks
     c                   if        %subst(dqdata:1:5) = '*demo'
     c                   exsr      setDemoWgt
     c                   goto      endrcvdtaq
     c                   endif
      *  if *bprtputblank last Serial number printed.
     c                   if        %subst(dqdata:1:7) = '*blkser'
     c                   exsr      blankSerial
     c                   goto      endrcvdtaq
     c                   endif
      *  if *clrerror blank DRI error in Scale file
     c                   if        %subst(dqdata:1:9) = '*clrerror'
     c                   exsr      updateError
     c                   goto      endrcvdtaq
     c                   endif
      *  if *prtlabel tells this socket process it can print labels when
      *   weight changes.  If it is not on a weight screen it should not
      *   print labels.
     c                   if        %trim(dqdata) = '*prtlabel'
     c                   eval      prtLabel = *on
     c                   goto      endrcvdtaq
     c                   endif
      *  if *nolabel tells system to NOT print labels when weith changes.
      *  this means the user is NOT on a weighing screen
     c                   if        %trim(dqdata) = '*nolabel'
     c                   eval      prtLabel = *off
     c                   goto      endrcvdtaq
     c                   endif
      *  if *close tells system to update scale record as closed and
      *  close socket
     c                   if        %trim(dqdata) = '*close'
     c                   exsr      closeScale
     c                   goto      endrcvdtaq
     c                   endif
      *  if label reprint *reprint then create Label
     c                   if        %len(dqdata) >= 10
     c                   if        %subst(dqdata:1:9) = '*reprint '

      /free
            // get previous label passed in for reprint
                          pos3 = %scan('::' : dqdata : 10);
                          strLimit = pos3 - 10;
                          if strLimit < 1;
                             strLimit = 1;
                          endif;
                          lhlsts = %trim(%subst(dqdata:10:strLimit));
           // get previous label time stamp from label history record
                          pos4 = %scan('  ' : dqdata : pos3+2);
                          strLimit = pos4 - (pos3+2);
                          if strLimit < 1;
                             strLimit = 1;
                          endif;
                          lhdtetim = %trim(%subst(dqdata:pos3+2:strLimit));
                           exec sql
                            select *
                             into :lhhst
                              from prdlbhist
                               where lhlsts = :lhlsts and
                                      lhdtetim = :lhdtetim;

                           if sqlstt <> '00000';
                           else;
                             exsr getcurrstamp;
                             lhcts = currstamploc;
                             lhdtetim = %subst(%char(lhcts):1:4) +
                                        %subst(%char(lhcts):6:2) +
                                        %subst(%char(lhcts):9:2) +
                                        %subst(%char(lhcts):12:2) +
                                        %subst(%char(lhcts):15:2) +
                                        %subst(%char(lhcts):18:2);
                             reprint = *on;
        // call reprint process but DO NOT add a second time to the
        //  label file
                             exsr insertlhhst;
                           endif;
                           endif;
      /end-free

     c                   endif
     c                   endif

     c     endrcvdtaq    endsr

700 A*----------------------------------------------------------------
700 A*  crtBrkDwnUCI  Create Breakdown UCI using Box Breaker
700 A*----------------------------------------------------------------

700 AC     crtBrkDwnUCI  begsr
700 A*
700 A* add record to uci file
700 A*
700 A*    Get User's employee number to be written to PORCV file
700 A*    if any records are flagged as touched.
700 A*
700 Ac                   if        scuci <> *blanks
710aAc                              and scdisp <> 'MULTIDAY'
700 AC                   eval      $code = scuser
700 AC                   eval      $whse = *zeros
700 AC                   eval      $emp# = *zeros
700 AC                   eval      $fnam = *blanks
700 AC                   eval      $init = *blanks
700 AC                   eval      $lnam = *blanks
700 AC                   eval      $whdp = *blanks
700 AC                   eval      $styp = *blanks
700 AC                   eval      $shft = *blanks
700 AC                   eval      $crew = *blanks
700 AC                   eval      $nhrs = *blanks
700 AC                   eval      $rtn = *blanks
700 AC                   call      'GETUSER'
700 AC                   parm                    $code
700 AC                   parm                    $whse
700 AC                   parm                    $emp#
700 AC                   parm                    $fnam
700 AC                   parm                    $init
700 AC                   parm                    $lnam
700 AC                   parm                    $whdp
700 AC                   parm                    $styp
700 AC                   parm                    $shft
700 AC                   parm                    $crew
700 AC                   parm                    $nhrs
700 AC                   parm                    $rtn
700 A /free
700 A
700 A   // get license from Case UCI
700 A   hldlcns = *blanks;
700 A   exsr clr$uciinfo;
700 A   $uiWhse = scwhse;
700 A   $uiUci = scuci;
700 A   $dricommand = '*UCIINFO';
700 A   $drisubcmd  = '%CHKGS199';
700 A   $drisys2upd = 'D';
700 A   exsr zzdricop;
700 A   if not error;
700 A      hldlcns = $uilcns;
720aA      hldseq = $uiseq;
700 A   else;
700 A      leavesr;
700 A   endif;
700 A
700 A   exsr clr$uciinfo;
700 A   $uiWhse = lhwhse;
700 A   $uiItem = lhlitm;
700 A   $uiuci = lhgs1;
700 A   ucilic#($unext: scwhse);
700 A   unexta = %editc($unext:'X');
700 A   $uiuciLcns = 'U:' + unexta;
700 A   $uiLcns = hldlcns;
700 A   $uiseq=hldseq;
700 A   $uiSerial = lhlsts;
700 A   $uiwgtlbs = lhweght;
700 A   $uiWgtKgs = 0;
700 A   $uiSelTrn# = 0;
700 A   $uiSelLbl# = 0;
700 A   $uiSelOrd = 0;
700 A   $uiSelSeq = 0;
700 A   $uiSelCSeq = 0;
700 A   $uiSelTrax = ' ';
700 A   $uiCrtBy = 'A';
720aA   if $bcgtin = *blanks;
720aA   $uiaGtin = 0;
720aA   else;
720aA   $uiaGtin = %DEC($bcgtin:14:0);
720aA   endif;
720aA   $uiaLot = $bclot;
720aA   $uiaExpD = woexdt;
720aA   $uiaEntD = today;

720aA   // Lets add some more stuff for tracking
720aA   $uiaction = 'PRDBRKDWN';
720aA   $uiaolcns = hldlcns;
720aA   $uialcns = hldlcns;
720aA   $uiaoseq = hldseq;
720aA   $uiscan = ' ';
720aA   //$uitran# = lbtrn#;
720aA   //$uilbl# = lblbl#;
700 A
700 A   $dricommand = '*UCIINFO';
700 A   $drisubcmd  = '%ADD';
700 A   $drisys2upd = 'D';
700 A   exsr zzdricop;
700 A
700 A   exsr crtUciSplits;
700 A                    endif;
700 A
700 A /end-free
700 AC                   endsr

700 A*----------------------------------------------------------------
700 A*  crtUciSplits  Create records that show how an item was broke
700 A*                down using Box Breaker
700 A*----------------------------------------------------------------
700 A
700 AC     crtUciSplits  begsr
700 A /free
700 A         // first get from information for Case UCI
700 A         exsr cvtBarCode;
700 A         // now build uci splits record
700 A         uswhse = lhwhse;
700 A         ustrn#=sctran;
700 A         usgs1c=lhuci;
700 A         usgs1b = lhgs1;
700 A         usfitm = frmItem;
700 A         usftyp = frmType;
700 A         usfuom = frmUom;
700 A         usfwgt = pCaseWgt;
700 A         // now build To Item information
700 A         chain (lhwhse:lhlitm) piritem;
700 A         ustitm = lhlitm;
700 A         usttyp = itType;
700 A         ustuom = itum2;
700 A         ustwgt = lhweght;
710eA         usbxbsq = scbxbsq;
700 A         usaddts = %timestamp;
700 A         usaddpgm = #prog;
700 A         usaddemp = $emp#;
700 A         usaddusr = lhuser;
700 A         usaddjob = #job;
700 A         usaddnbr = #jobn;
700 A         uschgts = %timestamp;
700 A         uschgpgm = #prog;
700 A         uschgemp = $emp#;
700 A         uschgusr = lhuser;
700 A         uschgjob = #job;
700 A         uschgnbr = #jobn;
700 A         write usrec;
700 A         if %error;
700 A         endif;
700 A /end-free
700 AC                   endsr

500cA*----------------------------------------------------------------
500cA*  manualLabel  Print labels for manually weighed products
500cA*----------------------------------------------------------------
500cA
500cAC     manualLabel   begsr
      /free
            // get manually entered quantity
                          pos3 = %scan('::' : dqdata : 1);
                          if pos3 = 0 or pos3 <8;
                             donotprint = *on;
                          else;
                             pos3 = pos3 +3;
                             qtytoprint = %dec(%subst(dqdata
                                  :pos3:4) :4 :0);
                     // get manually entered wieght
                             pos4 = %scan('::' : dqdata : pos3);
                             pos4 = pos4 +3;
                             incomingWgt = %dec(%subst(dqdata
                                  :pos4:9) :9 :0);
                             manualweight = incomingwgt / 100;
710 A                // get manually entered Tare Weight
710 A                        pos3 = %scan('::' : dqdata : pos4);
710 A                        pos3 = pos3 +3;
710 A                        incomingTare = %dec(%subst(dqdata
710 A                             :pos3:9) :9 :0);
710 A                        manualtare = incomingwgt / 100;
                             donotprint = *off;
                          endif;
           // print quantity of manual labels desired
                          dow qtytoprint >0;
                             sctare = sctare;
                             scweght = manualweight;
                             exsr createLabel;
                // update scale record with last serial number written
                             qtytoprint = qtytoprint - 1;
                          enddo;
                          eval manualweight = 0;
                          qtytoprint = 0;
      /end-free
     c                   endsr

500cA*----------------------------------------------------------------
500cA*  setDemoWgt  Set the Demo Weight
500cA*----------------------------------------------------------------
500cA
500cAC     setDemoWgt    begsr
      /free
                     // get demo weight per the button clicked
                        pos3 = %scan('::' : dqdata : 1);
                        if pos3 = 0;
                           demowgt = 0;
                        else;
                           pos3 = pos3 +3;
                           incomingWgt = %dec(%subst(dqdata
                              :pos3:9) :9 :0);
                           demowgt = incomingWgt/ 1000;
                        endif;
                        exsr setScleWgt;
      /end-free
     c                   endsr

500cA*----------------------------------------------------------------
500cA*  blankSerial  Blank last serial printed since moving to non
500cA*               printing screen
500cA*----------------------------------------------------------------
500cA
500cAC     blankSerial   begsr
     *  the manual and auto weighing screens load all transactions
     *  for previous 4 hours for a given station, and item.  Once
     *  labels are loaded it only loads new ones going forward.
     *  It uses the last serial number on the scale record to know
     *  which ones to load as new.  Therefore, when user returns to
     *  non print screen we blank to reset and load all on first pass
      /free
              exec sql
               update SCALE
                set scLsts = ' ',
                  scLblc = 0
               where scsta = :otStation;
      /end-free
     c                   endsr

500cA*----------------------------------------------------------------
500cA*  updateError  Update error in Scale table received from
500cA*               DRI Program
500cA*----------------------------------------------------------------
500cA
500cAC     updateError   begsr
     *  This program and SCLSTAT step on each other with such
     *  frequent updates.  This is the only routine that updates
     *  SCERROR
      /free
              exec sql
               update SCALE
                set scerror = ' '
               where scsta = :otStation;
      /end-free
     c                   endsr

500cA*----------------------------------------------------------------
500cA*  setScleWgt  Update the Demo Weight per the MRC button clicked
500cA*----------------------------------------------------------------
500cA
500cAC     setScleWgt    begsr
     *  the manual and auto weighing screens load all transactions
     *  for previous 4 hours for a given station, and item.  Once
     *  labels are loaded it only loads new ones going forward.
     *  It uses the last serial number on the scale record to know
     *  which ones to load as new.  Therefore, when user returns to
     *  non print screen we blank to reset and load all on first pass
      /free
              exec sql
               update SCALE
                set scDemoWgt = :demowgt
               where scsta = :otStation;
      /end-free
     c                   endsr

     C*----------------------------------------------------------------
     C*  CrtChkDgt  -  Create Check Digit for on the fly GTIN
     C*
     C*    Works with up to 18 digit number
     C*
     C     CrtChkDgt     begsr
     C
     c                   eval      Temp18A = ' '
      *  if cross reference upc exists use that upc number, otherwise
      *  build upc number on the fly off of customer item number
      *  if all numeric
      /free
710bA        If (scuci <> *Blanks and
                 scwo = *Blanks) or
710bA           (scuci <> *Blanks and
                 scdisp='MULTIDAY');
710bA           Eval UPumcd = '1';
710bA        Else;
710bA           Eval UPumcd = 'N';
710bA        EndIf;

710gM        if $ppAction='BXB';
710gA           chain (scwhse: sclitm) piritem;
710gA           if itum2 = *blanks;
710eA              // set to normal UOM for Box Breaker when no BrkDwn
710eA              UPumcd='N';
710gA           endif;
710eA        endif;

710bA        setll (scwhse: sclitm: UPumcd) upc5;

710cA       // Loop through UPC records for item until record with ALL numeric
710cA       // found.  Set indicator field to know how to proceed
710cA        DoU %Eof(UPC5);
710bA        reade (scwhse: sclitm: UPumcd) upc5;
710eM          If %equal(UPC5);
710cA            Non_Num_Posn = %check(Numberss:upupc);
710cA              If Non_Num_Posn > 0
710eA                 or upupc=*blanks;
710cA                Good_UPC = *Off;
710cA                Bad_UPC  = *On;
710cA                Iter;
710cA              Else;
710cA                Good_UPC = *On;
710cA                Bad_UPC  = *Off;
710cA                Leave;
710cA              EndIf;
710cA          Else;
710cA            Good_UPC = *Off;
710cA          EndIf;
710cA        EndDo;

             select;
710cA        When Not Good_UPC;
740 A          chain (scwhse:sclitm) piritem;
740 A          // need to create a GTIN
740 A          wrkgtin = ' ';
740 A          pirgtin#(wrkgtin: scwhse);
740 A          // item found in upc cross reference file
740 A          $cstr=*blanks;
740 A          // Add new upc/gtin record
740 A          xrupwhse = scwhse;
740 A          xrupitem = sclitm;
740 A          xrupupc = '      ' + wrkGtin;
740 A          xrupven = 0;
740 A          xrupvnam = ' ';
740 A          xrupvitm = ' ';
740 A          xrupbran = ' ';
740 A          xrupuom = itum1;
740 A          xruputyp = 'N';
740 A          xrupctyp = '3';
740 A          write uprecxrf;
740 A          if %error;
740 A          endif;

740 A /end-free
     c                   move      *blanks       $cstr
     c                   movel     xrupupc       temp19a          19
     c                   move      temp19a       $cstr
740 A /free
             other;
      /end-free
     c*  item found in upc cross reference file
     c                   move      *blanks       $cstr
     c                   movel     upupc         temp19a          19
     c                   move      temp19a       $cstr
      /free
             endsl;
      /end-free

     c                   if        $cstr <> ' '
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $CCMD             8
     C                   parm                    $CSTR            30
     c                   move      $cstr         temp17a          17
     C                   movel     temp17a       Temp18A
     c                   move      '0'           Temp18A
     C                   movea     Temp18A       A18

     C* Zero fill array.

     C                   eval      i = 1
     C                   dou       i > 18
     C                   if        A18(i) <> *Blank
     C                   leave
     C                   endif
     C                   eval      A18(i) = '0'
     C                   eval      i = i + 1
     C                   enddo

      *  if variable measure set in options place a 9 in
      *   position 13
     c                   if        opvarm = 'Y'
     c                             and opgengtin = 'Y'
     c                   eval      a18(5) = '9'
     c                   endif

     C* Make sure barcode only contains numbers.

     C                   eval      i = 1
     C                   dou       i > 18
     C                   eval      AINumb = %Scan(A18(i):Numbers)
     C                   if        AINumb = 0
     C                   eval      Error = *ON
     C                   eval      $preturn = '*INVALID'
710dA /free
710dA         // Non numeric should be caught above but in case it is not
710dA         // this will return an error
710ca              $drimessage = 'Item ' + %trim(sclitm) +
710dA                            ' has UPC with non numeric characters';
710dA              if %subst(dqdata:1:7)='*manual' and manualweight<>0;
710dA                 exec sql update scale set scerror=:$drimessage
710dA                                 where scport = :$pport;
710dA              endif;
710dA              $cstr = ' ';
710dA /end-free
     C                   Goto      EndChk10
     C                   endif
     C                   eval      i = i + 1
     C                   enddo

     c* Since check digit is not yet calculated.  Put zero on end
     C* and ignore difference at end since it is calculating
     C*   add every other position together.

     C                   eval      i = 17
     C                   eval      DigitSum = 0

     C                   dou       i < 0
     C                   eval      Temp1A = A18(i)
     C                   move      Temp1A        Temp1N
     C                   eval      DigitSum = DigitSum + Temp1N
     C                   eval      i = i - 2
     C                   enddo

     C* Multiply above sum by 3.

     C                   eval      DigitSum = DigitSum * 3

     C* Starting in position 16 and working backwards ...
     C*   add every other position to above sum.

     C                   eval      i = 16
     C                   dou       i = 0
     C                   eval      Temp1A = A18(i)
     C                   move      Temp1A        Temp1N
     C                   eval      DigitSum = DigitSum + Temp1N
     C                   eval      i = i - 2
     C                   enddo

     C* To get check digit ...
     C*   Divide sum by 10, take remainder and subtract from 10

     C*   Note: The statement 'CheckDigit = 10 - CheckRem' caused a
     C*         'target ... to small' error, thus the need for the
     C*         verbose 'if' statment.

     C     DigitSum      Div       10            DigitDiv
     C                   Mvr                     CheckRem
     C                   if        CheckRem = 0
     C                   eval      CheckDigit = 0
     C                   else
     C                   eval      CheckDigit = 10 - CheckRem
     C                   endif

     c                   move      CheckDigit    A18(18)
     c                   movea     A18           Temp18A
     c                   exsr      buildGS1
     c                   exsr      updProdSlot
     c                   eval      lhdisp = prdSlot
     c                   eval      lhlcns = $ppToLcns
     c                   endif

     C     EndChk10      endsr

     *----------------------------------------------------------------
     *  clearScale   Clear the scale record and close the socket
     *----------------------------------------------------------------

     C     clearScale    begsr
      /free
          // Get scale station record to clear current settings before
          //  closing
          chain (otwhse:otStation) scale;
          if %found(scale);
             sscweght = 0;
             sscwuom = ' ';
             ssclitm = ' ';
             sscuser = ' ';
             ssctype = ' ';
             sscdest = ' ';
             sscstat = 'X';
             sscbbseq =0;
             sscbbLcns = *blanks;
             update screc;
          endif;
          #iWork = close(#socket1);
      /end-free
     c                   endsr

500cA*----------------------------------------------------------------
500cA*  closeScale   Close Scale record when prompted from screen close
500cA*----------------------------------------------------------------
500cA
500cAC     closeScale    begsr
      /free
          // Get scale station record to clear current settings before
          //  closing
          chain (otwhse:otStation) scale;
          if %found(scale);
             sscweght = 0;
             sscwuom = ' ';
             ssclitm = ' ';
             sscuser = ' ';
             ssctype = ' ';
             sscdest = ' ';
             ssclblc = 0;
             ssclsts = ' ';
             ssctare = 0;
             sscordnbr = 0;
             ssccust = 0;
             sscbbseq =0;
             sscbbLcns = *blanks;
             sscstat = 'X';
             update screc;
          endif;
      /end-free
     c                   endsr

     C*----------------------------------------------------------------
     C*
     C*  ConnSocket  Connect to Server Socket hosted by Axel Terminal
     C*
     C     ConnSocket    BEGSR
      *
     C                   Eval      connectAgain = *off
     c                   eval      offOfZero = *on
     c                   eval      firstConnect = *on
      *
      *  Get socket descriptor...
      *
     c                   dow       0 = 0
     *
     *  check to see if a shutdown was issued
     *
     c                   exsr      ChkDtaq

     C                   Eval      #Socket1 = Socket(AF_INET:
     C                                               SOCK_STREAM:
     C                                               PROTOCOL)
     C                   if        #Socket1 < 0
     c                   eval      #iWork = close(#socket1)
      *  insert code to return socket error message
     C*                  eval      *INLR = *ON
     C                   eval      shutdown = *on
     C                   return
     C                   endif
      *
      *  set socket as non blocking to enable timeout on TCP operations
      *
      *  Connect...
      *
     C                   Eval      sin_family = AF_INET

      /free
                         ip = inetaddr(%addr($pipaddr));
                         if ip = INADDR_NONE;
                            p_hostent = gethostbyname(%trim($pipaddr));
                            if p_hostent <> *Null;
                               IP = h_addr;
                            endif;
                         endif;

                         if ip = INADDR_NONE;
                            //  code to return message host not found
                            shutdown = *on;
                         endif;
      /end-free

     c                   if        not shutdown
     C                   Eval      sin_port = #Port
     C                   Eval      sin_addr = ip
     c                   Eval      #iWork = %Size(ServerAddr)
     C                   Eval      #iRC = tConnect(#Socket1:
     C                                           %Addr(ServerAddr):
     C                                           #iWork:
     C                                           30)
     *
     C                   IF        (#iRC < 0 )
     *  write reason for no connect to log file
     c                   eval      perrno = $$errno()
     c                   eval      pmessage = strError(errno)
     C                   eval      SlgTyp = 'Opn'
     C                   eval      SlgUrc = #iRC
     C                   eval      SlgBuf = message
     c                   if        firstConnect
     c                   exsr      WriteLog
     c                   eval      firstConnect = *on
     c                   endif
     *  close socket before retry
     C                   eval      #iwork = close(#socket1)
     *  make this 3-5 minutes for go live.  Will only hit this when cannot
     *  connect.  Most likely terminal is off.  Set at 25 seconds for test
     C                   eval      returnStatus = Sleep(25)
     c                   else
     C                   eval      slgtyp = 'Opn'
     c                   exsr      WriteLog
     *
     *    Send command to Toledo scale to perform Reset
     *    This will stop any current feed so it is prepared
     *    to process commands sent
     *
     c                   eval      trynum = 0
     c                   dou       trynum > 25 or
740cAc                              %subst(csvrecin:2:6)='I4 A "'
740cAc                               or %subst(csvrecin:1:6)='I4 A "'
     c                   eval      #sBufferOut = '@' + CRLF
     c                   eval      #sBufferWrk = #sBufferOut
     c                   exsr      sndSocket
     c                   if        connectAgain
     c                   goto      endConnect
     c                   endif
     c                   exsr      rcvSocket
     c                   if        connectAgain
     c                   goto      endConnect
     c                   endif
     c                   eval      trynum = trynum + 1
     C                   eval      returnStatus = uSleep(275000)
     c                   enddo
     *  make sure command was successful
     c                   if        trynum > 25
     c*                  eval      shutdown = *on
     c                   eval      connectAgain = *on
     c                   goto      endConnect
     c                   else
     *  generate log entry for previous Send command since it
     *  a receive transaction
     C                   eval      SlgTyp = 'Snd'
     C                   eval      SlgUrc = #uRC
     C                   eval      SlgBuf = #sBufferShl
     c                   exsr      WriteLog
     *  write a transaction log entry for the received transaction
     C                   eval      SlgTyp = 'Rcv'
     C                   eval      SlgUrc = #uRC
     C                   eval      SlgBuf = #sBufferIn
     c                   exsr      WriteLog
     c                   endif

     *  once connection is established and reset sent to Toledo
     *  Scale pause 2 seconds and request Scale Id

     c                   exsr      FindScale
     c                   exsr      setScale

     c                   leave
     C                   endif
     c                   else
     c                   leave
     c                   endif
     c                   enddo

     c     endConnect    endsr

     *----------------------------------------------------------------
     C*  CSVXlateNum   Translate value into number
     *----------------------------------------------------------------

     C     CSVXlateNum   begsr
     C
     C                   eval      StrIn = Value
     C
      * set inital values
     C                   eval      left = *all'0'
     C                   eval      right = *blanks
     C                   eval      Side = 'left'
     C                   eval      Sign = 1
     C
      * extract parts of number to left & right of decimal point
     C     1             do        32            x2
     C                   eval      CurChar2 = %subst(StrIn:x2:1)
     C                   select
     C                   when      CurChar2 >= '0' and CurChar2 <= '9'
     C                   if        Side = 'left'
     C                   eval      Left = %subst(Left:2:20) + CurChar2
     C                   else
     C                   eval      Right = %trimr(Right) + CurChar2
     C                   endif
     C                   when      CurChar2 = '.'
     C                   eval      Side = 'right'
     C                   when      CurChar2 = '-' or CurChar2 = '<'
     C                   eval      Sign = -1
     C                   endsl
     C                   enddo
     C
      * combine the left & right strings to get the entire number
     C                   movel     Left          DecOut
     C                   eval      Right = %trimr(Right) + '000000000'
     C                   move      Right         DecOut
     C
      * if a hyphen or less-than was found, negate the number
     C                   if        Sign = -1
     C                   eval      DecOut = (- DecOut)
     C                   endif
     C
     C                   endsr

500cA*----------------------------------------------------------------
500cA*  FindScale  Send command to scale to have it return scale id
500cA*----------------------------------------------------------------
500cA
500cAC     FindScale     begsr
     *
     *    Send command to Toledo scale to perform request
     *    for scale identifer code
     *    scale record updated in file SCALE
     *
     c                   eval      trynum = 0
     c                   dou       trynum > 25 or
740cAc                              %subst(csvrecin:2:7)='I12 A "'
740cAc                              or %subst(csvrecin:1:7)='I12 A "'
     c                   eval      #sBufferOut = 'I12' + CRLF
     c                   eval      #sBufferWrk = #sBufferOut
     c                   exsr      sndSocket
     c                   if        connectAgain
     c                   goto      endFindScl
     c                   endif
     c                   exsr      rcvSocket
     c                   if        connectAgain
     c                   goto      endFindScl
     c                   endif
     c                   eval      trynum = trynum + 1
     C                   eval      returnStatus = uSleep(275000)
     c                   enddo
      *  make sure command was successful
     c                   if        trynum > 25
     c*                  eval      shutdown = *on
     c                   eval      connectAgain = *on
     c                   goto      endFindScl
     c                   else
     *  generate log entry for previous Send command since it
     *  a receive transaction
     C                   eval      SlgTyp = 'Snd'
     C                   eval      SlgUrc = #uRC
     C                   eval      SlgBuf = #sBufferShl
     c                   exsr      WriteLog
     *  write transaction log entry for receive transaction
     C                   eval      SlgTyp = 'Rcv'
     C                   eval      SlgUrc = #uRC
     C                   eval      SlgBuf = #sBufferIn
     c                   exsr      WriteLog
     c                   exsr      setScale
     c                   endif
      *

     c     endFindScl    endsr

500cA*----------------------------------------------------------------
500cA*  getcurrstamp  Get current timestamps
500cA*----------------------------------------------------------------
500cA
500cAC     getcurrstamp  begsr

      *  if option selected for expiration date get days to calc
     c                   if        opexpdte = 'Y'
      /free
                         chain (scwhse:sclitm) itemmsc;
                         if not %found(itemmsc);
                            imoday = 0;
                         endif;
      /end-free
     c                   endif

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc
     C     currstampsys  adddur    imoday:*DAYS  Expstamp

     C                   endsr

     *----------------------------------------------------------------
    C*  Init     Load initial values and do housework on load
     *----------------------------------------------------------------

     C     Init          begsr
     C                   Eval      #Port = $PPort

     *  In my test case I was not able to get the Axel client to report
     *  it's name to DNS.  Therefore I have the internal IP on the scale
     *  and I am getting the external IP from the file. Should work
     *  even if customer had similar issue

     c/exec sql
     c+ select scwhse,scid,scsta,scdemo
     c+   into :outkey
     c+   from scale
     c+   where scport = :$pport
     c/end-exec

      /free

                 if SQLSTT = '00000';


               //  Clear Data Queue on startup for given
               //  Warehouse and Port
               //  Since multiple devices can feed this one
               //  queue we look for the specific entries
               //  keyed by the warehouse and scale on startup
      /end-free

     c                   eval      dqdata = ' '
     c                   eval      dqname = 'SCALES'
     c                   eval      dqlib = '*LIBL'
     c                   eval      dqkeylen = 15
     c                   eval      dqwait = 0
     c                   eval      dqScale = otScale
     c                   eval      dqwhse = otWhse

     c                   dow       forever = forever

     C                   call      'QRCVDTAQ'
     C                   parm                    dqname
     C                   parm                    dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
     C                   parm                    dqwait
417bAC                   parm      'EQ'          dqorder
417bAC                   parm                    dqkeylen
417bAC                   parm                    dqkey
     c                   parm                    dqsnd             3 0
     c                   parm                    dqsndinfo        50

    c*    if no remaining entries for this scale and port
    c*    then leave

     c                   if        dqlen = 0
     c                   leave
     c                   endif

     c                   enddo
      /free
                    else;
                         // should probably return message
                         shutdown = *on;
                    endif;

               //  initiate OS signaling to force timeout
               //  for socket API.  This will prevent a
               //  lockup and allow for a controlled
               //  shutdown
                         init_signals();
               //  attempt to Connect to particular scale
                         exsr ConnSocket;

      /end-free
720aA*
720aA*  Convert today's date into century format.
720aA*
720aAC                   eval      $cvcmd = '*CURCMD '
720aAC                   call      @cvtdt
720aAC                   parm                    $cvtdt
720aAC                   eval      today = $cvd8o
720aA*
     c                   endsr

500cA*----------------------------------------------------------------
500cA*  rcvSocket Receive command from Toledo Scale
500cA*----------------------------------------------------------------
500cA
500cAC     rcvSocket     begsr
      *
     C                   Z-ADD     0             j                 5 0
     C                   EVAL      CSVRecin = *Blanks
     C                   Eval      RecIn = *Blanks
     C                   Move      *Off          Done              1
     c                   eval      WriteRequested = *off
      *
      *  Clear the work fields...
     C                   Eval      #sBufferIn = *Blanks
     C                   Eval      #sBufferWrk = *Blanks
      *
      *  Initialize the stream data control counters...
     C                   Eval      #BufferSz = BufferSize
      *
     C                   Eval      #uRC = tRecv(#Socket1:
     C                                         %Addr(#BufferIn):
     C                                         #BufferSz:
     c                                         30)
     *
     *  check to see if a shutdown was issued
     *
     c                   exsr      ChkDtaq
     *
     *    If #uRC = 0 the client has issued a close,
     *      if #uRC > BufferSize, an error has occured...
     *
 2B  C                   select
 2B  C                   when      #urc < 0 or #urc > buffersize
     C
     c                   eval      perrno = $$errno()
     c                   eval      pmessage = Strerror(errno)
     *  if this represents no data, but a signal interruption then
     *  check to see if a request to close exists in the data queue
     c*                  if        Errno = EINTR
     c*                  goto      EndRcv
     c*                  else
     c                   eval      connectAgain = *on
     C                   goto      EndRcv
     c*                  endif
     *
 2B  C                   when      #urc = 0
     C                   goto      EndRcv
 2E  C                   endsl
     *
     *    Translate ASCII to EBCDIC...
     *
     C                   Eval      #sBufferWrk = #sBufferIn
      *
     C                   Eval      #iWork5 = #uRC
     C                   Call      'QDCXLATE'
     C                   Parm                    #iWork5
     C                   Parm                    #sBufferIn
     C                   Parm                    #AtoETabl
     C                   Parm                    #XLateLib

     *  Read data from server.  Look for either Line feed or Carriage
     *   to terminate command

     C     1             do        #urc          i

     C                   if        #bufferin(i) <> lf
     C                             and #bufferin(i) <> cr
     C                   eval      j = j+1
     C                   eval      csvaryin(j) = #bufferin(i)
     C                   endif

     c     EndRcv        tag
     c                   enddo
     c                   endsr

     C*----------------------------------------------------------------
     C*
     C*  RDSocket Look for transactions from passed server
     C*
     C     RDSocket      BEGSR
      *
     C                   DoW       0 = 0
      *
      *  Read the incoming request...
      *
     *
     *    Send command to Toledo scale to request current
     *    weight every quarter second
     *
     c                   eval      trynum = 0
     c                   dou       trynum > 25 or
     c                              %subst(csvrecin:2:4)='S S '
     c                              or %subst(csvrecin:2:4)='S D '
740cAc                              or %subst(csvrecin:1:4)='S S '
740cAc                              or %subst(csvrecin:1:4)='S D '
     c                   eval      #sBufferOut = 'SI' + CRLF
     c                   eval      #sBufferWrk = #sBufferOut
     c                   exsr      sndSocket
     c                   if        connectAgain
     c                   goto      endReadSkt
     c                   endif
     c                   exsr      rcvSocket
     c                   if        connectAgain or shutdown
     c                   goto      endReadSkt
     c                   endif
     c                   eval      trynum = trynum + 1
     C                   eval      returnStatus = uSleep(275000)
     c                   enddo
     *  if not successful after 25 retries end program
     c                   if        trynum > 25
     c*                  eval      shutdown = *on
     c                   eval      connectAgain = *on
     c                   goto      endReadSkt
     c                   endif

     c                   select
     *  shutdown request
     c*                  when      %subst(csvrecin:1:9) = '*SHUTDOWN'
     c*                             or %subst(csvrecin:1:9) = '*shutdown'
     c*                             or %subst(csvrecin:1:9) = '*Shutdown'
     c*                             or %subst(csvrecin:1:9) = '*ShutDown'
     c*                  eval      shutdown = *on
     c*                  eval      WriteRequested = *on

     *  Continuious weight returned
     c                   when      (%subst(csvrecin:2:4) = 'S S '
     c                              or %subst(csvrecin:2:4) = 'S D ')
740cAc                              or (%subst(csvrecin:1:4) = 'S S '
740cAc                              or %subst(csvrecin:1:4) = 'S D ')
     c                              and ScaleWrk <> ' '
     c                   exsr      updWeight

     c                   if        WriteRequested
     *  generate log entry for previous Send command since it
     *  a receive transaction
     C                   eval      SlgTyp = 'Snd'
     C                   eval      SlgUrc = #uRC
     C                   eval      SlgBuf = #sBufferShl
     c                   exsr      WriteLog
     *  write received transaction to log
     C                   eval      SlgTyp = 'Rcv'
     C                   eval      SlgUrc = #uRC
     C                   eval      SlgBuf = #sBufferIn
     c                   exsr      WriteLog
     c                   endif
      *
     c                   if        shutdown
     c                   leave
     c                   endif

     c                   endsl

      *
     C                   eval      returnStatus = uSleep(275000)
     C                   EndDo
     C     endReadSkt    ENDSR

500cA*----------------------------------------------------------------
500cA*  SetScale  Scale had returned attached scale id.  Update Scale
500cA*            record in Scale file
500cA*----------------------------------------------------------------
500cA
500cAC     setScale      begsr
     *
     *    substring scale id from Scale command
     *

     c                   eval      $pstring = %trim(csvrecin)
     C                   eval      pos1 = %scan('"':$pstring:1)
     c                   if        pos1 >= 1
     C                   eval      pos2 = %scan('"':$pstring:pos1+1)
     c                   if        pos2 > pos1
     c                   eval      pos1=pos1+1
     c                   eval      pos2=pos2-pos1
     *  if length ends up being zero or less do not update scale id
     c                   if        pos2>0
     c                   eval      $pstring = %subst($pstring:pos1:pos2)
     c                   eval      ScaleWrk = $pstring
     *  update scale table with empty fields


      /free
          // Get scale station record to initialize scale record
          chain (otwhse:otStation) scale;
          if %found(scale);
             sscweght = 0;
             sscwuom = ' ';
             ssclitm = ' ';
             ssctype = ' ';
             sscdest = ' ';
             sscbbseq = 0;
             sscbblcns = *blanks;
             sscstat = 'I';
             sscport = $pport;
             update screc;
          endif;
      /end-free

     c                   endif
     c                   endif
     c                   endif

     c                   endsr

500cA*----------------------------------------------------------------
500cA*  SndSocket Send command to Scale
500cA*----------------------------------------------------------------
500cA
500cAC     sndSocket     begsr
      *
     *    Translate EBCDIC to ASCII ...
     C                   Eval      #sBufferShl = #sBufferOut
     C                   eval      #iwork5 = %len(%trim(#sBufferOut))
     C                   Call      'QDCXLATE'
     C                   Parm                    #iWork5
     C                   Parm                    #sBufferOut
     C                   Parm                    #EtoATabl
     C                   Parm                    #XLateLib

     *  send command to scale to retrieve Scale Id

     c                   eval      #iwork5 = tSend(#Socket1:
     c                                           %addr(#sBufferOut):
     c                                           #iwork5:
     c                                           30)

     c                   exsr      ChkDtaq

     c                   if        #iwork5<0
     c                   eval      perrno = $$errno()
     c                   eval      pmessage = Strerror(errno)
     *  if this represents no data, but a signal interruption then
     *  check to see if a request to close exists in the data queue
     c*                  if        Errno = EINTR
     c*                  goto      EndSnd
     c*                  else
     c                   eval      connectAgain = *on
     C                   eval      SlgTyp = 'Snd'
     C                   eval      SlgUrc = #uRC
     C                   eval      SlgBuf = #sBufferWrk
     c                   exsr      WriteLog
     c*                  endif
     c                   endif
     c     endSnd        endsr

     *----------------------------------------------------------------
     C*  UpdateScale   Update Weight value for Scale Record
     *----------------------------------------------------------------

     C     UpdateScale   begsr
      /free
             // write current time so SCLSTAT knows if this process quits
             // communicating it can force a not communicating and force the
             // to exit the scale process until this has been resolved
              currstamploc = %timestamp();
              exec sql
               update SCALE
                set scsktts = :currstamploc
               where scsta = :otStation;

             sqlupdstr = 'scport = ' + %char($pport);
             if $drimessage <> ' ';
                sqlupdstr = %trim(sqlupdstr) + ', scerror =' + sq +
                             $drimessage + sq;
                $drimessage = ' ';
             endif;

             if updWght;
                sqlupdstr = %trim(sqlupdstr) + ', scwuom = ' + sq +
                 %trim(Value) + sq + ', scweght = ' + %char(decout);
             endif;

             if sclitm <> ' ';
                sqlupdstr = %trim(sqlupdstr) + ', scstat = ' + sq +
                              'W' + sq;
             else;
                sqlupdstr = %trim(sqlupdstr) + ', scstat = ' + sq +
                              'C' + sq;
             endif;

          sqlstmt = 'update SCALE set ' + %trim(sqlupdstr) +
                        ' where scsta = ' + sq + otStation + sq;
      /end-free
     c/exec sql
     c+  execute immediate :sqlstmt
     c/end-exec

     c                   endsr

500cA*----------------------------------------------------------------
500cA*  updWeight Scale returns continious weight.  This routine
500cA*            analyzes the weight to determine if new and whether
500cA*            label should be produced.
500cA*----------------------------------------------------------------
500cA
500cAC     updWeight     begsr
     *
     *    substring weight and weight UOM
     *

     c                   eval      stable = *off
     c                   eval      $pstring = %trim(csvrecin)
     C                   eval      pos1 = %scan('S S ':$pstring:1)
     c                   if        pos1 > 0
     c                   eval      stable = *on
     c                   else
     C                   eval      pos1 = %scan('S D ':$pstring:1)
     c                   endif
     c                   if        pos1 >= 1
     *  convert weight to numeric value
     c                   eval      Value = %subst($pstring:pos1+5:9)
     c                   exsr      CSVXlateNum
     *  get weight UOM
     C                   eval      pos1 = %scan('.':$pstring:pos1+4)
     c                   eval      Value = %subst($pstring:pos1+4:3)
     *  determine whether weight should be updated and therefore
     *    process a label for weighted box
     *

      /free
          exsr getcurrstamp;
          updWght = *on;
          exsr rtvScale;
          if ScaleFound and scaleAlive;
             select;
             when Decout = 0 and not offOfZero;
                // when scan is zero, and not off a zero weight
                exsr UpdateScale;
                offOfZero = *on;
                WriteRequested = *on;
             when Stable and Decout <> 0 and offOfZero;
                // when scan > zero, stable and off a zero weight
                exsr CreateLabel;
                exsr UpdateScale;
                WriteRequested = *on;
                offOfZero = *off;
             when Stable and Decout < scweght;
                // when stable and scanned weight is less than previous
                //   weight
                exsr CreateLabel;
                exsr UpdateScale;
                WriteRequested = *on;
                offOfZero = *off;
700A         when not prtlabel;
700A            // when on non printing screen simply update weight to
700A            // current scale weight
700A            exsr UpdateScale;
             other;
               // if this transaction weight was not updated release
               //  scale record
                updWght = *off;
                exsr UpdateScale;
             endsl;
          else;
            // if we get here then the scale is found but appears MRC
            // label screen is not active, therefore we should not fire
            // a label but we should update the weight so it will not
            // automatically fire once it returns to weight screen
            if not scaleAlive;
               exsr UpdateScale;
               if scweght <> 0;
                  offOfZero = *off;
               else;
                  offOfZero = *on;
               endif;
            endif;
          endif;
      /end-free
     c                   endif

     c                   endsr

500cA*----------------------------------------------------------------
500cA*  createLabel  -  This routine currently writes information
500cA*                  to a label history file.
500cA*----------------------------------------------------------------
500cA
500cAC     createLabel   begsr
      /free

      //  only comes to this routine when weight changed.
      //  Therefore, generate label. Once labels ready we
      //  will need to create a UCI transaction and pass
      //  appropriate information along to label creation
      //  program

       // value prtLabel will also have to be on.  The
       // HTML MRC process will send a data queue transaction
       // that either flips this value on or off based on
       // whether the user is currently on a weight screen.

                  if prtLabel;

                     // GET PRODUCTION OPTIONS
                     popcode = '*PROD';
                     chain (scwhse:popCode) options;
                     if not %found(options);
                        clear oprec;
                     endif;

                     if sclitm <> ' ';
                        if manualweight = 0;
                           scwuom = Value;
                           scweght = decout;
                        else;
                           if scwuom = ' ';
                              scwuom = 'lb';
                           endif;
                           scweght = manualweight;
                        endif;

740aA         // if weight too large return an error
740aA                    if scweght > 9999;   // then return an error
740AA                      $drimessage='Weight cannot exceed 9999';
740aA                      exec sql update scale set scerror=:$drimessage
740aA                                     where scport = :$pport;
740aA                      $drimessage=*blanks;
740aA                      leavesr;
740aA                    endif;

740aA         // if weight minus tare is negative throw an error
740aA                    if (scweght-sctare) < 0;   // then return an error
740AA                      $drimessage='Weight cannot be less than Tare';
740aA                      exec sql update scale set scerror=:$drimessage
740aA                                     where scport = :$pport;
740aA                      $drimessage=*blanks;
740aA                      leavesr;
740aA                    endif;

                         exsr getcurrstamp;
                         wrkIso = %Date();
                         TodayJul = %char(wrkIso:*jul0);
             // if you ever start prompting for quantity per label
             // you will need to pass as parm to SCLSTAT and replace
             // the hard coded 1 below with that passed parm.
                         lhqty = 1;
                         lhcts = currstamploc;
                         lhwhse = scwhse;
                         lhsta = scsta;
                         lhport = scport;
                         lhlitm = sclitm;
                         lhcust = sccust;
                         lhuser = scuser;
                         lhordnbr = scordnbr;
                         lhtare = sctare;
                         lhweght = scweght;
                         lhwuom = scwuom;
740 A                    if lhwuom = *blanks and scwo='GENERATEITEM';
740 A                       lhwuom = 'LB';
740 A                    endif;
                         lhprtn = scprtn;
                         lhtype = sctype;
                         lhdest = scdest;
                         lhwo = scwo;
710 A                    // only move in LHUCI which is for Box Breaker is not MultiDay
710 A                    if scdisp <> 'MULTIDAY';
700 A                       lhuci = scuci;
700 A                       lhdspbb = scdisp;
710eA                       lhbxbsq = scbxbsq;
710 A                    endif;
700 A                    lhtran = sctran;
740 A                  if scwo='GENERATEITEM';
740 A                    lhstat='C';
740 A                  else;
                         lhstat = 'O';
740 A                  endif;

                  // get next available label number for scale and day
                         exec sql
                           select lhlblc,lhlsts
                           into :Labelky
                           from prdlbhist
                           where lhport = :$pport and lhsta = :scsta
                           order by lhlsts desc
                           fetch first row only;

                         if Sqlstt <> sqlSuccess;
                            lhlblc = sclblc + 1;
                         else;
                            if TodayJul = %subst(inlsts:1:5);
                               lhlblc = inlblc + 1;
                            else;
                               lhlblc = 1;
                            endif;
                         endif;

                         mfglne = scmfgno;
        //  build serial number for UCI transaction
         // 5 digit julian date, whse, mfg line#, and 5 digit seq. number
      /end-free
     c                   z-add     lhlblc        wklblc
      /free
                         gs1ser = TodayJul + %editc(scwhse:'X')
                                   + %editc(mfglne:'X')
                                   + %editc(wklblc:'X');
                         lhlsts = gs1ser;
                       lhdtetim = %subst(%char(lhcts):1:4) +
                                  %subst(%char(lhcts):6:2) +
                                  %subst(%char(lhcts):9:2) +
                                  %subst(%char(lhcts):12:2) +
                                  %subst(%char(lhcts):15:2) +
                                  %subst(%char(lhcts):18:2);
                         exsr insertlhhst;
                         sclsts = lhlsts;
                         sclblc = lhlblc;
                     endif;
                  endif;
      /end-free
500cAC                   endsr

500cA*----------------------------------------------------------------
500cA*  updProdSlot -   Get the correct production slot based on type
500cA*                  of transaction/item being processed
500cA*                  and add quantity of 1 to that slot per label
500cA*----------------------------------------------------------------
500cA
500cAC     updProdSlot   begsr
      /free

740 A           // If coming from Item Label generator only do not
740 A           // execute this routine.  No inventory transactions
740 A           if scwo = 'GENERATEITEM';
740 A              leavesr;
740 A           endif;

                savever# = $ppver#;
                clear $pprod;
                clear $pprod2;
                $ppver# = savever#;

710 A        // Make Sure Scale Mfg Line matches Work Order if WO passed
710 A        if scwo <> *blanks;
710 A           chain (scwhse:scwo) pwrkord;
710 A           if %found(pWrkORd);
710 A              scMfgno = woMfgno;
710 A           endif;
710 A        endif;
                if scmfgno <> 0;
                   chain (scwhse:scmfgno) plined;
                   if %found(plined);
                      $ppdesc = indesc;
                      prdSlot = ' ';
720 A                 select;
730bD                  //when %subst(sclitm:1:3)='WIP';   // WIP Stock to Lin slot
730bA                  //when ipPrdFlg='C';                 // WIP Stock to Lin slot
                       //  $pprcvau = *on;
                       //  $pprcva = inrcvaisl;
720 A                  when scdest = 'C';     // customer
                         $ppshpau = *on;      // set values to look fcust slt
                         $ppshpa = inpckaisl;
720 A                  when scdest = 'P';       // par stock
                         $ppparau = *on;
                         $pppara = instkaisl;
720 A                 endsl;

                   endif;
                endif;

                if sclitm <> '';
                   chain (scwhse:sclitm) piritem;
                   if %found(piritem);
                      $ppwhdpu = *on;
                      $ppwhdp  = itwhdp;
                      $ppitemu = *on;
                      $ppitem  = ititem;
                   endif;
                endif;

                $ppgs1u = *on;
                $ppgs1 = lhgs1;
                $ppser#u = *on;
                $ppser# = lhlsts;
                $ppwgtu = *on;
                $ppwgt = lhweght;
                $pptareu = *on;
                $pptare = lhtare;
                $ppActionu = *on;
                $ppAction = 'PSC';
                $ppuseru = *on;
                $ppuser  = scuser;
                $ppwhseu = *on;
                $ppwhse  = scwhse;
                $pplnenou = *on;
                $pplneno = scmfgno;
                $ppscaleu = *on;
                $ppscale = scsta;
                $ppcustu = *on;
                $ppcust = sccust;
                $pptypeu = *on;
                $pptype = sctype;
                $ppdestu = *on;
                $ppdest = scdest;
720 A      // if Wip Item then send to Lin slot instead of PAR or CUS slot
730bD           //if %subst(sclitm:1:3)='WIP';
730bD           //if ipPrdFlg='C';
730bD           //   $ppdest = 'M';
730bD           //endif;
                $ppqty1u = *on;
                $ppqty1 = 1;
                $ppadjcdeu = *on;
700bD     //    $ppadjcde = 'P1';
700bA           $ppadjcde = 'P3';
                $ppwo#u = *on;
                $ppwo# = scwo;
700 A           if scuci <> *blanks and $ppwo# = *blanks;
700 A              $ppadjcde = 'B1';
700 A              $ppActionu = *on;
700 A              $ppAction = 'BXB';
700 A              $ppuciu = *on;
700 A              $ppuci = scuci;
700 A              $ppdspbbu = *on;
700 A              $ppdspbb = scdisp;
700 A              $pptrn#u = *on;
700 A              $pptrn# = sctran;
700 A              // if from Box Breaker we are creating quantity in
700 A              // breakdown one quantity, not case quantity
700 A              // Case quantity will be reduced in separate command
700 A              // when things are completed.
700 A              $ppQty1 = 0;
700 A              $ppQty2 = 1;
700 A           else;
710 A              $ppuciu = *off;
710 A              $ppuci = *blanks;
700 A              $ppdspbbu = *off;
700 A              $ppdspbb = *blanks;
700 A              $pptrn#u = *off;
700 A              $pptrn# = *zeros;
700 A           endif;

710 A           if scuci <> *blanks and scdisp='MULTIDAY';
710 A              $pprmuciu = *on;
710 A              $pprmuci = scuci;
710 A           else;
710 A              $pprmuciu = *off;
710 A              $pprmuci = *blanks;
710 A           endif;
                $ppwgtu = *on;
                $ppwgt = lhweght;

                $dricommand = '*PROD';
                $drisubcmd = '%ADJQTY';
                $drisys2upd = 'D';
                exsr zzDriCop;
                if wkerror;
710gA              // when error comes back to identify as no breakdown
710gA              // Box Breaker transaction clear error.  This allows
710gA              // system to generate label only for items that are
710gA              // purchased as breakdown quantity but come in case
710gA              // and has no breakdown UCI's
710gA              if $drireturn = '*BOXNOUOM';
710gA                 $drireturn='*OK';
710gA                 wkerror = '0';
710gA              else;
                   wkCrtProdErr = '*PRDERR';
710gA              endif;
                else;
700 A              if $ppAction = 'BXB';
700 A                 prdSlot = scdisp;
700 A              else;
                      if scdest = 'P';
                         prdSlot = $ppparar;
                      endif;
                      if scdest = 'C';
                         prdSlot = $ppshpar;
                      endif;
720 A      // if Wip Item then return Lin Slot instead of Par or Cust slot
730bD                //if %subst(sclitm:1:3)='WIP';
730bD                //if ipPrdFlg='C';
730bD                //    prdSlot = $pprcvar;
730bD                //endif;
                   endif;
700 A           endif;

      /end-free
     c                   endsr

500cA*----------------------------------------------------------------
500cA*  insertLhhst  -  This routine performs a Sequel insert for
500cA*                  production label history
500cA*----------------------------------------------------------------
500cA
500cAC     insertlhhst   begsr
      /free

            // get production slot and add 1 to slot per the label
             // do not do following code for a reprint.  It simply
             // uses the data there from original print
             if not reprint;
                exsr crtchkdgt;
700dA           if $cstr = *blanks
710fA              or ($drireturn <> '*OK' and $driReturn<>'INSLOT'
740 A                    and scwo<>'GENERATEITEM');
710fA                exec sql update scale set scerror=:$drimessage
710fA                               where scport = :$pport;
700dA              leavesr;
700dA           endif;
700 A           exsr crtBrkDwnUCI;
             endif;

            // insert record into label history table for production
             // do not add record if reprint, invalid upc or other error
             if (Temp18A <> ' ' or reprint)
                  and $drimessage = ' ';
                         pWgt2 = lhweght - lhtare;
                         pWgt = %trim(%editc(pwgt2:'J'));
                         if lhdest = 'C';
                            chain (lhwhse:lhcust) custmast;
                            if %found(custmast);
                               pcustlen = %len(%char(lhcust));
                               if (46-(pcustlen+1)) >= 40;
                                  pcustlen = 40;
                               else;
                                  pcustlen = 46 - (pcustlen+1);
                               endif;
                               pcust = %char(lhcust) + '-' +
                                  %subst(cmname:1:pcustlen);
                            else;
                               pcust = %char(lhcust) + '-' +
                                  '** Customer not Valid **';
                            endif;
                         else;
                            pcust = ' ';
                         endif;
                         Exec SQL  Set :lhwuom = Upper(:lhwuom);
                // call process to print label
                         if ipmorp = 'M';
                            llfmt = 'PRDLBL';
                         else;
                            llfmt = 'PRODUCE';
                         endif;
740 A                    if scwo = 'GENERATEITEM';
740 A                      llfmt = 'PRODCE24';
740 A                    endif;
                         exsr prtprdlbl;
           if not reprint;
             exec sql
                insert into prdlbhist
                (lhcts,lhdtetim,lhwhse,lhsta,lhport,lhuser,lhlitm,
                 lhdisp,lhlcns,lhcust,lhordnbr, lhprtn, lhqty,
                 lhweght, lhtare,lhwuom,lhtype,lhdest,lhlblc,lhlsts,
710eD     //     lhgs1,lhwo,lhuci,lhdspbb,lhtran,lhstat)
710eM            lhgs1,lhwo,lhuci,lhdspbb,lhbxbsq,lhtran,lhstat)
                values( :lhcts, :lhdtetim, :lhwhse, :lhsta, :lhport,
                    :lhuser,:lhlitm, :lhdisp, :lhlcns,
                    :lhcust, :lhordnbr, :lhprtn, :lhqty, :lhweght, :lhtare,
                    :lhwuom, :lhtype, :lhdest, :lhlblc, :lhlsts,
710eD    //         :lhgs1, :lhwo, :lhuci, :lhdspbb, :lhtran, :lhstat);
710eM               :lhgs1, :lhwo, :lhuci, :lhdspbb, :lhbxbsq, :lhtran,
710eA               :lhstat);
             endif;
           endif;
             reprint = *off;

      /end-free
500cAC                   endsr

     c* ------------------------------------------------------------------
     c*  Print Production or Box Breaker Label
     c* ------------------------------------------------------------------
     c*
     c     PrtPrdLbl     begsr
      *
     c                   move      lhwhse        lcwhse
     c                   movel     lhgs1         lgs1
     c                   call      'PRTPRDLBL'
     c                   parm      '*PRINT'      lcmd
     c                   parm      'ZBRDRY'      llset
     c                   parm                    llfmt
     c                   parm                    lcwhse
     c                   parm                    lhlitm
     c                   parm                    lhdisp
     c                   parm                    lhordnbr
     c                   parm      '*Note1'      lnote1
     c                   parm      '*Note2'      lnote2
     c                   parm      '*Note3'      lnote3
     c                   parm      '*Note4'      lnote4
     c                   parm      '*Note5'      lnote5
     c                   parm      '*Note6'      lnote6
     c                   parm                    lhwuom
     c                   parm                    lgs1
     c                   parm                    lhprtn
     c                   parm      '*PRDLBL'     lform
     c                   parm                    pcust
     c                   parm                    TodayJul
     c                   parm                    pWgt
      *
     c                   endsr
      /free
       //---------------------------------------------------------
       // rtvScale - Retrieve the requested Scale Record
       //---------------------------------------------------------

         begsr rtvScale;

          scaleAlive = *off;
          exec sql
           select *
            into :scalerc
             from scale
              where scport = :$pport;

          if Sqlstt <> sqlSuccess;

             ScaleFound = *off;
          else;
             ScaleFound = *on;
      /end-free
     C     currstampsys  adddur    -2:*Seconds   currstamploc
      /free
           if currstamploc <= scpts;
              scaleAlive = *on;
           endif;

          endif;

         endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  Writelog    Write log record
     *
     C     writelog      begsr
      *
      *  determine if transaction is repeating from previous.  The scale
      *  process send weight requests over and over to keep weight updated
      *
     c                   select
     c                   when      slgTyp = 'Snd'
     c                   eval      prvBuffer = aryBuffer(1)
     c                   when      slgTyp = 'Rcv'
     c                   eval      prvBuffer = aryBuffer(2)
     c                   when      slgTyp = 'Sel'
     c                   eval      prvBuffer = aryBuffer(3)
     c                   when      slgTyp = 'Cl1'
     c                   eval      prvBuffer = aryBuffer(4)
     c                   when      slgTyp = 'Cl2'
     c                   eval      prvBuffer = aryBuffer(5)
     c                   when      slgTyp = 'Opn'
     c                   eval      prvBuffer = aryBuffer(6)
     c                   endsl

500cAC                   exsr      getcurrstamp

500cAC                   eval      slgts     = currstamploc
500cAC                   eval      slgucs    = currstampuc
500cAC                   eval      slguser   = #user
500cAC                   eval      slgjob    = #job
500cAC                   eval      slgjobnbr = #jobn
     c                   eval      slgip     = $pipaddr

     C                   eval      slgsk2 = #socket1
500aAC                   eval      SlgPortL = #port
500aAC                   eval      SlgPortc = $pport
 1B  C                   select
     C                   when      slgtyp = 'Opn'
     C                             or slgtyp = 'Rcv'
     C                   eval      slgid  = ' '
 1X  C                   other
 1E  C                   endsl
     c                   if        slgBuf <> prvBuffer
     C                   write     slgrec
     c                   select
     c                   when      slgTyp = 'Snd'
     c                   eval      aryBuffer(1) = slgBuf
     c                   when      slgTyp = 'Rcv'
     c                   eval      aryBuffer(2) = slgBuf
     c                   when      slgTyp = 'Sel'
     c                   eval      aryBuffer(3) = slgBuf
     c                   when      slgTyp = 'Cl1'
     c                   eval      aryBuffer(4) = slgBuf
     c                   when      slgTyp = 'Cl2'
     c                   eval      aryBuffer(5) = slgBuf
     c                   when      slgTyp = 'Opn'
     c                   eval      aryBuffer(6) = slgBuf
     c                   endsl
     c                   endif
     C
     C                   endsr

     *----------------------------------------------------------------
     *  ZZLICINFOCHK  Check to see if licinfo exist for Scale Info
     *----------------------------------------------------------------

      /free
        begsr zzlicinfochk;

          exsr clr$licinfo;

          $lnwhse  = scwhse;
          $lnlcns  = scbblcns;
          $lnseq  = scbbseq;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          exsr zzdricop;
          if error;
            // if not found add license/sequence
            exsr zzlicinfonew;
          else;
            // license/sequence found then update
            exsr zzlicinfoupd;
          endif;

        endsr;
      /end-free

     *-----------------------------------------------------------------
     *  ZZLICINFOUPD  Update License Info file with generated Breakdown
     *-----------------------------------------------------------------

      /free
        begsr zzlicinfoupd;

          exsr clr$licinfo;

          // Box Breaker creates a sequence for EACH UCI Case
          // broken down for this item on this license.  Therefore,
          // a new sequence is generated for each case UCI and
          // sequence one is always updated as well for this license
          $lnwhse  = scwhse;
          $lnlcns  = scbblcns;
          $lnseq  = scbbseq;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          exsr zzdricop;
          if error;
          else;
            // accumulate the lnseqqty field
            // if NOT updating transaction#
            // and label #
            $lnrcvtyp = 'A';
            $lnseqqty = $lnseqqty + 1;
            $lnttllbs = $lnttllbs + lhweght - lhtare;
            $dricommand = '*LICINFO';
            $drisubcmd  = '%CHANGES';
            $drisys2upd = 'D';
            exsr zzdricop;
          endif;

          // now update sequence one for any non sequence 1 entry

          if $lnseq <> 1;
             exsr clr$licinfo;

             // Box Breaker creates a sequence for EACH UCI Case
             // broken down for this item on this license.  Therefore,
             // a new sequence is generated for each case UCI and
             // sequence one is always updated as well for this license
             $lnwhse  = scwhse;
             $lnlcns  = scbblcns;
             $lnseq  = 1;

             $dricommand = '*LICINFO';
             $drisubcmd  = '%GET';
             $drisys2upd = 'D';
             exsr zzdricop;
             if error;
             else;
               // accumulate the lnseqqty field
               // if NOT updating transaction#
               // and label #
               $lnrcvtyp = 'A';
               $lnseqqty = $lnseqqty + 1;
               $lnttllbs = $lnttllbs + lhweght - lhtare;
               $dricommand = '*LICINFO';
               $drisubcmd  = '%CHANGES';
               $drisys2upd = 'D';
               exsr zzdricop;
             endif;
          endif;
        endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZLICINFONew Create new License info record
     *----------------------------------------------------------------

      /free
        begsr zzlicinfonew;

          // Write out standard license information
          exsr clr$licinfo;

          $lnwhse  = scwhse;
          if scbblcns = '*GEN';
             $lnlcns  = '*BB';
             $lnseq = 1;
          else;
             $lnlcns  = scbblcns;
             $lnseq = scbbseq;
          endif;

          $lnseqqty = $lnseqqty + lhqty;
          $lnttllbs = lhweght - lhtare;
          $lnitem = lhlitm;
          // LNRCVTYP notes
          // 1 = Manual quantity (original method)
          // 2 = Manual quantity with initial GS1 scan
          // 3 = UCI using Mfg GS1 barcodes
          // 4 = UCI using Internal GS1 barcodes (start with 99)
          // 5 = ASN file
          // 6 = Production Module
          // A = Box Breaker Breakdowns

          $lnrcvtyp = 'A';
          $lnrcvtrn# = 0;
          $lnrcvlbl# = 0;

          select;
            when womfdt = 0;
              $lnenttype = '*EXPDTE';
              $lnentdate = woexdt;
            other;
              $lnentdate = womfdt;
              $lnenttype = '*MFGDTE';
          endsl;

          $lnmfgdays = immday;
          $lnusrdays = imuday;
          $lndstdays = imdday;

          $lnmfgdate = womfdt;

          if woexdt > 0;
            $lnmfgexp = woexdt;
          endif;

          if wofifo > 0;
            $lnfifodate = wofifo;
          endif;

          if woexdt > 0;
            $lnexpdate = woexdt;
          endif;

          $lnmfgcode = *blanks;

          $lnavglbs = 0;

          if lhlsts <> ' ';
            $lnlot = lhlsts;
          endif;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%ADDS';
          $drisys2upd = 'D';
          exsr zzdricop;
          if error;
          else;
             // update Scale Record with latest License/Sequence
             exec sql
                update scale set scbblcns = :$lnlcns,
                       scbbseq = :$lnseq
                       where scsta = :otStation;
          endif;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzdriCop   Call DRICOP
     *----------------------------------------------------------------

     c     zzDriCop      begsr
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   eval      $dridata = $pprod
700 Ac                   eval      $dridata2 = $pprod2
     c                   when      $dricommand = '*LICINFO'
     c                   eval      $dridata = $LICINFO
700 Ac                   eval      $dridata2 = $LICINFO2
700 AC                   when      $dricommand = '*UCIINFO'
700 AC                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                              or $dricommand = '*LICINFO'
720aAc                              or $dricommand = '*UCIINFO'
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*PROD'
     c                   eval      $pprod = $dridata
700 Ac                   eval      $pprod2 = $dridata2
     c                   when      $dricommand = '*LICINFO'
     c                   eval      $LICINFO = $dridata
700 Ac                   eval      $LICINFO2 = $dridata2
700 AC                   when      $dricommand = '*UCIINFO'
700 AC                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     c                   endsl

     c                   endsr
      /copy qcopysrc,$SignalP
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
