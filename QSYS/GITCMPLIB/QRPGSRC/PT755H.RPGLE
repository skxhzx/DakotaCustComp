     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT755H    Remove history transactions/labels - Post
     *  12 January, 2012
     *  Lynn McMahon
     *
     *    01/12/12  LMC  6.40
     *      - created - copied from PT755 process history files
     *        in place of original files
640a *    01/20/12  LMC  6.40a
     *      - Fix: added logic to check to make sure liclog records
     *        don't exist before removing licinfo records
640b *    10/16/12  LMC  6.40b
     *      - NOTE: THIS MOD SHOULD ONLY BE APPLIED IF THE CLIENT HAS
     *        THE NEW LICINFOH FILE. Key for licinfo1 has changed.
     *        LICINFOH1 had lncode as a key field, and the field does
     *        not exist in the new file.
640cA*    06/18/12  LMC  6.40c
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
     *
730aA*    10/15/19  DAS  7.30a
     *      - Revised to use PIRTRANHW
     *      - Didn't need to use LABELHW beacause this is called from
     *        a CL program where OPNQRYF selects based on LBWHSE.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  49        - Error trying to delete a record.
     *  79        - Record not found or EOF.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     FLabelH    up   e           k disk
     FLicenseh1 uf   e           k disk
730aDF*irtranh  uf   e           k disk
730aMFpirtranhw uf   e           k disk
     Foptions   if   e           k disk
     flicinfoh2 uf   e           k disk
     flicinfoh1 if   e           k disk    rename(lnhrec:lnrec1) prefix(a_)
