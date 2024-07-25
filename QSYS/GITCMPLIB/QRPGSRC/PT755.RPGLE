     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT755     Remove closed transactions/labels - Post
     *  11 November, 1994
     *  Dave Sommerville
     *
     *    01/24/96  DAS  2.10
     *      - Revised to use EPM version of PIRTRAN file.
     *      - Revised to use closed date instead of end date.
     *
406 A*    10/01/97  DAS  4.06
     *      - Revised to work with new LABEL5 key.
     *
417 A*    06/09/04  MLB  4.17
     *      - Enh: Revised program to remove entries from POMFR
     *        when processing customer return labels/transactions.
500aA*    12/22/05  RLP  5.00a
     *      - Fix: Added ZZLIC routine to remove any entries from
     *        LICENSE for customer return labels/transactions.
510aA*    09/16/06  RH   5.10a
     *      - Fix: 5.00a was missed in V5.00 update.
520aA*    10/10/07  LMC  5.20a P#00023
     *      - Enh: Added purging to history files instead of just
     *             deleting the records
     *             NOTE - if this is moved to client site, make sure
     *             positions 33-35 of opdata in options is initilized.
520bA*    05/13/08  GJA  5.20b P#00023
     *      - Enh: Added options for extended history
520cA*    05/15/08  GJA  5.20c P#00023
     *      - Enh: Need to add LICINFO to the clean up and extended
     *        history function
530a *    01/19/10  GJA  5.30a
     *      - Fix: Add missing option OPTBJQ
640a *    12/16/11  RH   6.40a
     *      - Fix: LICINFOH rec name changed to LNHREC
640b *    01/05/12  LMC  6.40b
     *      - Fix: Added additional logic to cleanup LICINFO if no LICENSE
     *        record is found
     *      - Fix: Added logic to check for active license in either
     *        current or original license field.
     *      - Fix: moved zzlic and zzmfr into chktrn routine this
     *        is now conditioned on a no match in the licactive file
640c *    01/18/12  LMC  6.40c
     *      - Fix: added logic to check to make sure liclog records
     *        don't exist before removing licinfo records
640d *    10/16/12  LMC  6.40d
     *      - NOTE: THIS MOD SHOULD ONLY BE APPLIED IF THE CLIENT HAS
     *        THE NEW LICINFO FILE. Key for licinfo1 has changed.
     *        LICINFO1 had lncode as a key field, and the field does not
     *        exist in the new file.
640eA*    06/18/12  LMC  6.40e
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
700aA*    04/12/16  LMC  7.00a
     *      - Moved the move to populate $kwhse into the inzsr
     *        routine. If no records exist in the file, the cycle
     *        hits LR, and executes the wrttran log cleanup but sends
     *        warehouse 0. This causes a BFCWTD000 job to be started
     *        on the clients box.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
     *
730aA*    10/15/19  DAS  7.30a
     *      - Revised to use PIRTRANW
     *      - Didn't need to use LABELW beacause this is called from
     *        a CL program where OPNQRYF selects based on LBWHSE.
     *----------------------------------------------------------------
     * Indicators
     *
     *  49        - Error trying to delete a record.
     *  79        - Record not found or EOF.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     FLabel     up   e           k disk
500aAFLicense1  uf   e           k disk
730aDF*irtran   uf   e           k disk
730aMFpirtranw  uf   e           k disk
417 AFpomfr1    uf   e           k disk
     FLabel5    if   e           k disk
520aAFLicenseh  o  a e             disk
     F                                     rename(lirec:lirech)
520aAFpirtranh  o  a e             disk
     F                                     rename(ptrec:ptrech)
520aAFLabelh    o  a e             disk
     F                                     rename(lbrec:lbrech)
