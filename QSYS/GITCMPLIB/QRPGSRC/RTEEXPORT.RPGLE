      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RTEEXPORT   Export Rte - Pgm for SQL procedure of same name
     *  17 January 2014
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*    01/17/14  DAS  6.50
     *      - Created.
     *
650a *    03/06/14  DAS  6.50a
     *      - Added pSessId, pUser, pPgm paramters
     *      - Revised to use CHKIUSE2
     *      - Added call to WRTSESSLOG
     *
650b *    03/11/14  DAS  6.50b
     *      - Changed pWhse to character field.
     *      - Revised to submit this program to jobq.
     *      - Moved call to chkiuse2 into subprocedure
     *
650c *    05/07/14  KDE  6.50c
     *      - Several Will Call order changes since rtehed not coming
     *        in as status 5
     *
700a *    09/15/15  RTR  7.00a
     *      - Added additional BFCDEBUG logging to PreJobqCheck.
     *
710a *    04/10/17  RTR  7.10a
     *      - Fix: on a Trax route with merge, was trying to chain to
     *        RTEHED which was still closed, now opening if needed.
     *
710bA*    04/21/17  RBD  7.10a
     *      - Added call to TR811 to create version 1.3 Trax(c) xml
     *        file if client is a Trax(c) user and selects 1=export.
     *      - For now skip over code that writes merged routes into
     *        the same xml. The handheld is not yet ready to handle
     *        multiple routes in the same xml.  So for now merged
     *        routes (TTMERG) is only used by the Loader Module.
     *        When you're ready to reinstate this logic simply take out
     *        these 710a revs.
730a *    10/03/19  LMC  7.30a
     *      - Treat OPFTP = 'R' same as OPFTP = 'S'.
     *        R=Real time staging export.
     *
740aA*    11/06/20  RBD  7.40a
     *      - Added *TRAX options. Only create Trax xml at this time
     *        if Trax user AND they do not print Trax invoices.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - S. Bertram
     *
SBRaA*    02/18/15  JCJ  SBRa
     *      - Enh:  Added SBR to list of clients that print OR671
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Chef's Warehouse
     *
DRYbA*  01/16/14  MLB  DRYb
     *    - Revised program to call RH155S for select warehouses. Orders
     *      will be exported to JDEdwards.
DRYdA*  05/16/14  MLB  DRYd
     *    - Revised DRYb mod. Revised pgm to set $PCMD = *ALL to cause
     *      RH155SCL to be submitted to QS36EVOKE. Per Kelly R. phone
     *      call 05/16/14.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Panos
     *
PANaA*    05/19/17  MR   PANa
     *      - Add process to build EXPSPLBL and update with payroll
     *        and performance data.
     *
PANaA*    10/02/17  MR   PANb
     *      - Remove indicator 79 from eof indication due to conflict
     *        with other indicators and recompile.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - A and D Foods
     *
ADF A*    10/05/17  MLB  ADF
     *      - Enh:  Added ADF to list of clients that print OR671
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Soutwest Traders
     *
SWTa *    03/19/19  RTR  SWTa
     *      - Enh:  Added call to export version 2 for long order num.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Packer's Provision
     *
PCK A*    02/10/21  MLB  PCK
     *      - Enh:  Added call to export version 2 for long order num.
     *        Mod calls pgm, RH155CL2.
     *      - Added PCK to SWT mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Seashore
     *
SFPaA*    01/11/23  RH   SFPa
     *      - Enh:  Added SFP to list of clients that print OR671
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    The verification logic was taken from RH150A.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Frtehed    if   e           k disk    usropn
640eAf                                     prefix(r_)
411 AFoptions   if   e           k disk
530aAFpiruser   if   e           k disk
640eAFttmerg1   if   e           k disk    prefix(t1_)
640eAfttmerg2   if   e           k disk    rename(ttmrec:ttmrec2)
640eAf                                     prefix(t2_)
530aAFttrte     if   e           k disk
650bAFbfcdebug  o    e           k disk
PANaAFtruckh    if   e           k disk
PANaAFoptionz   if   e           k disk
PANaAFpltsum3   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.chkiuse

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Clients
     *----------------------------------------------------------------

