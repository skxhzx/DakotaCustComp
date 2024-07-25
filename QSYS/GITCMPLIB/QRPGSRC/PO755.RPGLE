     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO755     Remove exported purchase orders - Post
     *  14 November, 1994
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *----------------------------------------------------------------
     *  Revisions
     *
218 A*    02/06/97  RH   2.18
     *      - Change to POHHDR & POHDTL files from POH & POD files.
406 A*    10/01/97  RH   4.06
     *      - Remove records from files LABEL, PIRTRAN and LICENSE
     *
414aA*    04/25/00  MLB  4.14a
     *      - Revised routine ZZLABL to process a DO loop when re-
     *        moving records from PIRTRAN.
     *      - Removed indicators from all SETLL in all routines.
     *      - Conditioned setting of EFLAG in all routines.
414bA*    04/27/00  MLB  4.14b
     *      - Added new routine ZZMFR to process POMFR P/O Mfr date
     *        information file.
     *
415aA*    05/08/01  MLB  4.15a
     *      - Added new routine ZZRCV to process PORCV file and remove
     *        entries older than cutoff date.
416aA*    05/24/02  RH   4.16a
     *      - Recompile, LICENSE and PORCV file changed.
416bA*    12/18/02  HNK  4.16b
     *      - Add Lumper file.
     *
510 A*    06/08/06  MLB  5.10
     *      - Enh: Added p/o header misc. file POHHDRM file to
     *        clean-up program.
     *
510b *    11/20/06  RAH  5.10b
     *      - Enh: Converted to RPGLE.
     *      - Enh: Add POHACCP and POHHACCP.
510cA*    01/08/07  RH    5.10c
     *      - Enh: Recompile POHHACCP file key changed.
510dA*    05/14/07  RH   5.10d
     *      - Process PIRTRAN4 file for PUTSTG task transactions
520aA*    10/10/07  LMC  5.20a P#00023
     *      - Enh: Added purging to history files instead of just
     *        deleting the records.
     *        NOTE - if this is moved to client site, make sure
     *        positions 33-35 of opdata in options is initilized.
520bA*    05/13/08  GJA  5.20b P#00023
     *      - Enh: Added getting history option
     *      - Fix: Error flag was being set on when no PIRTRAN
     *        record was found and stop processing, needs to continue
520cA*    05/15/08  GJA  5.20c P#00023
     *      - Enh: Need to add LICINFO to the clean up and extended
     *        history function
520d *    12/11/08  GJA  5.20d
     *      - Enh: Move PUTSTG records to history along with license
     *        record
520e *    12/12/08  MLB  5.20e
     *      - Enh: Added p/o detail misc. file POHDTLM file to
     *        clean-up program.
520f *    12/19/08  GJA  5.20f
     *      - Fix: Corrected key field for PUTSTG records
     *        record
530a *    01/19/10  GJA  5.30a
     *      - Fix: added OPTBJQ option
640a *    12/16/11  RH   6.40a
     *      - Fix: LICINFOH rec name changed to LNHREC
640b *    01/04/12  LMC  6.40b
     *      - Fix: Added additional logic to cleanup LICINFO if no LICENSE
     *        record is found
     *      - Fix: Added logic to check for active license
640c *    01/11/12  LMC  6.40c
     *      - Enh: Added file POHHDRH for use in historical cleanup
640d *    01/18/12  LMC  6.40d
     *      - Fix: added logic to check to make sure liclog records
     *        don't exist before removing licinfo records
640e *    03/30/12  RBD  6.40e
     *      - Fix: only delete PUTSTG recs if group type 1 = P.
     *        Selection recs were getting deleted when a PO
     *        happened to match a route id.
640f *    06/13/12  LMC  6.40f
     *      - Fix: Added additional logic check to ensure we cleanup
     *        records asociated with the current export of the po.
     *        Problem existed that all data was being deleted for the
     *        PO, even if mutiple exported dates existed for the PO.
640g *    10/16/12  LMC  6.40g
     *      - NOTE: THIS MOD SHOULD ONLY BE APPLIED IF THE CLIENT HAS
     *        THE NEW LICINFO FILE. Key for licinfo1 has changed.
     *        LICINFO1 had lncode as a key field, and the field does not
     *        exist in the new file.
640h *    06/15/12  LMC  6.40h
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
640i *    10/29/12  LMC  6.40i
     *      - Enh: Do not execute subr ZZLABL & ZZSTAG if phhpo = ' '.
     *        This problem occured at European Imports and labels
     *        with blank po numbers were used to purged other files by
     *        mistake.
650a *    05/20/13  LMC  6.50a
     *      - Enh: Added cleanup for RCVPO transactions. No label will
     *        exist, so we will clean these up based on the PO#.