520bAFoptions   if   e           k disk
520cAflicinfo2  uf   e           k disk
640aDF*icinfoh  o  a e             disk    rename(lnrec:lnrech)
640aMFlicinfoh  o  a e             disk    rename(lnhrec:lnrech)
640bAFlicactive if   e           k disk
640bAflicactive6if   e           k disk    rename(larec:lareco) prefix(b_)
640cAfliclog    if   e           k disk
640cAfliclog1   if   e           k disk    rename(llrec:llrec1)
640bAflicinfo1  if   e           k disk    rename(lnrec:lnrec1) prefix(a_)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  ertcnt                 1      8p 0
     D  erlcnt                 9     16p 0
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
640eA*----------------------------------------------------------------
640eA*  Prototypes
640eA*----------------------------------------------------------------
640eA
640eAD wrttran1        pr                  extpgm('WRTTRAN1')
640eA * Input
640eAD   ppcmd                        8
640eAD   ppwait                       2  0
640eAD   ppwhse                       3  0
640eAD   pptran#                      7  0
640eAD   ppfromdate                   8  0
640eAD   pptodate                     8  0
640eAD   ppemp#                       5  0
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
     *-----VARIABLES--------------------------------------------------
     D $kdate          s              8  0
     D $kwhse          s              3  0
     D $msgf           s             10
     D delete          s              1
     D forevr          s              1
     D opnlbl          s              1
520bAd kycode          s                   like(opcode)
520bAd kywhse          s                   like(opwhse)
640dDd*kylicinfo1      s                   like(lncode)
640dDd*kylicinfotrn#   s                   like(lnvalue)
640bAd activelicense   s              1
640bAd foundlicense    s              1
640bAd keylcns         s                   like(lilcns)
640eAD wrtpcmd         s             10
640eAD wrtpwait        s              2  0
640eAD wrtpwhse        s              3  0
640eAD wrtptran#       s                   like(pttrn#)
640eAD wrtpfrmdate     s              8  0
640eAD wrtptodate      s              8  0
640eAd wrtpemp#        s                   like(ptemp#)
     *----------------------------------------------------------------
     ILbrec
     I                                          lbtrn#        l1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      $PWHSE  - Warehouse
     *      $PDATE  - Export date
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8
700aDC*                  move      $pwhse        $kwhse
     C                   move      $pdate        $kdate
     *----------------------------------------------------------------
     * Main line
     *
     * Check to see if we can delete this transaction.
     *
     C   l1              eval      delete = *off
     C   l1              exsr      chktrn
     *
     * Delete label record for transaction.
     *
     C                   if        delete = *on
     C                   add       1             erlcnt
520aA* ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
520aAC                   if        OPISHS <> 0
520aAC                   write     lbrech
520aAC                   endif
     C                   delete    lbrec                                49
417 A*
417 A*    Remove matching records for customer returns only.
640bA*    This code was moved to the chktrn subr
640bDC*                  if        pttask = 'PUTRTN'
640bDC*                  exsr      zzlic
640bDC*                  exsr      zzmfr
640bDC*                  endif
417 A*
     C                   endif
     *
640eACLR                 exsr      zzwrttrandlog
     CLr                 exsr      zm10
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
     *   Define full key for LABEL5 file.
     *
     C     keyl5         klist
     C                   kfld                    lbwhse
406 AC                   kfld                    lbgrp2
     C                   kfld                    lbrte
     C                   kfld                    lbpo
     C                   kfld                    lbpbat
     C                   kfld                    lbtrn#
     *
     C     keyl5p        klist
     C                   kfld                    lbwhse
406 AC                   kfld                    lbgrp2
     C                   kfld                    lbrte
     C                   kfld                    lbpo
     C                   kfld                    lbpbat
500aA*
500aA*   Define key for LICENSE1 file.
500aA*
500aAC     keylic        klist
500aAC                   kfld                    lbwhse
500aAC                   kfld                    lbtrn#
     *
     c* moved from mainline - if LR with no records $kwhse is 0
700aMC                   move      $pwhse        $kwhse
     C                   eval      ertcnt = 0
     C                   eval      erlcnt = 0
417 AC                   eval      forevr = *on
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
520cA*
520cA*   Define key for LICINFO file.
520cA*
520cAc     keyln         klist
520cAc                   kfld                    liwhse
520cAc                   kfld                    lilcns
640bA*
640bAc     keylcninfo1   klist
640bAc                   kfld                    lbwhse
640dDc*                  kfld                    kylicinfo1
640dDc*                  kfld                    kylicinfotrn#
640dAc                   kfld                    lbtrn#
640bA*   Define key for LICACTIVE file.
640bA*
640bAc     keylicactive  klist
640bAc                   kfld                    lbwhse
640bAc                   kfld                    keylcns
640bA*   Define key for LICINFO file orphaned in licinfo not license
640bA*
640bAc     keylnorphan   klist
640bAc                   kfld                    a_lnwhse
640bAc                   kfld                    a_lnlcns
     C                   endsr
