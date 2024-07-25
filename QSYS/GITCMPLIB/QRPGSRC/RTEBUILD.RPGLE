417cA /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  BUILDRTE    Build Rte - Pgm for SQL procedure of same name
     *  30 September 2009
     *  Dave Sommerville
     *
     *  Revisions:
     *
610 A*    09/30/09  DAS  6.10
     *      - Created.
     *
640a *    05/12/12  DAS  6.40a
     *      - Added new checks from RH120A
     *
640b *    05/12/12  DAS  6.40b
     *      - Changed RTEHED to update file to check for lock.
     *
650a *    12/13/31  DAS  6.50a
     *      - Added Session Id, Program, User to use with CHKIUSE2
     *      - Revised to use CHKIUSE2
     *
650b *    02/11/14  DAS  6.50b
     *      - Revised to submit OR605.
     *      - Added call to WRTSESSLOG with submitted info.
     *
650c *    03/05/14  DAS  6.50c
     *      - Moved pSessId, pUser, pPgm paramters
     *
650d *    03/11/14  DAS  6.50d
     *      - Changed pWhse to character field.
     *      - Revised to submit this program to jobq.
     *      - Moved call to chkiuse2 into subprocedure
     *
700a *    05/19/15  LMC  7.00a
     *      - Enh: Revised program to add support for Client id
     *
730aA*    09/15/19  DAS  7.30a
     *      - Added JQ WRTRTELOG logic
     *
740 A*    01/29/20  KDE  7.40
     *      - Enh: Revised to perform Route edits only for Wave Processing
     *
740aA*    09/22/20  LMC  7.40a
     *      - Enh: will also work for will call routes.
     *
750aA*    02/22/21  DAS  7.50a
     *      - Revised to create RTEHEDEXA record if it doesn't exist
     *        or to update TBType if blank.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Reinhart  Custom Changes
     *
RFSa *    05/19/15  LMC  RFSa
     *      - Each warehouse needs to use their own set of JOBQ's.
     *
     *----------------------------------------------------------------
     * US Foods  Custom Changes
     *
USFa *    05/19/15  LMC  USFa
     *      - Each branch needs to use their own set of JOBQ's.
     *
     *----------------------------------------------------------------
     * Client Custom Changes: Dairyland
     *
DRY A*    04/18/17  MLB  DRY
     *      - Each warehouse needs to use their own set of JOBQ's.
     *        Per Kelly R email dated 04.13.17.
     *      - Added DRY to RFS mod.
     *
     *----------------------------------------------------------------
     * Client Custom Changes: PFG Performance Food Group
     *
PFG A*    02/08/19  MLB  PFG
     *      - Each warehouse needs to use their own set of JOBQ's.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Notes
     *
     *    The verification logic was taken from RH120A.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

640bDF*tehed    if   e           k disk    usropn
640bMFrtehed    uf   e           k disk    usropn
640aAFordh4     if   e           k disk    rename(ohrec:ohrec4)
640aAFordh10    if   e           k disk    prefix(oh_)
640aAFoptionz   if   e           k disk
640aAFoptionz3  if   e           k disk    rename(opzrec:opz3) prefix(x)
640aAFtruckh    if   e           k disk
650dAFbfcdebug  o    e           k disk

700aA*----------------------------------------------------------------
700aA*  Customer id
700aA*----------------------------------------------------------------

RFSaA /copy qcopysrc,id#rfs
USFaA /copy qcopysrc,id#usfcorp
DRY A /copy qcopysrc,id#dairyla
PFG A /copy qcopysrc,id#pfg

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

750aA /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