650b *    03/17/14  LMC  6.50b
     *      - Enh: Check for licactive records for the PO prior to
     *        doing any deletes. If any active licenses exist, no
     *        PO data will be deleted. Once the license is no longer
     *        active, the data will be eligible for cleanup.
700aA*    04/12/16  LMC  7.00a
     *      - Moved the move to populate $kwhse into the inzsr
     *        routine. If no records exist in the file, the cycle
     *        hits LR, and executes the wrttran log cleanup but sends
     *        warehouse 0. This causes a BFCWTD000 job to be started
     *        on the clients box.
710a *    05/24/17  GJA  7.10a
     *      - Fix: Add ISFLABEL to clean up list
710b *    07/10/17  LMC  7.10b
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
720a *    12/20/18  LMC  7.20a
     *      - Enh: Added POHDREXA to cleanup.
730a *    08/08/19  LMC  7.30a
     *      - Enh: Added UCIWORK to cleanup.
740a *    12/02/20  LMC  7.40a
     *      - Enh: Added UCIINFO to cleanup.
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
     *----------------------------------------------------------------
     * Indicators
     *
218 D*  79        - EOF for POH
218 M*  79        - EOF for POHHDR
     *
     *----------------------------------------------------------------
     * File Specs
     *
218 D*OH     UP  E           K        DISK
218 Mfpohhdr    up   e           k disk
510 Afpohhdrm   uf   e           k disk
218 D*OD     UF  E           K        DISK
218 Mfpohdtl    uf   e           k disk
520eAfpohdtlm   uf   e           k disk
406 Aflabel10   uf   e           k disk
406 Afpirtran   uf   e           k disk
406 Aflicense1  uf   e           k disk
640fDf*pomfr     uf   e           k disk
640fMfpomfr1    uf   e           k disk
415aAfporcv     uf   e           k disk
416BAflumper    uf   e           k disk
510bAfpohhaccp  uf   e           k disk
510dAFPIRTRAN4  UF   E           K DISK    rename(ptrec:ptrec4)
520aAFpirtranh  o  a e             disk    rename(ptrec:ptrech)
520aAFlabelh    o  a e             disk    rename(lbrec:lbrech)
520aAFlicenseh  o  a e             disk    rename(lirec:lirech)
520bAFoptions   if   e           k disk
520cAflicinfo2  uf   e           k disk
640aDF*icinfoh  o  a e             disk    rename(lnrec:lnrech)
640aMFlicinfoh  o  a e             disk    rename(lnhrec:lnrech)
640bAflicinfo1  if   e           k disk    rename(lnrec:lnrec1) prefix(a_)
640bAflicactive if   e           k disk
640bAflicactive6if   e           k disk    rename(larec:lareco) prefix(b_)
640dAfliclog    if   e           k disk
640dAfliclog1   if   e           k disk    rename(llrec:llrec1)
640cAfpohhdrh   o  a e             disk
710aAfisflabel  uf   e           k disk
720aAfpohdrexa  uf   e           k disk
730aAfuciwork1  uf   e           k disk
740aA*----------------------------------------------------------------
740aA*  DRI parameters
740aA*----------------------------------------------------------------

740aA /COPY *libl/qcopysrc,C#DRIPARMP
740aA /COPY *libl/qcopysrc,C#DRIPARMS