640bA*----------------------------------------------------------------
640bA*
640bA*  chkactlicense  check for active licenses.
640bA*
640bAC     chkactlicense begsr
640bA*  check to make sure license is not active
640bAc                   eval      foundlicense = *off
640bA*  get the license number for the lbtrn# check license file first
640bA*  if not found in license file check licinfo file for orphans
640bAC     keylic        chain(n)  license1
640bAc                   if        %found(license1)
640bAc                   eval      foundlicense = *on
640bAc                   eval      keylcns = lilcns
640bAc                   endif
640bA
640bAc                   if        foundlicense = *off
640dDc*                  eval      kylicinfo1 = '*RCVTRN#'
640dDC*                  eval      kylicinfotrn# =   %char(lbtrn#)
640bAc     keylcninfo1   chain     licinfo1
640bAc                   if        %found(licinfo1)
640bAc                   eval      foundlicense = *on
640bAc                   eval      keylcns = a_lnlcns
640bAc                   endif
640bAc                   endif
640bA
640bAc                   if        foundlicense = *on
640bAc     keylicactive  chain     licactive
640bAc                   if        %found(licactive)
640bac                   eval      activelicense = *on
640bAc                   endif
640bAc     keylicactive  chain     licactive6
640bAc                   if        %found(licactive6)
640bac                   eval      activelicense = *on
640bAc                   endif
640bAc                   endif
640bAC                   endsr
     *----------------------------------------------------------------
     *
     *  CHKTRN  Check transaction to see if it should be deleted.
     *
     C     chktrn        begsr
     *
     *
     *  Delete transaction if all of the following are true:
     *
210eD*     - End date is older than user entered date.
210eD*     - End date is not 0.
210eM*     - Closed date is older than user entered date.
210eM*     - Closed date is not 0.
     *     - All labels are closed for the transaction.
     *
     *     Get transaction record. If it doesn't exist set the date
     *     to negative 1 so that the label records can still be
     *     deleted. Of course, the transaction record always exist.
     *