PCK A /COPY QCOPYSRC,ID#PACKERS
HAR A /COPY QCOPYSRC,ID#HARBOR
MJKaA /COPY QCOPYSRC,ID#MJKELLN
DRYaA /COPY QCOPYSRC,ID#DAIRYLA
CBIaA /COPY QCOPYSRC,ID#CHENEY
KFSaA /COPY QCOPYSRC,ID#KFS
HMWaA /COPY QCOPYSRC,ID#HMWAGNE
CDI A /COPY QCOPYSRC,ID#CDI
SBRaA /COPY QCOPYSRC,ID#SBR
PANaA /COPY QCOPYSRC,ID#PAN
ADF A /COPY QCOPYSRC,ID#ADF
SWTaA /copy qcopysrc,id#swt
SFPaA /copy qcopysrc,id#sfp

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650bAD sq              c                   Const('''')

     D $emp#           s              5
     D error           s               n
650bAD jobq            s               n

     D client          s             10
     D clientloc       s             10
640eAD firstpass       s              1
     D forevr          s              1
650aDD*iuCmd           s              8
650aDD*iuRtn           s              8
650aDD*iuFlag          s              1  0
650aDD*iuSubFlag       s              1  0
650aDD*iuText10        s             10
650aDD*iuText30        s             30
650aAD $irtn           s              8
650aAD $iuText10       s             10
650aAD $iuText30       s             30
650aAD $iuCmd          s              8
650aAD $iuPgm          s             20
650aAD $iuUser         s             10
650aAD $iuSessId       s             40
650aAD $iuJobName      s             10
650aAD $iuJobNbr       s              6
650aAD $iuJobUser      s             10
650aAD $iuStamp        s             26
650aAD logText         s            100
640eAD parentRte       s              5
650bAD sbmCmd          s           3000    varying
650bAD sbmJob          s             10A
650bAD sbmUser         s             10A
650bAD sbmJobNbr       s              6A
650bAD numWhse         s              3  0
PANaAD kytype          s                   like(r_rhtype)
PANaAD kyzone          s                   like(opzzon)
PANaAD lstzon          s                   like(psszon)
PANaAD kycode          s                   like(opzcod)
PANaAD $ptruk          s             10
PANaAD $ptmpl          s             10
PANaAD cmd             s              8

411 A*----------------------------------------------------------------
411 A*  *FTP      -  FTP options
411 A*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFTP   -  Use FTP for exporting (Y,N)
     *    OPSRVR  -  FTP Server name
     *    OPUSER  -  FTP User id
     *    OPPWD   -  FTP Password
     *
     * Data structure
     *
     D opdata          ds
     D  opftp                  1      1
     D  opsrvr                 2     33
     D  opuser                34     48
     D  oppwd                 49     63
     D  optend               117    117

     *----------------------------------------------------------------
530aA*  *SYSTEM  -  System options.
530aA*----------------------------------------------------------------
530aA*
530aA* Fields
530aA*
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
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -  Use UCI processing (Y,N).
     *    OPICWR  -  Check CW count for receiving. (N,M,B,C)
     *    OPWRNR -   Check CW variance for receiving. (N,M,B,C)
     *    OPTRAX -   Using TRAX module (Y,N).
     *
     * Data structure
     *
     D opdat1          ds
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
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opuci                 36     36
     D  opicwr                37     37
     D  opwrnr                38     38
     D  optrax                39     39
     D  opten1               117    117
PANaA*  Data structure for OPTIONZ
PANaAD opdta2          ds
PANaAD  opclvl                 1      3  0 inz(0)
PANaAD  opcwra                 4      4
PANaAD  opcwrb                 5      5
PANaAD  opuwra                 6      6
PANaAD  opuwrb                 7      7
PANaAD  optext                 8     50
PANaAD  operr                 51     52  0 inz(0)
PANaAD  opcwgt                53     54  0 inz(0)
PANaAD  oplpgm                55     64
PANaAD  oppdev                65     74
PANaAD  oppfrm                75     84
PANaAD  optend2              117    117
     *----------------------------------------------------------------
740aA*  *TRAX  -  TRAX options
740aA*----------------------------------------------------------------
740aA*
740aA* Fields
740aA*
740aA*    OPTHST  -  Days to keep TRAX export data (1-999)
740aA*    OPTSLI  -  Save log info
740aA*    OPTCWR  -  Catch weight required
740aA*    OPTOFT  -  Order number field type
740aA*    OPTDFT  -  Driver field type
740aA*    OPTRFT  -  Route field type
740aA*    OPTCAP  -  Capitalize input
740aA*    OPTDBL  -  Double click delivery
740aA*    OPTEKD  -  Entry key delivery
740aA*    OPTDAR  -  Delivery after return
740aA*    OPTIDB  -  Include item data base
740aA*    OPTBDA  -  Breakdowns allowed
740aA*    OPTGBD  -  Generic breakdown allowed
740aA*    OPTRTQ  -  Pre-trip questions
740aA*    OPTOTQ  -  Post-trip questions
740aA*    OPTCCE  -  Credit card enabled
740aA*    OPTSIG  -  Signature enabled
740aA*    OPTPIV  -  Print invoice
740aA*    OPTSDA  -  Send data after stop
740aA*    OPTWSP  -  Ws port
740aA*    OPTWSI  -  Ws IP
740aA*    OPTSVD  -  Save days
740aA*    OPTERT  -  Environment run time
740aA*    OPTEDV  -  Environment device
740aA*    OPTEOS  -  Environment OS
740aA*    OPTESW  -  Environment screen width
740aA*    OPTESH  -  Environment screen height
740aA*    OPTARE  -  Add return enabled
740aA*    OPTIDL  -  Icon delivery
740aA*    OPTDCI  -  Double click icons
740aA*    OPTPAL  -  Pallets enabled
740aA*    OPTCRA  -  Cradle upload enabled
740aA*    OPTDRV  -  Driver assigned before download
740aA*    OPTBUL  -  Bulk items enabled
740aA*    OPTEYS  -  Display empty stops
740aA*    OPTSAS  -  Save after scan
740aA*    OPTSDL  -  Save delay
740aA*    OPTSDT  -  Sync date and time
740aA*    OPTLRK  -  Left/right keys enabled
740aA*    OPTGSS  -  GS1 scanning
740aA*    OPTGSU  -  GS1 unique
740aA*    OPTSBV  -  Scan beep volume
740aA*    OPTRAG  -  Restart after get route.
740aA*    OPTRD   -  Restart daily.
740aA*    OPTRDT  -  Restart daily time.
740aA*    OPTRFP  -  Reader focus position.
740aA*    OPTRFM  -  Reader focus mode.
740aA*    OPTNSR  -  Non scan reason prompt.
740aA*    OPTFBD  -  Filter by department.
740aA*    OPTDSF  -  Display stop flags before restart.
740aA*    OPTSOR  -  Sort items by compartment Y/N.
740aA*    OPTODE  -  Customer on site delivery enable Y/N.
740aA*    OPTODP  -  Customer on site delivery verification period, 5-60.
740aA*    OPTONT  -  On truck picking Y/N.
740aA*    OPTOTP  -  Override truck picking Y/N.
740aA*    OPTNSB  -  No signee button on signature screen Y/N.
740aA*    OPTRAXINV - 1 = Print all invoices
740aA*                2 = Print pristine invoices only
740aA*                3 = Print non-pristine invoices only
740aA*                9 = Print no invoices
740aA*
740aA* Data structure
740aA*
740aAD opdat3          ds
740aAD  opthst                 1      3  0
740aAD  optsli                 4      4
740aAD  optcwr                 5      5
740aAD  optoft                 6      6
740aAD  optdft                 7      7
740aAD  optrft                 8      8
740aAD  optcap                 9      9
740aAD  optdbl                10     10
740aAD  optekd                11     11
740aAD  optdar                12     12
740aAD  optidb                13     13
740aAD  optbda                14     14
740aAD  optgbd                15     15
740aAD  optrtq                16     16
740aAD  optotq                17     17
740aAD  optcce                18     18
740aAD  optsig                19     19
740aAD  optpiv                20     20
740aAD  optsda                21     21
740aAD  optwsp                22     26  0
740aAD  optwsi                27     41
740aAD  optsvd                42     43  0
740aAD  optert                44     47
740aAD  optedv                48     57
740aAD  opteos                58     67
740aAD  optesw                68     71  0
740aAD  optesh                72     75  0
740aAD  optare                76     76
740aAD  optidl                77     77
740aAD  optdci                78     78
740aAD  optpal                79     79
740aAD  optcra                80     80
740aAD  optdrv                81     81
740aAD  optbul                82     82
740aAD  opteys                83     83
740aAD  optsas                84     84
740aAD  optsdl                85     86  0
740aAD  optsdt                87     87
740aAD  optlrk                88     88
740aAD  optgss                89     89
740aAD  optgsu                90     90
740aAD  optsbv                91     91  0
740aAD  optrag                92     92
740aAD  optrd                 93     93
740aAD  optrdt                94     97  0
740aAD  optrfp                98     98
740aAD  optrfm                99     99
740aAD  optnsr               100    100
740aAD  optfbd               101    101
740aAD  optdsf               102    102
740aAD  optsor               103    103
740aAD  optode               104    104
740aAD  optodp               105    106  0
740aAD  optont               107    107
740aAD  optotp               108    108
740aAD  optnsb               109    109
740aAD  optraxinv            110    110
740aAD  opten3               117    117


     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.chkiuse2
650aA /copy qcopysrc,p.wrtsessl
650bA /copy qcopysrc,p.qcmdexc

650bAD QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
650bAD   MsgInfo                  32766A   options(*varsize)
650bAD   MsgInfoLen                  10I 0 const
650bAD   Format                       8A   const
650bAD   StackEntry                  10A   const
650bAD   StackCount                  10I 0 const
650bAD   MsgType                     10A   const
650bAD   MsgKey                       4A   const
650bAD   WaitTime                    10I 0 const
650bAD   MsgAction                   10A   const
650bAD   ErrorCode                32766A   options(*varsize)

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

650bAd CallChkiuse2    pr
     d  cmd                          10    const

650bAD SubmitJob       PR            10I 0
     D   peName                      10A   const varying
     D   peJobQ                      10A   const varying
     D   peCmd                     3000A   const varying
     D   peSbmName                   10A   options(*nopass)
     D   peSbmUser                   10A   options(*nopass)
     D   peSbmNbr                     6A   options(*nopass)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
650aA*      pSessId     Session id
650aA*      pUser       User
650aA*      pPgm        Calling dictionary.pgm
     *      pWhse       Warehouse
     *      pRtid       Route id
     *      pRte        Route
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage         80
650aMC                   parm                    pSessId          40
650aMC                   parm                    pUser            10
650aMC                   parm                    pPgm             20
650bMC                   parm                    pWhse             3
     C                   parm                    pRtid             5
     C                   parm                    pRte              5
650d C                   parm                    pJobq             5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;
         pMessage = ' ';

650bA    // Convert parameters to numeric
650bA
650bA    monitor;
650bA      numWhse = %dec(pWhse: 3: 0);
650bA    on-error;
650bA      bdtype = 'ERROR';
650bA      bdvalues = 'Whse conversion error: ' + pWhse;
650bA      exsr WrtDebug;
650bA      numWhse = 0;
650bA    endmon;

650bA    // Set jobq flag
650bA
650bA    if %parms >= 8 and pJobq = '*JOBQ';
650bA      jobq = *on;
650bA    else;
650bA      jobq = *off;
650bA    endif;

650bA    // When not running from Jobq ...
650bA
650bA    if not jobq;
650bA
650bA      // Do pre-Jobq checks
650bA
650bA      exsr PreJobqChecks;
650bA      if error;
650cM        CallChkiuse2('*CLEAR');
650bA        return;
650bA      endif;
650bA
650bA      // Submit this program to Jobq
650bA
650bA      exsr SubmitProgram;
650bA      return;
650bA
650bA    endif;

      /end-free

414cA*
414cA*  Call Route Summary by Stop Report
414cA*
414cAC                   move      pWhse         $rwhse
414cAC                   call      'OR670CL'
414cAC                   parm                    $rwhse            3
414cAC                   parm      pRtid         $rrtid            5
414cAC                   parm      ' '           $rrtn             8
530 AC                   parm      'N'           $rovr             1
KFSbA*
KFSbAC                   if        client = Kellys
KFSbAC                   call      'OR660CCL'
KFSbAC                   parm      ' '           $rcmd             8
KFSbAC                   parm      '*SUMMARY'    $rtype            8
KFSbAC                   parm                    $rwhse
KFSbAC                   parm      pRtid         $rrtid
KFSbAC                   parm      ' '           $rrtn
KFSbAC                   parm      'N'           $rovr
KFSbAC                   endif
MJKAA*
MJKaA*  Call Route Summary by Stop Report
MJKaA*
MJKaAC                   if        client = mjkeln  or
MJKaAC                             client = dairyl
KFSaAC                             or client = Kellys
HMWaAC                             or client = HMWagner
SBRaAC                             or client = sbertram
ADF AC                             or client = AandDFoods
SFPaAC                             or client = Seashore
MJKaAC                   call      'OR671CL'
MJKaAC                   parm                    $rwhse
MJKaAC                   parm      pRtid         $rrtid
MJKaAC                   parm      ' '           $rrtn
MJKaAC                   parm      'N'           $rovr
MJKaAC                   parm      'E'           $rtds             1
MJKaAC                   endif
520bA*
520bA*    Update unique piece number recs' scan qty, file ORDP.
520bA*
650bMC                   eval      $whs30 = numWhse
520bAC                   call      'OR633'
520cMC                   parm                    $whs30
520bAC                   parm                    pRtid
417aA*
HAR A*    Conditionally call pgms to write XML/POD export files
HAR A*    and XML/ASN export files.
HAR A*
HAR AC                   if        client = harbor
     *
650bMC                   eval      $whs30 = numWhse
HAR AC                   call      'XM155'
HARaMC                   parm                    $whs30            3 0
HAR AC                   parm      pRtid         $brtid            5
HAR AC                   parm      pRte          $btrte            5
HAR AC                   parm      ' '           $prtn             8
     *
HAR AC                   endif
     *
710bM*    If client is using TRAX call TR810 and TR811 to create
710bM*    Trax(c) xml files.
530aA*
530aAC                   if        optrax = 'Y'
740aAC                             and optraxinv = '9'
710bAC                   goto      skipMerge
640eA*
640eA*    If this is a Trax merged route, do not build Trax xml unless
640eA*    all of the connected routes have also been exported.
640eA*
640eAC                   eval      parentRte = pRtid
640eAC     keyrs         setll     ttmerg2
640eAC                   dow       forevr = forevr
640eAC     keyrs         reade     ttmerg2
640eAC                   if        %eof
640eAC                   leave
640eAC                   else
640eAC                   eval      parentRte = t2_ttmpri
640eAC                   leave
640eAC                   endif
640eAC                   enddo
640eA*
640eAC                   eval      firstpass = *on
640eAC     keyttm        setll     ttmerg1
640eAC                   dow       forevr = forevr
640eAC     keyttm        reade     ttmerg1
640eAC                   if        %eof
640eAC                   leave
640eAC                   endif
640eA*
640eA*  Don't build Trax xml if this is a child being exported
640eA*  and the parent route has not yet been exported.
640eAC                   if        firstpass = *on and parentRte <> pRtid
710aA /free
710aA    if not %open(rtehed);
710aA        open(e) rtehed;
710aA        if %error;
710aA            error = *on;
710aA            pMessage = 'Error occured trying to '
710aA                     + 'open file RTEHED in pgm '
710aA                     + #pgm;
700aA          bdtype = 'ERROR';
700aA          bdvalues = pMessage;
700aA          exsr WrtDebug;
710aA        endif;
710aA    endif;
710aA /end-free
640eAC     keyttm        chain     rtehed
640eAC                   if        %found(rtehed)
640eAC                             and r_rhstat = '6'
640eAC                   else
640eAC                   goto      skipTR810
640eAC                   endif
640eAC                   endif
640eAC                   eval      firstpass = *off
640eA*
640eAC                   if        t1_rhstat <> '6'
640eAC                             and t1_ttmcri <> pRtid
640eAC                   goto      skipTR810
640eAC                   endif
640eAC                   enddo
640eA*
710bAC     skipMerge     tag
640eA*
530aAC                   eval      usemp# = 0
530aAC     keyrs         chain     ttrte                              77
530aAC                   if        not *in77
530aAC     ttrusr        chain     piruser                            77
530aAC                   endif
530aAC                   move      usemp#        $emp#
650bMC                   eval      $whs30 = numWhse
530aAC                   call      'TR810'
650bMC                   parm      numWhse       $whs30
530aAC                   parm      pRtid         $brtid
530aAC                   parm                    $emp#
530aAC                   parm      ' '           $filsn           30
530aAC                   parm      ' '           $prtn
530aAC                   parm      ' '           $perm            60
640dA*      Prevent ZMQMSG routine from executing.
640dAC                   if        $prtn = '*OK'
640dAC                   eval      $prtn = ' '
640dAC                   endif
640dA*
710bAC                   call      'TR811'
710bMC                   parm      numWhse       $whs30
710bAC                   parm      pRtid         $brtid
710bAC                   parm                    $emp#
710bAC                   parm      ' '           $filsn           30
710bAC                   parm      ' '           $prtn
710bAC                   parm      ' '           $perm
710bA*      Prevent ZMQMSG routine from executing.
710bAC                   if        $prtn = '*OK'
710bAC                   eval      $prtn = ' '
710bAC                   endif
640dA*
530aAC                   endif
     *
640eAC     skipTR810     tag
     *
CDI AC                   if        client = cdi
CDI AC                   eval      opftp = 'N'
CDI AC                   endif
     *
     *    The call to RH151 has been left alone, except to include
     *    it in the new select statement. Notice, that RH151 will
     *    never display an error because it does not use $PRTN.
     *
411 AC                   select
411 AC                   when      opftp = 'Y'
DRYbA*
DRYbAC                   select
DRYbAC                   when          client = Dairyland
DRYbA*      Call Stage export to Host pgm.
DRYbAC                   eval      $rwhse = %editc(numWhse:'X')
DRYdAC                   eval      $bcmd = '*ALL'
DRYbAC                   call      'RH155SCL'
DRYbAC                   parm                    $bcmd
DRYbAC                   parm                    $rwhse
DRYbAC                   parm      prtid         $brtid
DRYbAC                   parm      pRte          $btrte
DRYbAC                   parm      ' '           $prtn
DRYbA*
SWTaAC                   when          client = SWT
PCK AC                             or  client = Pack730
SWTaAC                   call      'RH155CL2'
SWTaAC                   parm      #prog         $bpgm            10
SWTaAC                   parm      numWhse       $brwhs            3 0
SWTaAC                   parm      pRtid         $brtid
SWTaAC                   parm      pRte          $btrte
SWTaAC                   parm      ' '           $prtn
SWTaAC                   parm      ' '           $pmsg             4
SWTaA*
DRYbAC                   other
411 AC                   call      'RH155CL'
411 AC                   parm      #prog         $bpgm            10
650bMC                   parm      numWhse       $brwhs            3 0
411 AC                   parm      pRtid         $brtid
411 AC                   parm      pRte          $btrte
411 AC                   parm      ' '           $prtn
411 AC                   parm      ' '           $pmsg             4
DRYbAC                   endsl
DRYbA*
640aAC                   when      opftp = 'S'
730aAc                             or opftp ='R'
640aAC                   if        client = cheney
640aAC                   eval      $bcmd = '*HDRDTL'
640aAC                   else
640aAC                   eval      $bcmd = '*ALL'
640aAC                   endif
640aAC                   call      'RH155S'
640aAC                   parm                    $bcmd             8
650bMC                   parm      numWhse       $brwhs            3 0
640aAC                   parm      pRtid         $brtid
640aAC                   parm      pRte          $btrte
640aAC                   parm      ' '           $prtn
640bA*
640bAC                   if        $prtn = ' '
640bA*      Call Stage export to Host pgm.
650bMC                   eval      $rwhse = %editc(numWhse:'X')
640bAC                   call      'RH155SCL'
640bAC                   parm                    $bcmd
640bAC                   parm                    $rwhse
640bAC                   parm      pRtid         $brtid
640bAC                   parm      pRte          $btrte
640bAC                   parm      ' '           $prtn
640bAC                   endif
640bA*
411 AC                   other
OP1 AC                   call      'RH151'
650bMC                   parm      numWhse       $brwhs
OP1 AC                   parm      pRtid         $brtid
OP1 AC                   parm      pRte          $btrte
OP1 AC                   parm      ' '           $brtn             8
411 AC                   endsl

      /free

         // Reset in-use flag

650bM    CallChkiuse2 ('*CLEAR');

PANaA    //Build PFILES for Panos
PANaA    if client = panos;
PANaA       exsr runpfiles;
PANaA    endif;

         return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

      /end-free

     C     keyrs         klist
650bMC                   kfld                    numWhse
     C                   kfld                    pRtid
     *
640eA*  Define partial key for file TTMERG1.
640eA*
640eAC     keyttm        klist
650bMC                   kfld                    numWhse
640eAC                   kfld                    parentRte
PANaA*
PANaAC     keyth         klist
PANaAC                   kfld                    numWhse
PANaAC                   kfld                    $ptruk
PANaA*
PANaAC     keyps3        klist
PANaAC                   kfld                    numWhse
PANaAC                   kfld                    prtid
PANaAC                   kfld                    kytype
PANaA*
PANaAC     keyopz        klist
PANaAC                   kfld                    kycode
PANaAC                   kfld                    numwhse
PANaAC                   kfld                    $ptmpl
PANaAC                   kfld                    kyzone
PANaA*
PANaAC     keyop2        klist
PANaAC                   kfld                    kycode
PANaAC                   kfld                    numWhse
PANaAC                   kfld                    $ptmpl
411 A*
411 A*  Define key for options file.
411 A*
411 AC     keyop         klist
411 AC                   kfld                    opwhse
411 AC                   kfld                    opcode
411 A*
530aA*   Get *SYSTEM options from options file.
530aA*
530aAC                   eval      opwhse = 0
530aAC                   eval      opcode = '*SYSTEM '
530aAC     keyop         chain     options                            79
530aAC                   if        *in79
530aAC                   eval      optrax = 'N'
530aAC                   else
530aAC                   eval      opdat1 = opdata
530aAC                   endif
     *
740aA*   Get *TRAX options from options file.
740aA*
740aAC                   eval      opwhse = numwhse
740aAC                   eval      opcode = '*TRAX   '
740aAC     keyop         chain     options
740aAC                   if        not %found(options)
740aAC                   eval      optraxinv = '9'
740aAC                   else
740aAC                   eval      opdat3 = opdata
740aAC                   endif
     *
411 A*   Get FTP options from options file.
411 A*
411 AC                   eval      opwhse = 0
411 AC                   eval      opcode = '*FTP    '
411 AC     keyop         chain     options                            79
411 AC                   if        *in79
411 AC                   eval      opftp = 'N'
411 AC                   endif

      /free
700aA      bdtype = 'START';
700aA   // bdvalues = %trim(pSessId) + ':'
700aA   //          + %trim(pUser) + ':'
700aA   //          + %trim(pPgm) + ':'
700aA   //          + %trim(pWhse) + ':'
700aA   //          + %trim(pRtid) + ':'
700aA   //          + %trim(pRte) + ':'
700aA   //          + %trim(pJobq);
700aA      exsr WrtDebug;
       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  getrtehed   Get RTEHED record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr getrtehed;

         error = *off;

500sA    // Open rtehed file

         if not %open(rtehed);
             open(e) rtehed;
             if %error;
                 error = *on;
                 pMessage = 'Error occured trying to '
                          + 'open file RTEHED in pgm '
                          + #pgm;
                 leavesr;
             endif;
         endif;

500sA    // Get rtehed record

650bM    chain(e) (numWhse: pRtid) rtehed;

         if %status = 01218; //locked
             error = *on;
             pMessage = 'Route locked by another user '
                      + '('
650bM                 + %Trim(%editc(numWhse:'Z'))
                      + '/'
                      + %Trim(pRte)
                      + '/'
                      + %Trim(pRtid)
                      + ')';
             leavesr;
         endif;

         if not %found;
             error = *on;
             pMessage = 'Route not found '
                      + '('
650bM                 + %Trim(%editc(numWhse:'Z'))
                      + '/'
                      + %Trim(pRte)
                      + '/'
                      + %Trim(pRtid)
                      + ')';
             leavesr;
         endif;

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  PreJobQChecks   Pre-Jobq Checks
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr PreJobQChecks;

         error = *off;

         // Verify route is still at "closed" status

         exsr getrtehed;
         if error;
             leavesr;
         endif;

         // if r_rhstat <> '5';
         if r_rhstat <> '5' and r_rhtype <> 'W';
             error = *on;
             pMessage = 'Route not at CLOSED status '
                      + '('
                      + %Trim(r_rhstat)
                      + ')';
             leavesr;
         endif;

         // Set in-use flag

650aA    monitor;
650bM      CallChkiuse2 ('*INUSE4');
650aA    on-error;
           error = *on;
650aA      pMessage = 'Error calling GETIUSE2 program';
700aA      bdtype = 'ERROR';
700aA      bdvalues = pMessage;
700aA      exsr WrtDebug;
650aA      leavesr;
650aA    endmon;

650aA   if $iRtn = '*ERROR';
           error = *on;
650aA      pMessage = 'Route in use - ' + %trimr($iuText30) + ' '
650aA               + '('
650bM               + %Trim(%editc(numWhse:'Z'))
650aA               + '/'
650aA               + %Trim(pRte)
650aA               + '/'
650aA               + %Trim(pRtid)
650aA               + '/'
650aA               + %Trim($iuUser)
650aA               + '/'
650aA               + %Trim($iuSessId)
650aA               + ')';
700aA      bdtype = 'ERROR';
700aA      bdvalues = pMessage;
700aA      exsr WrtDebug;
650aA      leavesr;
650aA    endif;


       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  SubmitProgram   Submit Program
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr SubmitProgram;

         sbmCmd = 'CALL  '
                +   'PGM(' + %trimr(#pgm) + ') '
                +   'PARM('
                +      sq + pMessage + sq + ' '
                +      sq + pSessId + sq + ' '
                +      sq + pUser + sq + ' '
                +      sq + pPgm + sq + ' '
                +      sq + pWhse + sq + ' '
                +      sq + pRtid + sq + ' '
                +      sq + pRte + sq + ' '
                +      sq + '*JOBQ' + sq
                +   ')';

         if SubmitJob(#pgm: 'BFCJOBQ':
                      sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;

650dA      bdtype = 'ERROR';
650dA      bdvalues = 'sbmcmd:' + %trimr(sbmcmd);
650dA      exsr WrtDebug;
           pMessage = 'Error submitting command ' + #pgm;
650cM      CallChkiuse2('*CLEAR');
           return;

         endif;

650aA    // Write GLOSESSLOG record
650aA
650aA    logText = 'whs:' + pWhse + ','
650aA            + 'nwhse:' + %char(numWhse) + ','
650aA            + 'rtid:' + %trim(pRtid) + ','
650aA            + 'rte:' + %trim(pRte);
650aA    wrtsesslog(pSessId: #pgm: pPgm: pUser: logText:
650aA               sbmJob: sbmUser: sbmJobNbr);

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  wrtDebug       Write out debug record
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
PANaA*----------------------------------------------------------------
PANaA*
PANaA*  Build EXPSPLBL process
PANaA*
PANaAC     RUNPFILES     BEGSR
PANaA*
PANaA* Get Zone Template Code if Template type is T=Truck
PANaA*
PANaAc                   if        not %open(rtehed)
PANaAC                   open      rtehed
PANaAc                   end
PANaAC                   eval      parentRte = pRtid
PANaAC     keyttm        chain     rtehed
PANaAC                   if        %found(rtehed)
PANaAC                   eval      $ptruk = r_rhtruk
PANaAC                   end
PANaA*
PANaAC     keyth         chain     truckh
PANaAC                   if        %found(truckh)
PANaAC                             and thtype = 'T'
PANaAC                   eval      $ptmpl =  thztmp
PANaAC                   else
PANaAC                   eval      $ptmpl =  $ptruk
PANaAC                   endif
PANaA*
PANaAc*                  if        parentrte = *blanks
PANaAc*                  eval      parentrte = rhrtid
PANaAc*                  endif
PANaAc**                 eval      prte = r_rhrte
PANaAc**                 eval      prtid = r_rhrtid
PANaA*
PANaA*  Loop through pallets in reverse generation order.
PANaA*
PANaAC                   eval      kytype = 'O'
PANaAC     keyps3        setll     pltsum3
PANaAC                   dow       forevr = forevr
PANbDC*    keyps3        reade     pltsum3                                79
PANbDC*                  if        *in79
PANbMC     keyps3        reade     pltsum3
PANbMC                   if        %eof
PANaAC                   leave
PANaAC                   endif
PANaA*
PANaA*
PANaA*    Skip duplicate zones.
PANaA*
PANaAC                   if        psszon = lstzon
PANaA*    or skip empty pallet zones.
PANaAC                             or pstzon = ' '
PANaAC                             and pspzon = ' '
PANaAC                             and psszon = ' '
PANaAC                             and pstrn# = 0
PANaAC                   iter
PANaAC                   else
PANaAC                   eval      lstzon=psszon
PANaAC                   endif
PANaA*
PANaA*    Get picking options for zone.
PANaA*
PANaAC                   eval      kycode = '*PICKLBL'
PANaAC                   eval      kyzone = psszon
PANaAC                   eval      opdta2 = *blanks
PANaAC     keyopz        chain     optionz                            79
PANaAC                   if        *in79 = *off
PANaAC                   eval      opdta2 = opzdta
PANaAC                   endif
PANaAC                   if        *in79
PANaAC     keyop2        setll     optionz
PANaAC     keyop2        reade     optionz                                78
PANaAC                   if        *in78
PANaAC                   eval      oplpgm = *blanks
PANaAC                   else
PANaAC                   eval      opdta2 = opzdta
PANaAC                   endif
PANaAC                   endif
PANaAc*
PANaA*  Build EXPSLBL with export data
PANaAC*                  eval       $whse=$pwhse
PANaAc*
PANaAC                   call      'PFILES'
PANaAC                   parm      '*PRINT  '    cmd
PANaAC                   parm                    numWhse
PANaAC                   parm                    prtid
PANaAC                   parm                    pscomp
PANaAC                   parm                    pstzon
PANaAC                   parm                    psgen
PANaAC                   parm                    psszon
PANaAC                   parm                    $ptruk
PANaAC                   parm                    prte
PANaAC                   parm                    opdta2
PANaAC                   parm                    $prtn
PANaAC                   call      'PFILES'
PANaAC                   parm      '*CLOSE  '    cmd
PANaAC                   parm                    numWhse
PANaAC                   parm                    prtid
PANaAC                   parm                    pscomp
PANaAC                   parm                    pstzon
PANaAC                   parm                    psgen
PANaAC                   parm                    psszon
PANaAC                   parm                    $ptruk
PANaAC                   parm                    prte
PANaAC                   parm                    opdta2
PANaAC                   parm                    $prtn
PANaA*
PANaAc                   enddo
PANaA*
PANaA*  Update EXPSLBL with payroll and performance data
PANaA*
PANaAc                   call      'PFILES2'
PANaA*
PANaAC                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CallChkiuse2  Call CHKIUSE2
     *----------------------------------------------------------------

     p CallChkiuse2    b
     d CallChkiuse2    pi
     d  cmd                          10    const

      /free

650aM    chkiuse2 (cmd: numWhse: pRtid:
650aM              pPgm: pUser: pSessId: $irtn:
650aM              $iuText10: $iuText30: $iuCmd: $iuPgm:
650aM              $iuUser: $iuSessId: $iuJobName: $iuJobNbr:
650aM              $iuJobUser: $iuStamp);

      /end-free

     p CallChkiuse2    e

650bA*----------------------------------------------------------------
650bA*  SubmitJob   Submit job to job queue
650bA*
650bA*     peName    = name of job to submit
650bA*     peJobQ    = Queue to submit to
650bA*     peCmd     = Command to submit
650bA*     peSbmName = name returned by the submit job command
650bA*     peSbmUser = user returned by the submit job command
650bA*     peSbmNbr  = job number returned by the submit job command
650bA*
650bA*  Returns 0 if successful, or -1 if it failed
650bA*----------------------------------------------------------------
650bAP SubmitJob       B                   export
650bAD SubmitJob       PI            10I 0
     D   peName                      10A   const varying
     D   peJobQ                      10A   const varying
     D   peCmd                     3000A   const varying
     D   peSbmName                   10A   options(*nopass)
     D   peSbmUser                   10A   options(*nopass)
     D   peSbmNbr                     6A   options(*nopass)

     *  Local Variables

     D cmd             s           3000    varying

     D dsM1            DS
     D  dsM1_BytRtn                  10I 0
     D  dsM1_BytAvl                  10I 0
     D  dsM1_MsgSev                  10I 0
     D  dsM1_MsgID                    7A
     D  dsM1_MsgType                  2A
     D  dsM1_MsgKey                   4A
     D  dsM1_Reserv1                  7A
     D  dsM1_CCSID_st                10I 0
     D  dsM1_CCSID                   10I 0
     D  dsM1_DtaLen                  10I 0
     D  dsM1_DtaAvl                  10I 0
     D  dsM1_Dta                    256A

     D dsEC            DS
     D  dsECBytesP             1      4I 0 INZ(%size(dsEC))
     D  dsECBytesA             5      8I 0 INZ(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

     D wwMsgKey        S              4A
     D wwJobNo         S             26A

      /free

         // Submit job

         cmd = 'SBMJOB CMD(' + peCmd + ') ' +
               'JOBQ(' + peJobQ +') ' +
               'JOB(' + peName+ ')';

         monitor;
           qcmdexc(%trim(cmd): %len(%trim(cmd)));
         on-error *all;
           return -1;
         endmon;

         // Look for a success message

         wwMsgKey = *ALLx'00';
         dou dsECBytesA>0 or dsM1_MsgID='CPC1221';
           QMHRCVPM(dsM1: %size(dsM1): 'RCVM0100':
                    '*': 0: '*PRV': wwMsgKey: 0: '*SAME':
                    dsEC);
           wwMsgKey = dsM1_MsgKey;
         enddo;

         if dsECBytesA>0;
           return -1;
         endif;

         // Grab the job info from the response

         if dsM1_DtaAvl >= 26;
           wwJobNo = %subst(dsM1_Dta:1:26);
         else;
           wwJobNo = *blanks;
         endif;

         if %parms >= 4;
           peSbmName = %subst(wwJobNo:1:10);
         endif;

         if %parms >= 5;
           peSbmUser = %subst(wwJobNo:11:10);
         endif;

         if %parms >= 6;
           peSbmNbr = %subst(wwJobNo:21:6);
         endif;

         return 0;

      /end-free

     P                 E