740aA*----------------------------------------------------------------
740aA*  Data Formats
740aA*----------------------------------------------------------------
740aA /COPY *libl/qcopysrc,C#UCIINFO
740aAD savever#        s                   like($uiver#)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     d desc            s             50    dim(1) ctdata perrcd(1)
640hA*----------------------------------------------------------------
640hA*  Prototypes
640hA*----------------------------------------------------------------
640hA
740aA /copy qcopysrc,p.driuci
640hAD wrttran1        pr                  extpgm('WRTTRAN1')
640hA * Input
640hAD   ppcmd                        8
640hAD   ppwait                       2  0
640hAD   ppwhse                       3  0
640hAD   pptran#                      7  0
640hAD   ppfromdate                   8  0
640hAD   pptodate                     8  0
640hAD   ppemp#                       5  0
520bA*----------------------------------------------------------------
520bA*  *SYSTEM  -  System options.
520bA*----------------------------------------------------------------
520bA*
520bA* Fields
520bA*
520bA*    OPEPM   -  Using EPM module (Y,N).
520bA*    OPRF    -  Using RF module (Y,N).
520bA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
520bA*    OPLETD  -  Print letdown labels (Y,N).
520bA*    OPWRNC  -  Perform catch weight variance check (Y,N).
520bA*    OPRG1C  -  Catch weight low variance percentage.
520bA*    OPRG2C  -  Catch weight high variance percentage.
520bA*    OPIMPI  -  Import Item fields (Y,N).
520bA*    OPICW   -  Individual catch weight entry (Y,N).
520bA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
520bA*    OPRCDY  -  Number of days to keep receiving logs.
520bA*    OPMPCK  -  Number of days to keep picking logs.
520bA*    OPRTHS  -  Number of weeks - exported routes to keep.
520bA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
520bA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
520bA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
520bA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
530aA*    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
520bA*    OPISHS  -  Number of weeks - extra history files to keep.
520bA*
520bA* Data structure
520bA*
520bAD opdata          ds
520bAD  opepm                  1      1
520bAD  oprf                   2      2
520bAD  opcapc                 3      3
520bAD  opletd                 4      4
520bAD  opwrnc                 5      5
520bAD  oprg1c                 6      8  1
520bAD  oprg2c                 9     11  1
520bAD  opimpi                12     12
520bAD  opicw                 13     13
520bAD  opmpck                14     14
520bAD  oprcdy                15     15  0
520bAD  oppkdy                16     16  0
520bAD  oprths                17     19  0
520bAD  opcrhs                20     22  0
520bAD  oppohs                23     25  0
520bAD  opiahs                26     28  0
520bAD  opmshs                29     31  0
530aAD  optbjq                32     32
520bAD  opishs                33     35  0
520bAD  optend               117    117
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     d $mdt            ds
     d  errmsg                 1     50
     *
     d  errecs                 1      3p 0
     d  erdesc                 4     48
     d                 ds
     d  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     d #msgf           c                   const('PIRMSGF   ')
     *
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
520bAd kycode          s                   like(opcode)
520bAd kywhse          s                   like(opwhse)
640gDd*kylicinfo1      s                   like(lncode)
640gAd*kylicinfotrn#   s                   like(lnvalue)
640bAd keylcns         s                   like(lilcns)
640hAD wrtpcmd         s             10
640hAD wrtpwait        s              2  0
640hAD wrtpwhse        s              3  0
640hAD wrtptran#       s                   like(pttrn#)
640hAD wrtpfrmdate     s              8  0
640hAD wrtptodate      s              8  0
640hAd wrtpemp#        s                   like(ptemp#)
740aA*----------------------------------------------------------------
740aA*  Called program flags
740aA*----------------------------------------------------------------

740aAD driUciCalled    s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      &PWHSE  - Warehouse
     *      &PDATE  - Export date
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     c     *entry        plist
     c                   parm                    $pprg            10
     c                   parm                    $pwhse            3
     c                   parm                    $pdate            8
700aDc*                  move      $pwhse        $kwhse            3 0
     c                   move      $pdate        $kdate            8 0
     *----------------------------------------------------------------
     * Main line
     *
     *  Although the following conditions are tested by open query
     *  in the preceding CL program, this is tested here again for
     *  additional safety.
     *
218 D*          PHWHSE    IFNE $KWHSE
218 Mc     phhwhs        ifne      $kwhse
218 D*          PHUDTE    ORGE $KDATE
218 Mc     phhedt        orge      $kdate
     c                   goto      bottom
     c                   endif
406 M*  Moved code to delete po detail records to subroutine.
650bA*
650bA*  before doing any deletes - make sure no active licenses
650bA*  exist for the po attempting to cleanup.
650bAc                   exsr      zzlicactive
650bAc     eflag         cabeq     *on           bottom
406 A*
406 A*  Delete exported purchase order detail records.
406 Ac                   exsr      zzpodt
406 Ac     eflag         cabeq     *on           bottom
520eA*
520eA*  Delete exported purchase order detail misc. records.
520eAc                   exsr      zzpodm
520eAc     eflag         cabeq     *on           bottom
406 A*
406 A*  Delete exported label records and transactions.
640iAc     phhpo         ifne      ' '
406 Ac                   exsr      zzlabl
640iAc                   endif
406 Ac     eflag         cabeq     *on           bottom
510dA *  Delete PUTSTG transactions.
640iAc     phhpo         ifne      ' '
510dAC                   exsr      ZZSTAG
640iAc                   endif
510dAC     EFLAG         CABEQ     *ON           BOTTOM
650aA *  Delete RCVPO transactions.
650aAc     phhpo         ifne      ' '
650aAC                   exsr      ZZRCVPO
650aAc                   endif
650aAC     EFLAG         CABEQ     *ON           BOTTOM
414bA*
414bA*  Delete P/O Mfr date information records.
640fa*  Moved to execute within zzlabl subr.
640fDc*                  exsr      zzmfr
640fDc*    eflag         cabeq     *on           bottom
415aA*
415aA*  Delete P/O Receiving information records.
415aAc                   exsr      zzrcv
415aAc     eflag         cabeq     *on           bottom
     *
416bA*
416bA*  Delete P/O Lumper information records.
416bAc                   exsr      zzlmpr
416bAc     eflag         cabeq     *on           bottom
     *
720aA*  Delete POHDREXA information records.
720aAc                   exsr      zzpohdrexa
730aA*  Delete UCIWORK Records.
730aAc                   exsr      zzuciwork
     *  Delete HACCP history record.