730aDC**   lbtrn#        chain     pirtran                            79
730aDC**                 if        *in79
730aM /free
730aM                    chain (lbwhse: lbtrn#) pirtranw;
730aM /end-free
730aMC                   if        not %found(pirtranw)
210eD*                    Z-SUB1         PTEDTE
210eMC                   eval      ptcdte = -(1)
417 AC                   eval      pttask = *blanks
     C                   endif
640bA*    check for active license
640bAc                   eval      activelicense = *off
640bAC                   if        pttask = 'PUTRTN'
640bAC                   exsr      chkactlicense
640bAC                   endif
640bA*
     *
     *     Check for open label records. If the label is not a
     *     picking label (has a route number) or a receiving label
     *     (has a p.o. number) then use the entire key other wise
     *     search with a partial key.
     *
     C                   if        lbrte = *blanks  and
     C                             lbpo = *blanks
     C     keyl5         setll     label5                                 50
     C                   else
     C     keyl5p        setll     label5                                 50
     C                   endif
     C                   move      *in50         opnlbl
     *
     *     Now do actual check to see if we should delete transaction.
     *
210eD*          PTEDTE    IFLT $KDATE
210eD*          PTEDTE    ANDNE0
210eMC                   if        ptcdte < $kdate  and
210eMC                             ptcdte <> 0  and
640bAc                             activelicense = *off  and
     C                             opnlbl = *off
     C                   eval      delete = *on
     C                   if        not *in79
     C                   add       1             ertcnt
520aA* ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
520aAC                   if        OPISHS <> 0
520aAC                   write     ptrech
520aAC                   endif
730aMC                   delete    pirtranw                             49
640eA * This is only executed if no extended history is kept
640eAc                   if        opishs = 0
640eAc                   exsr      zzwrttrand
640eAc                   endif
640bA*
640bA*    Remove matching records for customer returns only.
640bA*    This code was moved from the mainline so it only executes
640bA*    When the license is no longer active
640bAC                   if        pttask = 'PUTRTN'
640bAC                   exsr      zzlic
640bAC                   exsr      zzmfr
640bAC                   endif
     C                   endif
     C                   endif
     *
     C                   endsr
500aA*----------------------------------------------------------------
500aA*
500aA*  ZZLIC   Remove matching LICENSE records for PUTRTN task.
500aA*
500aAC     zzlic         begsr
500aA*
640bDC*    keylic        setll     license1
640bDC*                  dow       forevr = forevr
640bDC*    keylic        reade     license1                               77
640bMC     keylic        chain     license1
500aAC                   select
640bDC*                  when      *in77
640bDC*                  leave
500aA*
640bDC*                  when      not *in77
640bMc                   when      %found(license1)
640cAc     keyln         chain     liclog
640cAc     keyln         chain     liclog1
640cAc                   if        not %found(liclog)  and
640cAc                             not %found(liclog1)
500aAC     keyln         setll     licinfo2
520cAc     *in74         doweq     *off
520cAc     keyln         reade     licinfo2                               74
520cAc                   if        not *in74
520cA * Only write history if additional history is set in options
520cAC                   if        opishs <> 0
520cAC                   write     lnrech
520cAC                   endif
520cAc                   delete    lnrec                                73
520cAc                   endif
520cAc                   enddo
640cAc                   endif
520aA* ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
520aAC                   if        OPISHS <> 0
520aAC                   write     lirech
520aAC                   endif
500aAC                   delete    lirec                                78
640bAc
640bAc                   when      not %found(license1)
640bA * if no license record is found check the licinfo1 file for
640bA * license info code *RCVTRN# move to history if license is no
640bA * longer active
640dDc*                  eval      kylicinfo1 = '*RCVTRN#'
640dDC*                  eval      kylicinfotrn# =   %char(lbtrn#)
640bAc     keylcninfo1   chain     licinfo1
640bAc                   if        %found(licinfo1)
640bAc                   eval      *in76 = *off
640cAc     keylnorphan   chain     liclog
640cAc     keylnorphan   chain     liclog1
640cAc                   if        not %found(liclog) and
640cAc                             not %found(liclog1)
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
640bAc                   endif
640bAc                   enddo
640cAc                   endif
640bAc                   endif
500aAC                   endsl
500aA*
640bDC*                  enddo
500aA*
500aAC                   endsr
500aA*
417 A*----------------------------------------------------------------
417 A*
417 A*  ZZMFR   Remove matching POMFR records for PUTRTN task.
417 A*
417 AC     zzmfr         begsr
417 A*
417 AC     lblbl#        setll     pomfr1
417 AC                   dow       forevr = forevr
417 AC     lblbl#        reade     pomfr1                                 76
417 AC                   select
417 AC                   when      *in76
417 AC                   leave
417 A*
417 AC                   when      not *in76  and
417 AC                             pmpo = *blanks  and
417 AC                             lbpo = *blanks  and
417 AC                             pmitem = lbitem
417 AC                   delete    pmrec                                75
417 AC                   endsl
417 A*
417 AC                   enddo
417 A*
417 AC                   endsr
417 A*
640eA*----------------------------------------------------------------*********
640eA*
640eA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640eA*
640eA /free
640eA   begsr zzwrttrand;
640eA     wrtpcmd = '*CLEANUP';
640eA     wrtpwait = 0;
640eA     wrtpwhse = ptwhse;
640eA     wrtptran# = pttrn#;
710aD     //wrtpfrmdate = 0;
710aM     wrtpfrmdate = ptgdte;
640eA     wrtptodate = 0;
640eA     wrtpemp# = 0;
640eA
640eA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640eA               wrtpfrmdate: wrtptodate: wrtpemp#);
640eA   endsr;
640eA /end-free
640eA*----------------------------------------------------------------*********
640eA*
640eA*  ZZWRTTRANDLOG Execute new WRTTRAN1 program to cleanup LOGTRAND
640eA*
640eA /free
640eA   begsr zzwrttrandlog;
640eA     wrtpcmd = '*CLEANLOG';
640eA     wrtpwait = 0;
640eA     wrtpwhse = $kwhse;
640eA     wrtptran# = 0;
640eA     wrtpfrmdate = 0;
640eA     wrtptodate = 0;
640eA     wrtpemp# = 0;
640eA
640eA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640eA               wrtpfrmdate: wrtptodate: wrtpemp#);
640eA   endsr;
640eA /end-free
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PT75010  Transaction and labels removed.
     *
     C     zm10          begsr
     C                   eval      #msgid = 'PT75010'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   endsr