750aDD*sq              c                   Const('''')

750aDD*error           s               n
650cAD jobq            s               n

640aAD forevr          s               n
640aAD $ptmpl          s             10
640aAD $kwhse          s              3s 0
640aAD kycod3          s                   like(opzcod)
640aAD kycod4          s                   like(opzcod)
640aAD $irtn           s              8
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
700aAD bfcjobq         s             10
700aAD client          s             10
700aAD clientloc       s             10
700aAD cmdjobq         s           3000    varying
650bAD logText         s            100
650bAD sbmCmd          s           3000    varying
650bAD sbmJob          s             10A
650bAD sbmUser         s             10A
650bAD sbmJobNbr       s              6A
650cAD numWhse         s              3  0
740 Ad subGrp          s             12

730aA*----------------------------------------------------------------
730aA*  WRTRTELOG Parameters
730aA*----------------------------------------------------------------
730aA
730aAd rlmrid          s             26
730aAd rlGrpId         s              7  0
730aAd rlGrpCode       s             10
730aAd rlSubGrp        s             12
730aAd rlType          s              1
730aAd rlJobqTS        s             26
730aAd rlJobqUC        s             26

640aA*----------------------------------------------------------------
640aA*  *PICKLBA -  Label printing options for the standard pick,
640aA*              retail, and tote labels.
640aA*
640aA*     08/12/09  RBD  5.20  P#00219
640aA*       - Added record type *PICKLBA which holds printing info
640aA*         for the standard pick, retail, and tote labels.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
     *    OPCU1   -  Use cutter option Y/N.           - Standard pick label
     *    OPLP1   -  Label printing program.          - Standard pick label
     *    OPDV1   -  Printer device.                  - Standard pick label
     *    OPFM1   -  Form.                            - Standard pick label
     *
     *    OPLB2   -  Print retail label Y/N.          - Retail label
     *    OPCU2   -  Use cutter option Y/N.           - Retail label
     *    OPLP2   -  Label printing program.          - Retail label
     *    OPDV2   -  Printer device.                  - Retail label
     *    OPFM2   -  Form.                            - Retail label
     *
     *    OPLB3   -  Print tote label Y/N.            - Tote label
     *    OPCU3   -  Use cutter option Y/N.           - Tote label
     *    OPLP3   -  Label printing program.          - Tote label
     *    OPDV3   -  Printer device.                  - Tote label
     *    OPFM3   -  Form.                            - Tote label
     *
     * Data structure
     *
     D opdta3          ds
     D  oplb1                  1      1
     D  opcu1                  2      2
     D  oplp1                  3     12
     D  opdv1                 13     22
     D  opfm1                 23     32
     D  oplb2                 33     33
     D  opcu2                 34     34
     D  oplp2                 35     44
     D  opdv2                 45     54
     D  opfm2                 55     64
     D  oplb3                 65     65
     D  opcu3                 66     66
     D  oplp3                 67     76
     D  opdv3                 77     86
     D  opfm3                 87     96
     D  opend3               117    117
640aA*----------------------------------------------------------------
640aA*  *PICKLBB -  Label printing options for the pick list and
640aA*               ASN labels and pick list report.
640aA*
640aA*     08/12/09  RBD  5.20  P#00219
640aA*       - Added record type *PICKLBB which holds printing info
640aA*         for the pick list and ASN labels and pick list report.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB4   -  Print pick list label Y/N.       - Pick list label
     *    OPCU4   -  Use cutter option Y/N.           - Pick list label
     *    OPLP4   -  Label printing program.          - Pick list label
     *    OPDV4   -  Printer device.                  - Pick list label
     *    OPFM4   -  Form.                            - Pick list label
     *
     *    OPLB5   -  Print ASN label Y/N.             - ASN label
     *    OPCU5   -  Use cutter option Y/N.           - ASN label
     *    OPLP5   -  Label printing program.          - ASN label
     *    OPDV5   -  Printer device.                  - ASN label
     *    OPFM5   -  Form.                            - ASN label
     *
     *    OPLB6   -  Print pick list report Y/N.      - Pick list report
     *    OPCU6   -  Use cutter option Y/N.           - Pick list report
     *    OPLP6   -  Label printing program.          - Pick list report
     *    OPDV6   -  Printer device.                  - Pick list report
     *    OPFM6   -  Form.                            - Pick list report
     *
     *    OPLB7   -  Print PICK labels for ZONPKUP 1/2- Pick labels
     *
     * Data structure
     *
     D opdta4          ds
     D  oplb4                  1      1
     D  opcu4                  2      2
     D  oplp4                  3     12
     D  opdv4                 13     22
     D  opfm4                 23     32
     D  oplb5                 33     33
     D  opcu5                 34     34
     D  oplp5                 35     44
     D  opdv5                 45     54
     D  opfm5                 55     64
     D  oplb6                 65     65
     D  opcu6                 66     66
     D  oplp6                 67     76
     D  opdv6                 77     86
     D  opfm6                 87     96
     D  oplb7                 97     97
     D  opend4               117    117
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
640aAD  $llb                  22     22
640aAD  $lcu                  23     23
640aAD  $llp                  24     33
640aAD  $ldv                  34     43
640aAD  $lfm                  44     53
640aAD  $llbltype             54     54

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

650bA /copy qcopysrc,p.qcmdexc
650bA /copy qcopysrc,p.wrtsessl
650aA /copy qcopysrc,p.chkiuse2
700aA /copy qcopysrc,p.getclien
730aA /copy qcopysrc,p.wrtrtelg
750aA /copy qcopysrc,p.exrtehed
750aA /copy qcopysrc,p.gettbtyp

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

650cAd CallChkiuse2    pr
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
650cM*      pSessId  Session id
650cM*      pUser    User
650cM*      pPgm     Calling dictionary.pgm
     *      pWhse    Warehouse
     *      pRtid    Route id
     *      pRte     Route
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
650cMC                   parm                    pSessId          40
650cMC                   parm                    pUser            10
650cMC                   parm                    pPgm             20
650dMC                   parm                    pWhse             3
     C                   parm                    pRtid             5
     C                   parm                    pRte              5
650dAC                   parm                    pJobq             5
730aAC                   parm                    pSubGrp          12
730aAC                   parm                    pGrpId           15 5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

650dA    // Convert parameters to numeric
650dA
650dA    monitor;
650dA      numWhse = %dec(pWhse: 3: 0);
650dA    on-error;
650dA      bdtype = 'ERROR';
650dA      bdvalues = 'Whse conversion error: ' + pWhse;
650dA      exsr WrtDebug;
650dA      numWhse = 0;
650dA    endmon;

650dA    // Set jobq flag
650dA
740 A
740 A    if %parms >= 9;
740 A      subGrp=psubgrp;
740 A    else;
740 A      subGrp=*blanks;
740 A    endif;
740 A
740 D    //if %parms >= 8 and pJobq = '*JOBQ';
740 M    if %parms >= 8 and pJobq = '*JOBQ' and subGrp<>'*ALOCSTG';
650dA      jobq = *on;
650dA    else;
650dA      jobq = *off;
650dA    endif;

650dA    // When not running from Jobq ...
650dA
650dA    if not jobq;
650dA
650dA      // Do pre-Jobq checks
650dA
650dA      exsr PreJobqChecks;
740 D      //if error;
740 A      if error or subGrp='*ALOCSTG';
740 A        CallChkiuse2 ('*CLEAR');
650dA        return;
650dA      endif;
650dA
650dA      // Submit this program to Jobq
650dA
650dA      exsr SubmitProgram;
650dA      return;
650dA
650dA    endif;

730aA    // Record end of jobq to log
730aA
730aA    if %parms() >= 10;
730aA      rlGrpCode = '*ALOCBLD';
730aA      rlType = '2';
730aA      rlGrpId = pGrpId;
730aA      rlSubGrp = pSubGrp;
730aA      wrtrtelog(numWhse: pRtid: rlmrid: rlGrpId: rlGrpCode: rlSubGrp:
730aA                rlType: pUser: #pgm: rlJobqTS: rlJobqUC);
730aA    endif;

         // Call program to build route

740aA   exsr getrtehed;
740aA   if rhtype = 'W';
740aA     $btype = '*WCPICK1';
740aA     $bprg  = 'GWBUILD';
740aA   else;
740aA     $btype = '*PICK1';
740aA     $bprg  = ' ';
740aA   endif;
      /end-free
510bAC                   call(e)   'OR605'
510bAC                   parm      '*PICK   '    $bcmd             8
510bAC                   parm      '*ALOCBLD'    $bcmd2            8
740aDC*                  parm      '*PICK1  '    $btype            8
740aMC                   parm                    $btype            8
510bAC                   parm      '0'           $bjtyp            1
510bAC                   parm      numWhse       $bwhs            15 5
510bAC                   parm      0             $bbat             7 0
510bAC                   parm      ' '           $bstat            1
510bAC                   parm      pRtid         $brtid            5
510bAC                   parm      0             $bord             7 0
510bAC                   parm      0             $brwhs            3 0
510bAC                   parm      ' '           $btrte            5
510bAC                   parm      ' '           $brtn             8
510bAC                   parm      ' '           $bmsg             4
740bDC*                  parm      ' '           $bprg            10
740bMC                   parm                    $bprg            10
      /free

         // Error on call

         if %error;
             error = *on;
             pMessage = 'Error calling program OR605';
650bA        bdtype = 'ERROR';
650bA        bdvalues = pMessage;
650bA        exsr WrtDebug;
650dM        CallChkiuse2 ('*CLEAR');
             return;
         endif;

         return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

640aA*----------------------------------------------------------------
640aA*  *INZSR    Initialization subroutine
640aA*----------------------------------------------------------------
640aA
640aAC     *inzsr        begsr

700aA /free
700aA   getclient(client: clientLoc);
700aA /end-free

     *  Define key for TRUCKH file.

     C     trkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    rhtruk
     *
     *  Define key for OPTIONZ file.
     *
     C     opzkya        klist
     C                   kfld                    kycod3
     C                   kfld                    $kwhse
     C                   kfld                    $ptmpl

     C     opzkyb        klist
     C                   kfld                    kycod4
     C                   kfld                    $kwhse
     C                   kfld                    $ptmpl

     *  Define partial key for file ORDH4.

     C     keyordh4      klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid

     *  Define key for file ORDH10.

     C     keyordh10     klist
     C                   kfld                    ohwhse
     C                   kfld                    ohcord

     C                   endsr

700aA*----------------------------------------------------------------
700aA*  chkjobq     Check to make sure jobq exists
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr chkjobq;

700aA    // check for jobq
700aA    cmdjobq = 'CHKOBJ ' +
700aA    'OBJ('+ bfcjobq +') ' +
700aA    'OBJTYPE(*JOBQ)';

700aA    monitor;
700aA      qcmdexc(%trim(cmdjobq): %len(%trim(cmdjobq)));
700aA    on-error *all;
700aA      bfcjobq = 'BFCJOBQ';
700aA    endmon;
700aA  endsr;
700aA /end-free

750aA*----------------------------------------------------------------
750aA*  ChkTBType   Check to make TruckBuilder type exists
750aA*----------------------------------------------------------------
750aA
750aA /free
750aA  begsr ChkTBType;

         // Get RTEHEDEX info. Get out if call error.

         monitor;
           exWhse = numWhse;
           EXRTEHED('*GET': exRtnCode: exRtnMsg:
                    exWhse: pRtid: rhatbtype);
         on-error;
           leavesr;
         endmon;

         // Get out if TBType defined

         if rhatbtype <> '';
           leavesr;
         endif;

         // Get default TB type

         monitor;
           GetTBType(numWhse: prtid: rhatbtype);
           if rhatbtype = 'B';
             error = *on;
             pMessage = 'TB processing type not defined for route id '
                      + prtid + ' '
                      + 'and default is B=Both.';
             leavesr;
           endif;
         on-error;
           error = *on;
           pMessage = 'Error getting TB Processing Type (GetTBType)';
           leavesr;
         endmon;

750 A    // If Super Route then force Enhanced
750 A    if %subst(rhrte:1:3)='#SR';
750 A      rhatbtype='E';
750 A    endif;

         // Update/Add TB Type

         monitor;
           if exRtnCode <> '*ERROR';
             EXRTEHED('*CHANGE': exRtnCode: exRtnMsg:
                      exWhse: prtid: rhatbtype);
           else;
             EXRTEHED('*ADD': exRtnCode: exRtnMsg:
                      exWhse: prtid: rhatbtype);
           endif;
         on-error;
           error = *on;
           pMessage = 'Error updating TB Processing Type (GetTBType)';
           leavesr;
         endmon;

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

         chain(e) (numWhse: pRtid) rtehed;

         if %status = 01218; //locked
             error = *on;
             pMessage = 'Route locked by another user '
                      + '('
                      + %Trim(%editc(numWhse:'Z'))
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
                      + %Trim(%editc(numWhse:'Z'))
                      + '/'
                      + %Trim(pRte)
                      + '/'
                      + %Trim(pRtid)
                      + ')';
             leavesr;
         endif;

640bA    unlock rtehed;

       endsr;
      /end-free

650dA*----------------------------------------------------------------
650dA*  PreJobQChecks   Pre-Jobq Checks
650dA*----------------------------------------------------------------
650dA
650dA /free
650dA  begsr PreJobQChecks;

         error = *off;

         // Verify route is still at "open" or "allocated" status

         exsr getrtehed;
         if error;
             leavesr;
         endif;

         if rhstat <> '1' and rhstat <> '2';
             error = *on;
             pMessage = 'Route not at OPEN status '
                      + '('
                      + %Trim(rhstat)
                      + ')';
             leavesr;
         endif;
750aA
750aA    // Make sure TruckBuilder Processing Type is defined
750aA
750aA    exsr chkTBType;
750aA    if error;
750aA      leavesr;
750aA    endif;

640aA    // Do extra verifications that came from RH120A
640aA
640aA    $kwhse = numWhse;
640aA    exsr rh120aChecks;
640aA    if pMessage <> ' ';
           error = *on;
640aA      leavesr;
640aA    endif;

         // Set in-use flag

650dM    CallChkiuse2 ('*INUSE1');

         if $irtn = '*ERROR';
             error = *on;
             pMessage = 'Route already in use '
                      + '('
                      + %Trim(%editc(numWhse:'Z'))
                      + '/'
                      + %Trim(pRte)
                      + '/'
                      + %Trim(pRtid)
650aA                 + '/'
650aA                 + %Trim($iuUser)
650aA                 + '/'
650aA                 + %Trim($iuSessId)
                      + ')';
             return;
         endif;

       endsr;
      /end-free

640aA*----------------------------------------------------------------
640aA*  rh120aChecks    Extra checks from RH120A
640aA*----------------------------------------------------------------
640aA
640aAC     rh120aChecks  begsr

     *   Do not allow Aloc/Build if route contains Pre-Picked items
     *   where the Pre-Pick route is a status less than 4 Pick/Printed.

     C     keyordh4      setll     ordh4
     C                   dow       forevr = forevr

     C     keyordh4      reade     ordh4
     C                   if        %eof
     C                             or %subst(ohmisc:17:1) = 'Y'
     C                   leave
     C                   endif

     C     keyordh10     setll     ordh10
     C                   dow       forevr = forevr

     C     keyordh10     reade     ordh10
     C                   if        %eof
     C                   leave
     C                   endif

     C                   if        %subst(oh_ohmisc:17:1) <> 'Y'
     C                   iter
     C                   endif

     C                   if        rhrte = oh_rhrte
     C                             and oh_rhstat < '4'
     C                   eval      pMessage = 'Pre-Picked items not '
     C                                      + 'yet Pick/Printed ('
     C                                      + %trim(prte) + '/'
     C                                      + %trim(prtid) + ')'
     C                   leavesr
     C                   endif

     C                   enddo

     C                   enddo
     *
     *   Do not allow Aloc/Build if the zone template has any printers
     *   that are not valid or not entered.                           .
     *
     * Get Zone Template Code if Template type is T=Truck
     *
     C     trkey         chain     truckh
     C                   if        %found(truckh) and thtype = 'T'
     C                   eval      $ptmpl =  thztmp
     C                   else
     C                   eval      $ptmpl =  rhtruk
     C                   endif
     * Pick/Retail/Tote
     C                   eval      opdta3 = *blanks
     C                   eval      kycod3 = '*PICKLBA'
     C     opzkya        setll     optionz
     C                   dou       %eof(optionz)
     C     opzkya        reade     optionz
     C                   if        not %eof(optionz)
     C                   eval      opdta3 = opzdta
     * Pick Label Device
     C                   if        oplb1 = 'Y'
     C                   eval      $llp = oplp1
     C                   eval      $ldv = opdv1
     C                   eval      $llbltype = '1'
     C                   exsr      VerifyDevice
     C                   if        pMessage <> ' '
     C                   leavesr
     C                   endif
     C                   endif
     * Retail Label Device
     C                   if        oplb2 = 'Y'
640bAC                   eval      $llp = oplp2
640bAC                   eval      $ldv = opdv2
640bAC                   eval      $llbltype = '2'
640bAC                   exsr      VerifyDevice
640bAC                   if        pMessage <> ' '
640bAC                   leavesr
640bAC                   endif
640bAC                   endif
     * Tote Label Device
640bAC                   if        oplb3 = 'Y'
640bAC                   eval      $llp = oplp3
640bAC                   eval      $ldv = opdv3
640bAC                   eval      $llbltype = '3'
640bAC                   exsr      VerifyDevice
640bAC                   if        pMessage <> ' '
640bAC                   leavesr
640bAC                   endif
640bAC                   endif
640bAC                   endif
640bAC                   enddo
     * ASN/Pick List Label & Report
640bAC                   eval      kycod4 = '*PICKLBB'
640bAC                   eval      opdta4 = *blanks
640bAC     opzkyb        setll     optionz
640bAC                   dou       %eof(optionz)
640bAC     opzkyb        reade     optionz
640bAC                   if        not %eof(optionz)
640bAC                   eval      opdta4 = opzdta
     * ASN Label Device
640bAC                   if        oplb4 = 'Y'
640bAC                   eval      $llp = oplp4
640bAC                   eval      $ldv = opdv4
640bAC                   eval      $llbltype = '4'
640bAC                   exsr      VerifyDevice
640bAC                   if        pMessage <> ' '
640bAC                   leavesr
640bAC                   endif
640bAC                   endif
     * Pick List Label Device
640bAC                   if        oplb5 = 'Y'
640bAC                   eval      $llp = oplp5
640bAC                   eval      $ldv = opdv5
640bAC                   eval      $llbltype = '5'
640bAC                   exsr      VerifyDevice
640bAC                   if        pMessage <> ' '
640bAC                   leavesr
640bAC                   endif
640bAC                   endif
     * Pick List Report Device
640bAC                   if        oplb6 = 'Y'
640bAC                   eval      $llp = oplp6
640bAC                   eval      $ldv = opdv6
640bAC                   eval      $llbltype = '6'
640bAC                   exsr      VerifyDevice
640bAC                   if        pMessage <> ' '
640bAC                   leavesr
640bAC                   endif
640bAC                   endif
640bAC                   endif
640bAC                   enddo

     C                   endsr

650dA*----------------------------------------------------------------
650dA*  SubmitProgram   Submit Program
650dA*----------------------------------------------------------------
650dA
650dA /free
650dA  begsr SubmitProgram;

730aA    // Moved building of sbmCmd to just before submit

         // Determine jobq to use

700aA    Select;
RFSaA      when client = rfs
DRY A        or client = dairyland;
RFSaA        bfcjobq = 'BFCALC' + pwhse;
RFSaA        exsr chkjobq;

USFaA      when client = usfcorp;
USFaA        bfcjobq = 'BFCALCA_' + %trim(clientloc);
USFaA        exsr chkjobq;

PFG A      when client = pfg;
PFG A        bfcjobq = 'BFCALCB' + pwhse;
PFG A        exsr chkjobq;

700aA      other;
700aA        bfcjobq = 'BFCJOBQ';
700aA    endsl;

730aA    // Record start of jobq to log
730aA
730aA    rlGrpCode = '*ALOCBLD';
730aA    rlType = '1';
730aA    rlGrpId = 0;
730aA    rlSubGrp = 'JQ' + bfcjobq;
730aA    wrtrtelog(numWhse: pRtid: rlmrid: rlGrpId: rlGrpCode: rlSubGrp:
730aA              rlType: pUser: #pgm: rlJobqTS: rlJobqUC);

         // Build call string
730aM    // Moved here from beginning of routine

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
730aM           +      sq + '*JOBQ' + sq + ' '
730aA           +      sq + %trim(rlSubGrp) + sq + ' '
730aA           +      %char(rlGrpId)
                +   ')';

700aD    //if SubmitJob(#pgm: 'BFCJOBQ':
                      //sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;
700aM    if SubmitJob(#pgm: bfcjobq:
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

640aA*----------------------------------------------------------------
640aA*  VerifyDevice  Verify printer device
640aA*----------------------------------------------------------------
640aA
640aAC     VerifyDevice  begsr

640bAC                   eval      $lwhse = numWhse
640bAC                   call      'ZH125'
640bAC                   parm                    $lparm
640bAC                   if        $lrtn = '*ERROR  '
640bAC                   eval      pMessage = %trim($lerm)
640bAC                                      + ' in zone template '
640bAC                                      + $ptmpl
640bAC                   endif

     C                   endsr

650dA*----------------------------------------------------------------
650dA*  wrtDebug       Write out debug record
650dA*----------------------------------------------------------------
650dA
650dA /free
650dA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

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