510bac     keyod         setll     pohhaccp
510bac     keyod         reade     pohhaccp
510bac                   dow       not %eof
640fAc                   if        hahedt >  phhedt
640fAc                   else
510bac                   delete    hahrec
640fAc                   endif
510bac     keyod         reade     pohhaccp
510bac                   enddo
     *
     *  Delete exported purchase order header record.
     *
     c                   add       1             errecs
218 D*                    DELETPHREC                  79
640cA * Only write history if additional history is set in options
640cAC                   if        opishs <> 0
640cAC                   write     phhrech
640cAC                   endif
218 Mc                   delete    phhrec                               79
510 A*
510 A*  Delete exported purchase order header misc. record.
510 A*
510 Ac     kyhmm         chain     pohhdrm                            79
510 Ac     *in79         ifeq      *off
510 Ac                   delete    phhmrc                               79
510 Ac                   endif
     *
     c     bottom        tag
     *
640hAclr                 exsr      ZZWRTTRANDLOG
     clr                 exsr      zm0750
740aAclr                 exsr      zzclose
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     c     *inzsr        begsr
     c* moved from mainline - if LR with no records $kwhse is 0
700aMc                   move      $pwhse        $kwhse            3 0
     c                   z-add     0             errecs
     c                   movel     desc(1)       erdesc
406 Ac                   move      *off          eflag             1
414aAc                   move      *off          forevr            1
     *
218 D*   Define partial key for POD file.
218 M*   Define partial key for POHDTL file.
     *
     c     keyod         klist
218 D*R                   KFLD           PHWHSE
218 Mc                   kfld                    phhwhs
218 D*R                   KFLD           PHPO
218 Mc                   kfld                    phhpo
510 A*
510 A*   Define partial key for POHHDRM file.
510 A*
510 Ac     kyhmm         klist
510 Ac                   kfld                    phhwhs
510 Ac                   kfld                    phhpo
510 Ac                   kfld                    phhedt
510 Ac                   kfld                    phheti
510 A*
406 A*   Define key for LICENSE file.
     *
406 Ac     keylcn        klist
406 Ac                   kfld                    lbwhse
406 Ac                   kfld                    lbtrn#
520eA*
520eA*   Define partial key for POHDTLM file.
520eA*
520eAc     kydmm         klist
520eAc                   kfld                    phhwhs
520eAc                   kfld                    phhpo
520eAc                   kfld                    phhedt
520eAc                   kfld                    phheti
520fA*
520fA*   Define key for LICENSE file.
520f *
520fAc     keystgl       klist
520fAc                   kfld                    ptwhse
520fAc                   kfld                    pttrn#
520cA*
520cA*   Define key for LICINFO file.
520cA*
520cAc     keyln         klist
520cAc                   kfld                    liwhse
520cAc                   kfld                    lilcns
640bA*   Define key for LICINFO file orphaned in licinfo not license
640bA*
640bAc     keylnorphan   klist
640bAc                   kfld                    a_lnwhse
640bAc                   kfld                    a_lnlcns
640bA*
640bA*   Define key for LICINFO1 file.
640bA*
640bAc     keylcninfo1   klist
640bAc                   kfld                    lbwhse
640gDc*                  kfld                    kylicinfo1
640gDc*                  kfld                    kylicinfotrn#
640gAc                   kfld                    lbtrn#
640bA*   Define key for LICACTIVE file.
640bA*
640bAc     keylicactive  klist
640bAc                   kfld                    lbwhse
640bAc                   kfld                    keylcns
     *
416bA*   Define key for LUMPER file.
416bA*
416bAc     keylm         klist
416bAc                   kfld                    phhwhs
416bAc                   kfld                    phhpo
510dAC*   Define key for PIRTRAN4 file.
510dACSR   KEYSTG        KLIST
510dACSR                 KFLD                    PHHWHS
510dACSR                 KFLD                    KYGRP2
510dACSR                 KFLD                    PHHPO
     *
520bA*
520bA*    Define full key for file OPTIONS.
520bA*
520bAC                   eval      kywhse = *zeros
520bAC                   eval      kycode = '*SYSTEM '
520bAC     keyop         klist
520bAC                   kfld                    kywhse
520bAC                   kfld                    kycode
520bA*
520bA*    Retrieve System options.
520bA*
520bAC     keyop         chain     options                            79
520bAC                   if        *in79
520bAC                   eval      opishs = 0
520bAC                   endif
     c                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     c     zmsmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid            7
     c                   parm                    #msgtp            7
     c                   parm                    #msgdt
     c                   parm      $pprg         #pgmq2           10
     c                   parm                    #msgk             4
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR0750  Records removed.
     *
     c     zm0750        begsr
     c                   move      'PIR0750'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   endsr