640aAfliclogh   if   e           k disk
640aAfliclogh1  if   e           k disk    rename(llhrec:llrec1)
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
640cA*----------------------------------------------------------------
640cA*  Prototypes
640cA*----------------------------------------------------------------
640cA
640cAD wrttran1        pr                  extpgm('WRTTRAN1')
640cA * Input
640cAD   ppcmd                        8
640cAD   ppwait                       2  0
640cAD   ppwhse                       3  0
640cAD   pptran#                      7  0
640cAD   ppfromdate                   8  0
640cAD   pptodate                     8  0
640cAD   ppemp#                       5  0
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import Item fields (Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
     *    OPISHS  -  Number of weeks - extra history files to keep.
     *
     * Data structure
     *
     D opdata          ds
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
     D  optend               117    117
     *-----VARIABLES--------------------------------------------------
     D $kdate          s              8  0
     D $kwhse          s              3  0
     D $msgf           s             10
     D delete          s              1
     D forevr          s              1
     D opnlbl          s              1
     d kycode          s                   like(opcode)
     d kywhse          s                   like(opwhse)
640bDd*kylicinfo1      s                   like(lncode)
640bDd*kylicinfotrn#   s                   like(lnvalue)
     d foundlicense    s              1
     d keylcns         s                   like(lilcns)
640cAD wrtpcmd         s             10
640cAD wrtpwait        s              2  0
640cAD wrtpwhse        s              3  0
640cAD wrtptran#       s                   like(pttrn#)
640cAD wrtpfrmdate     s              8  0
640cAD wrtptodate      s              8  0
640cAd wrtpemp#        s                   like(ptemp#)
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
     C                   move      $pwhse        $kwhse
     C                   move      $pdate        $kdate
     *----------------------------------------------------------------
     * Main line
     *
     * history is not used, don't execute the program.
     c                   if        opishs = 0
     c                   eval      *inlr = *on
     c                   goto      bottom
     c                   endif
     * Check to see if we can delete this transaction.
     *
     C   l1              eval      delete = *off
     C   l1              exsr      chktrn
     *
     * Delete label record for transaction.
     *
     C                   if        delete = *on
     C                   add       1             erlcnt
     * ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
     C                   if        OPISHS <> 0
     C                   delete    lbrec                                49
     C                   endif
     *
     C                   endif
     C     bottom        tag
     *
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
     *   Define key for LICENSEH1 file.
     *
     C     keylic        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbtrn#
     *
     C                   eval      ertcnt = 0
     C                   eval      erlcnt = 0
     C                   eval      forevr = *on
     *
     *
     *    Define full key for file OPTIONS.
     *
     C                   eval      kywhse = *zeros
     C                   eval      kycode = '*SYSTEM '
     C     keyop         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode
     *
     *    Retrieve System options.
     *
     C     keyop         chain     options                            79
     C                   if        *in79
     C                   eval      opishs = 0
     C                   endif
     *
     *   Define key for LICINFO file.
     *
     c     keyln         klist
     c                   kfld                    liwhse
     c                   kfld                    lilcns
     *
     c     keylcninfo1   klist
     c                   kfld                    lbwhse
640bDc*                  kfld                    kylicinfo1
640bDc*                  kfld                    kylicinfotrn#
640bAc                   kfld                    lbtrn#
     *   Define key for LICINFO file orphaned in licinfo not license
     *
     c     keylnorphan   klist
     c                   kfld                    a_lnwhse
     c                   kfld                    a_lnlcns
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CHKTRN  Check transaction to see if it should be deleted.
     *
     C     chktrn        begsr
     *
     *
     *  Delete transaction if all of the following are true:
     *
     *     - End date is older than user entered date.
     *     - End date is not 0.
     *     - Closed date is older than user entered date.
     *     - Closed date is not 0.
     *     - All labels are closed for the transaction.
     *
     *     Get transaction record. If it doesn't exist set the date
     *     to negative 1 so that the label records can still be
     *     deleted. Of course, the transaction record always exist.
     *
730aDC**   lbtrn#        chain     pirtranH                           79
730aDC**                 if        *in79
730aM /free
730aM                    chain (lbwhse: lbtrn#) pirtranhw;
730aM /end-free
730aMC                   if        not %found(pirtranhw)
     C                   eval      ptcdte = -(1)
     C                   eval      pttask = *blanks
     C                   endif
     *
     C                   eval      opnlbl = *off
     *
     *     Now do actual check to see if we should delete transaction.
     *
     C                   if        ptcdte < $kdate  and
     C                             ptcdte <> 0  and
     C                             opnlbl = *off
     C                   eval      delete = *on
     C                   if        not *in79
     C                   add       1             ertcnt
     * ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
     C                   if        OPISHS <> 0
     C                   delete    ptrec                                49
640cAc                   exsr      zzwrttrand
     C                   endif
     *
     *    Remove matching records for customer returns only.
     *    This code was moved from the mainline so it only executes
     *    When the license is no longer active
     C                   if        pttask = 'PUTRTN'
     C                   exsr      zzlic
     C                   endif
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZLIC   Remove matching LICENSE records for PUTRTN task.
     *
     C     zzlic         begsr
     *
     C     keylic        chain     licenseh1
     C                   select
     *
     c                   when      %found(licenseh1)
640aAc     keyln         chain     liclogh
640aAc     keyln         chain     liclogh1
640aAc                   if        not %found(liclogh)  and
640aAc                             not %found(liclogh1)
     C     keyln         setll     licinfoh2
     c     *in74         doweq     *off
     c     keyln         reade     licinfoh2                              74
     c                   if        not *in74
      * Only write history if additional history is set in options
     C                   if        opishs <> 0
     c                   delete    lnhrec                               73
     C                   endif
     c                   endif
     c                   enddo
640aAc                   endif
     * ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
     C                   if        OPISHS <> 0
     C                   delete    lirec                                78
     C                   endif
     c
     c                   when      not %found(licenseh1)
      * if no license record is found check the licinfoh1 file for
      * license info code *RCVTRN# move to history if license is no
      * longer active
640bDc*                  eval      kylicinfo1 = '*RCVTRN#'
640bDC*                  eval      kylicinfotrn# =   %char(lbtrn#)
     c     keylcninfo1   chain     licinfoh1
     c                   if        %found(licinfoh1)
     c                   eval      *in76 = *off
640aAc     keylnorphan   chain     liclogh
640aAc     keylnorphan   chain     liclogh1
640aAc                   if        not %found(liclogh) and
640aAc                             not %found(liclogh1)
     c     keylnorphan   setll     licinfoh2
     c     forevr        doweq     forevr
     c     keylnorphan   reade     licinfoh2                              76
     c     *in76         ifeq      *on
     c                   leave
     c                   endif
     c     *in76         ifeq      *off
      * Only write history if additional history is set in options
     C                   if        opishs <> 0
     c                   delete    lnhrec                               77
     C                   endif
     c                   endif
     c                   enddo
640aAc                   endif
     c                   endif
     C                   endsl
     *
     C*                  enddo
     *
     C                   endsr
     *
640cA*----------------------------------------------------------------*********
640cA*
640cA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640cA*
640cA /free
640cA   begsr zzwrttrand;
640cA     wrtpcmd = '*CLEANUP';
640cA     wrtpwait = 0;
640cA     wrtpwhse = ptwhse;
640cA     wrtptran# = pttrn#;
710aD     //wrtpfrmdate = 0;
710aM     wrtpfrmdate = ptgdte;
640cA     wrtptodate = 0;
640cA     wrtpemp# = 0;
640cA
640cA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640cA               wrtpfrmdate: wrtptodate: wrtpemp#);
640cA   endsr;
640cA /end-free
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