740aA*---------------------------------------------------------------
740aA*
740aA*    ZZCLOSE close dri programs called
740aA*
740aAC     zzclose       begsr
740aA /free
740aA    if driUCICalled;
740aA      driuciinfo('%CLOSE': $pprogram: $drireturn: $drimessage:
740aA               $dridata: $dridata2);
740aA    endif;
740aA
740aA /end-free
740aAC                   endsr
650bA*---------------------------------------------------------------
650bA*
650bA*    ZZlicactive    check for any acitve license for the PO
650bA*
650bAc     zzlicactive   begsr
650bA*
650bA /free
650bA   eflag = *off;
650bA   setll (phhwhs: phhpo) label10;
650bA   dow not %eof(label10);
650bA     reade(n) (phhwhs: phhpo) label10;
650bA     if not %eof(label10);
650bA       chain(n) (lbwhse: lbtrn#) license1;
650bA       if not %eof(license1);
650bA         // make sure license is not active in order to continue
650bA         chain (lbwhse: lilcns) licactive;
650bA         if %found(licactive);
650bA           eflag = *on;
650bA           leave;
650bA         endif;
650bA         chain (lbwhse: lilcns) licactive6;
650bA         if %found(licactive6);
650bA           eflag = *on;
650bA           leave;
650bA         endif;
650bA       endif;
650bA     endif;
650bA   enddo;
650bA /end-free
650bAc                   endsr
     *---------------------------------------------------------------
406 A*
406 A*    ZZLABL  Delete exported Label records for PO.
406 A*            Delete dependent PIRTRAN and LICENSE records for label.
406 A*
406 Ac     zzlabl        begsr
406 A*
406 Ac                   move      *off          eflag
414aD*          KEYOD     SETLLLABEL10              79
414aMc     keyod         setll     label10
414aD*                    MOVE *IN79     EOF
414aMc                   move      *off          eof
406 Ac     eof           doweq     *off
406 Ac     keyod         reade     label10                                79
406 Ac                   move      *in79         eof
406 Ac     *in79         ifeq      *off
640fA * check the report date, make sure it is <= the PO export date
640fAc                   if        lbrdte > phhedt
640fAc                   iter
640fAc                   endif
406 Ac     keylcn        chain     license1                           77
406 Ac     *in77         ifeq      *off
640bA * check to make sure license is not active before continuing
640bAc                   eval      keylcns = lilcns
640bAc     keylicactive  chain     licactive
640bAc                   if        %found(licactive)
640bAc                   eval      eflag = *on
640bAc                   leave
640bAc                   endif
640bAc     keylicactive  chain     licactive6
640bAc                   if        %found(licactive6)
640bAc                   eval      eflag = *on
640bAc                   leave
640bAc                   endif
640dA * if records exist in liclog, for either original or current license
640dA * don't remove licinfo at this time.
640dA * licinfo will be cleaned up when liclog file is ready to be removed.
640dAc     keylicactive  chain     liclog
640dAc     keylicactive  chain     liclog1
640dAc                   if        not %found(liclog ) and
640dAc                             not %found(liclog1)
414aMc     keyln         setll     licinfo2
520cAc     forevr        doweq     forevr
520cAc     keyln         reade     licinfo2                               78
520cAc     *in78         ifeq      *off
520cA * Only write history if additional history is set in options
520cAC                   if        opishs <> 0
520cAC                   write     lnrech
520cAC                   endif
520cAc                   delete    lnrec                                77
520cAc     *in77         ifeq      *on
520cAc                   move      *in77         eflag
520cAc                   endif
740aA /free
740aA   if opishs = 0;
740aA     exsr zzuci;
740aA   endif;
740aA /end-free
520cAc                   else
520cAc                   leave
520cAc                   endif
520cAc                   enddo
640dAc                   endif
520aA * Only write history if additional history is set in options
520aAC                   if        opishs <> 0
520aAC                   write     lirech
520aAC                   endif
406 Ac                   delete    lirec                                77
414aAc     *in77         ifeq      *on
406 Ac                   move      *in77         eflag
414aAc                   endif
640bAc                   else
640bA * if no license record is found check the licinfo1 file for
640bA * license info code *RCVTRN# move to history if license is no
640bA * longer active
640gDc*                  eval      kylicinfo1 = '*RCVTRN#'
640gDC*                  eval      kylicinfotrn# =   %char(lbtrn#)
640bAc     keylcninfo1   chain     licinfo1
640bAc                   if        %found(licinfo1)
640bA * check for active license - if active don't delete
640bAc                   eval      keylcns = a_lnlcns
640bAc     keylicactive  chain     licactive
640bAc     keylicactive  chain     licactive6
640bAc                   if        not %found(licactive)   and
640bAc                             not %found(licactive6)
640bAc                   eval      *in76 = *off
640dAC     keylicactive  chain     liclog
640dAC     keylicactive  chain     liclog1
640dAc                   if        not %found(liclog)  and
640dAc                             not %found(liclog1)
640bAc     keylnorphan   setll     licinfo2
640bAc     forevr        doweq     forevr
640bAc     keylnorphan   reade     licinfo2                               76
640bAc     *in76         ifeq      *on
640bAc                   leave
640bAc                   endif
640bAc     *in76         ifeq      *off
640bA * Only write history if additional history is set in options
640bAC                   if        opishs <> 0
640bAC                   write     lnrech
640bAC                   endif
640bAc                   delete    lnrec                                77
640bAc     *in77         ifeq      *on
640bAc                   move      *in77         eflag
640bAc                   endif
740aA /free
740aA   if opishs = 0;
740aA     exsr zzuci;
740aA   endif;
740aA /end-free
640bAc                   endif
640bAc                   enddo
640dAc                   endif
640bAc                   else
640bAc                   eval      eflag = *on
640bAc                   endif
640bAc                   endif
406 Ac                   endif
406 Ac     eflag         cabeq     *on           endlb
414aAc     lbtrn#        setll     pirtran
406 D*          LBTRN#    CHAINPIRTRAN              77
414aAc     forevr        doweq     forevr
414aMc     lbtrn#        reade     pirtran                                77
406 Ac     *in77         ifeq      *off
520aA * Only write history if additional history is set in options
520aAC                   if        opishs <> 0
520aAC                   write     ptrech
520aAC                   endif
406 Ac                   delete    ptrec                                77
      * This is only executed if no extended history is kept
640hAc                   if        opishs = 0
640hAc                   exsr      zzwrttrand
640hAc                   endif
414aAc     *in77         ifeq      *on
406 Ac                   move      *in77         eflag
414aAc                   endif
414aAc                   else
414aAc                   leave
406 Ac                   endif
414aAc                   enddo
406 Ac     eflag         cabeq     *on           endlb
640fA*
640fA*  Delete P/O Mfr date information records.
640fMc                   exsr      zzmfr
640fAc     eflag         cabeq     *on           endlb
710aA*  Delete ISFLABEL information records.
710aAc                   exsr      zzisflbl
710aAc     eflag         cabeq     *on           endlb
710aA*
520aA * Only write history if additional history is set in options
520aAC                   if        opishs <> 0
520aAC                   write     lbrech
520aAC                   endif
406 Ac                   delete    lbrec                                78
414aAc     *in78         ifeq      *on
406 Ac                   move      *in78         eflag
414aAc                   endif
406 Ac                   endif
406 Ac                   enddo
406 Ac     endlb         endsr
406 A*
414bA*---------------------------------------------------------------
414bA*
414bA*    ZZMFR   Delete P/O Mfr date information records.
414bA*
414bAc     zzmfr         begsr
414bA*
414bA*  Delete P/O Mfr date information records.
414bA*
640fdc*    keyod         setll     pomfr
640fMc     lblbl#        setll     pomfr1
414bAc                   move      *off          eof               1
414bAc     eof           doweq     *off
640fDc*    keyod         reade     pomfr                                  79
640fMc     lblbl#        reade     pomfr1                                 79
414bAc                   move      *in79         eof
414bAc     *in79         ifeq      *off
414bAc                   delete    pmrec                                78
414bAc     *in78         ifeq      *on
414bAc                   move      *in78         eflag
414bAc                   endif
414bAc                   endif
414bAc                   enddo
640fAc                   eval      eof = '0'
710aAc                   endsr
710aA*---------------------------------------------------------------
710aA*
710aA*  ZZISFLBL  Delete ISFLABEL information records.
710aA*
     c     zzisflbl      begsr
     *
     *  Delete ISFLABEL information records.
     *
     c     lblbl#        setll     isflabel
     c                   move      *off          eof               1
     c     eof           doweq     *off
     c     lblbl#        reade     isflabel                               79
     c                   move      *in79         eof
     c     *in79         ifeq      *off
     c                   delete    lfrec                                78
     c     *in78         ifeq      *on
     c                   move      *in78         eflag
     c                   endif
     c                   endif
     c                   enddo
     c                   eval      eof = '0'
     c                   endsr
     *---------------------------------------------------------------
406 A*
406 A*    ZZPODT  Delete exported purchase order detail records.
406 A*
406 Ac     zzpodt        begsr
406 A*
406 A*  Delete exported purchase order detail records.
406 A*
406 Ac                   move      *off          eflag
218 D*          KEYOD     SETLLPOD                  79
414aD*          KEYOD     SETLLPOHDTL               79
414aMc     keyod         setll     pohdtl
414aD*                    MOVE *IN79     EOF     1
414aMc                   move      *off          eof               1
406 Mc     eof           doweq     *off
218 D*          KEYOD     READEPOD                      79
406 Mc     keyod         reade     pohdtl                                 79
406 Mc                   move      *in79         eof
406 Mc     *in79         ifeq      *off
218 D*                    DELETPDREC                  78
640fA * check to make sure this detail matches the header export date
640fAc                   if        phdedt <= phhedt
218 Mc                   delete    phdrec                               78
414aAc     *in78         ifeq      *on
406 Ac                   move      *in78         eflag
414aAc                   endif
640fAc                   endif
406 Mc                   endif
406 Mc                   enddo
406 Ac                   endsr
520eA*
520eA*---------------------------------------------------------------
520eA*
520eA*    ZZPODM  Delete exported purchase order detail misc. records.
520eA*
520eAc     zzpodm        begsr
520eA*
520eA*  Delete exported purchase order detail misc. records.
520eA*
520eAc                   move      *off          eflag
520eAc     kydmm         setll     pohdtlm
520eAc                   move      *off          eof               1
520eAc     eof           doweq     *off
520eAc     kydmm         reade     pohdtlm                                79
520eAc                   move      *in79         eof
520eAc     *in79         ifeq      *off
520eAc                   delete    phdmrc                               78
520eAc     *in78         ifeq      *on
520eAc                   move      *in78         eflag
520eAc                   endif
520eAc                   endif
520eAc                   enddo
520eAc                   endsr
415aA*
415aA*
415aA*---------------------------------------------------------------
415aA*
415aA*    ZZRCV   Delete P/O Receiving information records.
415aA*
415aAc     zzrcv         begsr
415aA*
415aA*  Delete P/O Mfr date information records.
415aA*
415aAc     keyod         setll     porcv
415aAc                   move      *off          eof               1
415aAc     eof           doweq     *off
415aAc     keyod         reade     porcv                                  79
415aAc                   move      *in79         eof
415aAc     *in79         ifeq      *off
415aAc     pordte        andlt     $kdate
415aAc                   delete    porrec                               78
415aAc     *in78         ifeq      *on
415aAc                   move      *in78         eflag
415aAc                   endif
415aAc                   endif
415aAc                   enddo
415aAc                   endsr
650aAC*---------------------------------------------------------------
650aAC*
650aAC*    ZZRCVPO Delete RCVPO transactions for PO.
650aAC*
650aA /free
650aA    begsr zzrcvpo;
650aA      kygrp2 = ' ';
650aA      eflag = *off;
650aA      setll (phhwhs: kygrp2: phhpo) pirtran4;
650aA      dow not %eof(pirtran4);
650aA        reade (phhwhs: kygrp2: phhpo) pirtran4;
650aA        if %eof(pirtran4);
650aA          leave;
650aA        endif;
650aA        if ptgrp1 <> 'P';
650aA          leave;
650aA        endif;
650aA        if ptgdte > phhedt;
650aA          iter;
650aA        endif;
650aA        if pttask <> 'RCVPO';
650aA          iter;
650aA        endif;
650aA        if opishs <> 0;
650aA          write ptrech;
650aA        endif;
650aA        delete PTREC4;
650aA        if %error;
650aA          eflag = *on;
650aA          leave;
650aA        endif;
650aA        // This is only executed if no extended history is kept
650aA        if opishs = 0;
650aA          exsr zzwrttrand;
650aA        endif;
650aA      enddo;
650aA    endsr;
650aA /end-free
650aA
510d C*---------------------------------------------------------------
510dAC*
510dAC*    ZZSTAG  Delete PUTSTG transactions for PO.
406 AC*
510dACSR   ZZSTAG        BEGSR
510dAC*
510dAC                   MOVE      *BLANKS       KYGRP2            1
510dAC                   MOVE      *OFF          eof
510dACSR   KEYSTG        SETLL     PIRTRAN4
510dACSR                 MOVE      *OFF          EFLAG
510dAC     eof           DOWEQ     *OFF
510dAC     KEYSTG        READE     PIRTRAN4                               77
510dAC                   MOVE      *IN77         eof
520bDC*                  MOVE      *IN77         EFLAG
510dAC     *IN77         IFEQ      *OFF
640eAC     PTGRP1        ANDEQ     'P'
640fA * check the dates to see if generated date <= po export date
640fAc                   if        ptgdte > phhedt
640fAc                   iter
640fAc                   endif
520dDC*    KEYLCN        CHAIN     LICENSE1                           78
520fAC     KEYSTGL       CHAIN     LICENSE1                           78
520dAC     *IN78         IFEQ      *OFF
640fA * check to make sure license is not active before continuing
640fAc                   eval      keylcns = lilcns
640fAc     keylicactive  chain     licactive
640fAc                   if        %found(licactive)
640fAc                   eval      eflag = *on
640fAc                   leave
640fAc                   endif
640fAc     keylicactive  chain     licactive6
640fAc                   if        %found(licactive6)
640fAc                   eval      eflag = *on
640fAc                   leave
640fAc                   endif
520dAC                   if        opishs <> 0
520dAC                   write     lirech
520dAC                   endif
520dAC                   delete    lirec                                77
520dAC                   endif
520dAC                   if        opishs <> 0
520dAC                   write     ptrech                               77
520dAC                   endif
510dAC                   delete    PTREC4                               77
      * This is only executed if no extended history is kept
640hAc                   if        opishs = 0
640hAc                   exsr      zzwrttrand
640hAc                   endif
510dACSR   *IN77         IFEQ      *ON
510dAC                   MOVE      *IN77         EFLAG
510dACSR                 ENDIF
510dACSR                 ELSE
510dACSR                 LEAVE
510dAC                   ENDIF
510dAC                   ENDDO
510dACSR                 ENDSR

     *---------------------------------------------------------------
     *
416bA*    ZZLMPR  Delete P/O Lumper information records.
     *
416bAc     zzlmpr        begsr
     *
     c                   move      *off          eflag
640fAc     keylm         setll     lumper                             79
640fDc*    keylm         chain     lumper                             79
640fAc     *in79         doweq     *off
640fMc     keylm         reade     lumper                                 79
     c     *in79         ifeq      *off
640fAc                   if        lmhedt > phhedt
640fAc                   iter
640fAc                   endif
     c                   delete    lmrec                                78
     c     *in78         ifeq      *on
     c                   move      *in78         eflag
     c                   endif
     c                   endif
640fAc                   enddo
416bAc                   endsr
720aA*---------------------------------------------------------------
720aA*
720aA*    ZZPOHDREXA Delete POHDREXA information records.
     *
720aAc     zzpohdrexa    begsr
     *
720aAc                   move      *off          eflag
720aAc     keylm         setll     pohdrexa                           79
720aAc     *in79         doweq     *off
720aAc     keylm         reade     pohdrexa                               79
720aAc     *in79         ifeq      *off
720aAc                   delete    pharec                               78
720aAc     *in78         ifeq      *on
720aAc                   move      *in78         eflag
720aAc                   endif
720aAc                   endif
720aAc                   enddo
720aAc                   endsr
740aA*---------------------------------------------------------------
740aA*
740aA*    ZZUCI   Delete uci records for license received.
740aA*
740aAC     zzuci         begsr
740aA*
740aA  /free
740aA        clear $uciinfo;
740aA        clear $uciinfo2;
740aA        $uiver# = savever#;

740aA        $uiwhse = lnwhse;
740aA        $uilcns = lnlcns;
740aA        $uicrtby = '7';

740aA        $dridata = $uciinfo;
740aA        $dridata2 = $uciinfo2;
740aA        driUCICalled = *on;
740aA        driuciinfo('%CLEANUP2': $pprogram: $drireturn:
740aA                 $drimessage: $dridata: $dridata2);
740aA  /end-free
740aAC                   endsr
730aA*---------------------------------------------------------------
730aA*
730aA*    ZZUCIWORK  Delete UCIWORK records.
     *
730aAc     zzuciwork     begsr
     *
730aAc                   move      *off          eflag
730aAc     keylm         setll     uciwork1                           79
730aAc     *in79         doweq     *off
730aAc     keylm         reade     uciwork1                               79
730aAc     *in79         ifeq      *off
730aAc                   delete    uiwrec                               78
730aAc     *in78         ifeq      *on
730aAc                   move      *in78         eflag
730aAc                   endif
730aAc                   endif
730aAc                   enddo
730aAc                   endsr
640hA*----------------------------------------------------------------*********
640hA*
640hA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640hA*
640hA /free
640hA   begsr zzwrttrand;
640hA     wrtpcmd = '*CLEANUP';
640hA     wrtpwait = 0;
640hA     wrtpwhse = ptwhse;
640hA     wrtptran# = pttrn#;
710bD     //wrtpfrmdate = 0;
710bM     wrtpfrmdate = ptgdte;
640hA     wrtptodate = 0;
640hA     wrtpemp# = 0;
640hA
640hA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640hA               wrtpfrmdate: wrtptodate: wrtpemp#);
640hA   endsr;
640hA /end-free
640hA*----------------------------------------------------------------*********
640hA*
640hA*  ZZWRTTRANDLOG Execute new WRTTRAN1 program to cleanup LOGTRAND
640hA*
640hA /free
640hA   begsr zzwrttrandlog;
640hA     wrtpcmd = '*CLEANLOG';
640hA     wrtpwait = 0;
640hA     wrtpwhse = $Kwhse;
640hA     wrtptran# = 0;
640hA     wrtpfrmdate = 0;
640hA     wrtptodate = 0;
640hA     wrtpemp# = 0;
640hA
640hA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640hA               wrtpfrmdate: wrtptodate: wrtpemp#);
640hA   endsr;
640hA /end-free
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
exported purchase orders
