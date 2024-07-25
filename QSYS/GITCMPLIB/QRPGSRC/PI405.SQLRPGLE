     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PI405     Import FTP purchase orders - Multi Whse
     *  Max Blacknik
     *  11 March 2012
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    03/11/12  MLB  6.40
     *      - Created
     *
650 A*    08/31/13  MLB  6.50
     *      - Fix: Revised pgm to remove members from import files if
     *        no purchase orders found to import for warehouse.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    08/30/13  MLB  DRY
     *      - Revised program to process IMPFPOD2M file as primary
     *        instead of IMPFPOH2M.  Dairyland is upgrading to JDEdwards
     *        newest version and the pgm can create a purchase order
     *        to be sent to multiple warehouses.
     *      - Added new LF, IMPFPOH2M1 to retrieve p/o info for import
     *        p/o header file.
     *      - Added new LF, IMPFPOHMM1 to pgm.
DRYaA*    08/12/16  MLB  DRYa  P#0????
     *      - Enh: Revised pgm to write purchase orders into Import
     *        Staging files intead of using FTP import files.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fmultwhse  if   e           k disk
     Fimpfpoh2m uf   e           k disk
     F                                     prefix(mw_)
DRY AFimpfpoh2m1uf   e           k disk
DRY AF                                     prefix(mw_)
DRY AF                                     rename(pihrecm : pihrecm1)
     Fimpfpohmm uf   e           k disk    usropn
     F                                     prefix(mw_)
DRY AFimpfpohmm1uf   e           k disk    usropn
DRY AF                                     prefix(mw_)
DRY AF                                     rename(pihmrcm : pihmrcm1)
     Fimpfpod2m uf   e           k disk
     F                                     prefix(mw_)
     Fimpfpodmm uf   e           k disk    usropn
     F                                     prefix(mw_)
     *
     Fimpfpoh2  o  a e           k disk    usropn
     F                                     extfile(extpoh2)
     F                                     extmbr(extpoh2mbr)
     Fimpfpohm  o  a e           k disk    usropn
     F                                     extfile(extpohm)
     F                                     extmbr(extpohmmbr)
     Fimpfpod2  o  a e           k disk    usropn
     F                                     extfile(extpod2)
     F                                     extmbr(extpod2mbr)
     Fimpfpodm  o  a e           k disk    usropn
     F                                     extfile(extpodm)
     F                                     extmbr(extpodmmbr)
DRYaA*
DRYaAFstgbatch  uf a e           k disk    usropn
DRYaAFimpspoh   if a e           k disk    usropn
DRYaAF                                     rename(pihrec : pihrecs)
DRYaAFimpspod   if a e           k disk    usropn
DRYaAF                                     rename(pidrec : pidrecs)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
DRY A /COPY QCOPYSRC,ID#dairyla
     *----------------------------------------------------------------
     *  Called programs
     *
DRYaA*----------------------------------------------------------------
DRYaA*  Standard SQL variables and constants
DRYaA*----------------------------------------------------------------
DRYaA
DRYaA /copy qcopysrc,c#stdsql
DRYaA
DRYaA*----------------------------------------------------------------
DRYaA*  Prototypes
DRYaA*----------------------------------------------------------------
DRYaA
DRYaAD GetBatId        pr                  extpgm('GETBATID')
DRYaA * Input
DRYaAD   pWhse                        3p 0 const
DRYaAD   pType                       10    const
DRYaAD   pStatus                      1    const
DRYaA * Output
DRYaAD   pBatId                      11
DRYaAD   pReturn                     10
DRYaAD   pMessage                   200
DRYaA*
     *----------------------------------------------------------------
     *  Working Variables
     *
DRYaAD chgdate         s               d
DRYaAD chgtime         s               t
DRYaAD batid           s                    like(sbbatid)
     D cmdexcerr       s              1    inz('0')
     D error           s              1
     D extpoh2         s             21
     D extpoh2mbr      s             10
     D extpohm         s             21
     D extpohmmbr      s             10
     D extpod2         s             21
     D extpod2mbr      s             10
     D extpodm         s             21
     D extpodmmbr      s             10
     D forevr          s              1
DRYaAD importtype      s             10
     D len             s              1  0
     D lstwhs          s              3  0
     D mscdup          s              4    inz('*NO ')
     D mschup          s              4    inz('*NO ')
     D rcdstoimport    s              1    inz('0')
DRYaAD rtnCode         s             10
DRYaAD rtnMessage      s            200
DRYaAD stamp           s               z   inz
DRYaAD stampUC         s               z   inz
DTL AD dtlrcdread      s              1    inz('0')
DRY A*
DRY Ad mw_pidds        ds
DRY Ad  mw_pidpo               1      9
DRY Ad  mw_pidcdt             10     17  0
DRY Ad  mw_pidctm             18     23  0
DRYaAd  mw_addstamp           10     23  0
DRY Ad  mw_piddta              1     23
DRY A*
DRY Ad sv_pidds        ds
DRY Ad  sv_pidpo               1      9
DRY Ad  sv_pidcdt             10     17  0
DRY Ad  sv_pidctm             18     23  0
DRY Ad  sv_piddta              1     23
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD  - *PO2MP - Multi-warehouse import - Production
     *               *PO2MT - Multi-warehouse import - Test
     *      $PMBR  - Multi-warehouse import member
     *      $POUTQ - Output Queue for import reports
     *      $PFORM - Formtype for import reports
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pmbr            10
     C                   parm                    $poutq           10
     C                   parm                    $pform           10
     *
     *      Whip through all the multi-warehouse records.
     *
     *
     *      Processing p/o's for Production environment.
     C                   if        $pcmd = '*PO2MP'
     C                   eval      kyenv = 'P'
     C                   else
     C                   eval      kyenv = 'T'
     C                   endif
     C                   eval      lstwhs = -999
     C                   dow       forevr = forevr
     *
     C                   read      multwhse
     C                   if        %eof(multwhse)
     C                   leave
     C                   endif
     *
     *      Process only Active warehouses.
     C                   if        mltacd <> 'A'
     C                   iter
     C                   endif
     *
     *      Create warehouse heading if necessary.
     C                   if        mltwhs <> lstwhs
     C                   eval      lstwhs = mltwhs
650 AC                   if        rcdstoimport = '1'
     C                   eval      rcdstoimport = '0'
     *
     *      Close import files, if open to prepare for next warehouse.
DRYaAC                   if        importtype = '*FTP'
     C                   exsr      clsimportfile
DRYaAC                   endif
650 AC                   endif
     *
     *      Create library/file and member to be used for import.
DRYaAC                   select
DRYaAC                   when      importtype = '*FTP'
     C                   eval      extpoh2 = %trim(mltlib)
     C                                       + '/IMPFPOH2'
     C                   eval      extpoh2mbr = $pmbr
     *
     C                   eval      extpohm = %trim(mltlib)
     C                                       + '/IMPFPOHM'
     C                   eval      extpohmmbr = $pmbr
     *
     C                   eval      extpod2 = %trim(mltlib)
     C                                       + '/IMPFPOD2'
     C                   eval      extpod2mbr = $pmbr
     *
     C                   eval      extpodm = %trim(mltlib)
     C                                       + '/IMPFPODM'
     C                   eval      extpodmmbr = $pmbr
     *
     C                   exsr      addimportmbr
     *
     C                   exsr      addimportlib
     *
     C                   exsr      opnimportfile
DRYaAC                   endsl
     *
     C                   endif
DRY A*
DRY AC                   select
DRY AC                   when      client = Dairyland
DRY A*
DRYaAC                   select
DRYaAC                   when      importtype = '*FTP'
DRY A*      Write P/O detail records.
DRY AC                   exsr      zzwrtpid_dry
DRY A*
DRY A*      Write P/O detail misc. file.
DRY AC                   if        mscdup = '*YES'
DRY AC                   exsr      zzwrtpidm
DRY AC                   endif
DRYaA*
DRYaAC                   when      importtype = '*STAGE'
DRYaA*      Write P/O detail records.
DRYaAC                   exsr      zzstgpid_dry
DRYaAC                   endsl
DRY A*
DRY AC                   other
     *
     *      Write P/O header records.
     C                   exsr      zzwrtpih
     *
     *      Write P/O header misc. records.
     C                   if        mschup = '*YES'
     C                   exsr      zzwrtpihm
     C                   endif
     *
     *      Write P/O detail records.
     C                   exsr      zzwrtpid
     *
     *      Write P/O detail misc. file.
     C                   if        mscdup = '*YES'
     C                   exsr      zzwrtpidm
     C                   endif
     *
DRY AC                   endsl
DRY A*
     *      Submit import p/o updates job for current warehouse.
     C                   if        rcdstoimport = '1'
DRYaA*
DRYaAC                   if        importtype = '*FTP'
     C                   exsr      sbmpoimport
DRYaAC                   endif
DRYaA*
650 AC                   else
DRYaA*
DRYaAC                   if        importtype = '*FTP'
650 AC                   exsr      clsimportfile
650 AC                   exsr      rmvimportmbr
DRYaAC                   endif
DRYaA*
     C                   endif
     *
DRYaA*
DRYaAC                   if        importtype = '*FTP'
     C                   exsr      rmvimportlib
DRYaAC                   endif
     *
     C                   enddo
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm      *blanks       client           10
     C                   parm      *blanks       clientloc        10
     *
     C                   eval      forevr = *off
     C                   eval      error = *off
     C                   eval      mschup = '*NO '
     C                   eval      mscdup = '*NO '
     *
     * Key definitions
     *
     C     *like         define    mltenv        kyenv
     C     mltkey        klist
     C                   kfld                    mw_pihwhs
     C                   kfld                    kyenv
DRY A*
DRY A* Partial key for IMPFPOH2M1 file.
DRY AC     keypihm1      klist
DRY AC                   kfld                    sv_pidpo
DRYaA*
DRYaA* Full key for IMPFPOHM file.
DRYaAC     keypihm       klist
DRYaAC                   kfld                    mw_pidwhs
DRYaAC                   kfld                    mw_pidpo
DRYaAC                   kfld                    mw_pidcdt
DRYaAC                   kfld                    mw_pidctm
DRYaA*
DRYaA* Full key for IMPFPOD2M file.
DRYaAC     keypidm       klist
DRYaAC                   kfld                    mw_pidwhs
DRYaAC                   kfld                    mw_pidpo
DRYaAC                   kfld                    mw_pidcdt
DRYaAC                   kfld                    mw_pidctm
DRYaAC                   kfld                    mw_pidseq
DRYaAC                   kfld                    mw_piditm
     *
     * Open IMPFPOHMM Multi-Warehouse file.
     C                   if        not %open(impfpohmm)
     *
     C                   open (e)  impfpohmm
     C                   if        not %error
     C                   eval      mschup = '*YES'
DRY A*
DRY AC                   if        client = dairyland
DRY AC                   open (e)  impfpohmm1
DRY AC                   endif
DRY A*
     C                   else
     C                   eval      mschup = '*NO '
     C                   endif
     *
     C                   endif
     *
     * Open IMPFPODMM Multi-Warehouse file.
     C                   if        not %open(impfpodmm)
     *
     C                   open (e)  impfpodmm
     C                   if        not %error
     C                   eval      mscdup = '*YES'
     C                   else
     C                   eval      mscdup = '*NO '
     C                   endif
     *
     C                   endif
     *
DRYaAC                   select
DRYaAC                   when      client = Dairyland
DRYaAC                   eval      importtype = '*STAGE'
DRYaA*
DRYaAC                   if        not %open(stgbatch)
DRYaAC                   open (e)  stgbatch
DRYaAC                   endif
DRYaA*
DRYaAC                   if        not %open(impspoh)
DRYaAC                   open (e)  impspoh
DRYaAC                   endif
DRYaA*
DRYaAC                   if        not %open(impspod)
DRYaAC                   open (e)  impspod
DRYaAC                   endif
DRYaAC
DRYaAC                   other
DRYaAC                   eval      importtype = '*FTP'
DRYaAC                   endsl
     C
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ADDIMPORTLIB   Add import files library to library list.
     *
     C     addimportlib  begsr
     *
     C                   eval      qcmd = 'addlible lib('
     C                             + %trim(mltlib)
     C                             + ') position(*AFTER PIRMODS)'
     C                   eval      qlen = %len(%trim(qcmd))
     C                   exsr      zzcmdexc
     C                   if        cmdexcerr = '1'
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ADDIMPORTMBR   Add import file members.
     *
     C     addimportmbr  begsr
     *
     C                   eval      qcmd = 'addpfm file('
     C                             + %trim(mltlib)
     C                             + '/'
     C                             + %trim('IMPFPOH2) mbr(')
     C                             + %trim($pmbr)
     C                             + ')'
     C                   eval      qlen = %len(%trim(qcmd))
     C                   exsr      zzcmdexc
     C                   if        cmdexcerr = '1'
     C                   endif
     *
     C                   eval      qcmd = 'addpfm file('
     C                             + %trim(mltlib)
     C                             + '/'
     C                             + %trim('IMPFPOHM) mbr(')
     C                             + %trim($pmbr)
     C                             + ')'
     C                   eval      qlen = %len(%trim(qcmd))
     C                   exsr      zzcmdexc
     C                   if        cmdexcerr = '1'
     C                   endif
     *
     C                   eval      qcmd = 'addpfm file('
     C                             + %trim(mltlib)
     C                             + '/'
     C                             + %trim('IMPFPOD2) mbr(')
     C                             + %trim($pmbr)
     C                             + ')'
     C                   eval      qlen = %len(%trim(qcmd))
     C                   exsr      zzcmdexc
     C                   if        cmdexcerr = '1'
     C                   endif
     *
     C                   eval      qcmd = 'addpfm file('
     C                             + %trim(mltlib)
     C                             + '/'
     C                             + %trim('IMPFPODM) mbr(')
     C                             + %trim($pmbr)
     C                             + ')'
     C                   eval      qlen = %len(%trim(qcmd))
     C                   exsr      zzcmdexc
     C                   if        cmdexcerr = '1'
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  OPNIMPORTFILE   Open import file members.
     *
     C     opnimportfile begsr
     *
     C                   if        not %open(impfpoh2)
     C                   open      impfpoh2
     C                   endif
     *
     C                   if        not %open(impfpohm)
     C                   open      impfpohm
     C                   endif
     *
     C                   if        not %open(impfpod2)
     C                   open      impfpod2
     C                   endif
     *
     C                   if        not %open(impfpodm)
     C                   open      impfpodm
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CLSIMPORTFILE   Close import file members.
     *
     C     clsimportfile begsr
     *
     C                   if        %open(impfpoh2)
     C                   close     impfpoh2
     C                   endif
     *
     C                   if        %open(impfpohm)
     C                   close     impfpohm
     C                   endif
     *
     C                   if        %open(impfpod2)
     C                   close     impfpod2
     C                   endif
     *
     C                   if        %open(impfpodm)
     C                   close     impfpodm
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RMVIMPORTLIB   Remove import files library from library list.
     *
     C     rmvimportlib  begsr
     *
     C                   eval      qcmd = 'rmvlible lib('
     C                             + %trim(mltlib)
     C                             + ')'
     C                   eval      qlen = %len(%trim(qcmd))
     C                   exsr      zzcmdexc
     C                   if        cmdexcerr = '1'
     C                   endif
     *
     C                   endsr
650 A*
650 A*----------------------------------------------------------------
650 A*
650 A*  RMVIMPORTMBR   Remove member from import files.
650 A*
650 AC     rmvimportmbr  begsr
650 A*
650 AC                   eval      qcmd = 'rmvm file('
650 AC                             + %trim(mltlib)
650 AC                             + '/'
650 AC                             + 'impfpoh2'
650 AC                             + ')'
650 AC                             + ' mbr('
650 AC                             + %trim($pmbr)
650 AC                             + ')'
650 AC                   eval      qlen = %len(%trim(qcmd))
650 AC                   exsr      zzcmdexc
650 AC                   if        cmdexcerr = '1'
650 AC                   endif
650 A*
650 AC                   if        mschup = '*YES'
650 AC                   eval      qcmd = 'rmvm file('
650 AC                             + %trim(mltlib)
650 AC                             + '/'
650 AC                             + 'impfpohm'
650 AC                             + ')'
650 AC                             + ' mbr('
650 AC                             + %trim($pmbr)
650 AC                             + ')'
650 AC                   eval      qlen = %len(%trim(qcmd))
650 AC                   exsr      zzcmdexc
650 AC                   if        cmdexcerr = '1'
650 AC                   endif
650 AC                   endif
650 A*
650 AC                   eval      qcmd = 'rmvm file('
650 AC                             + %trim(mltlib)
650 AC                             + '/'
650 AC                             + 'impfpod2'
650 AC                             + ')'
650 AC                             + ' mbr('
650 AC                             + %trim($pmbr)
650 AC                             + ')'
650 AC                   eval      qlen = %len(%trim(qcmd))
650 AC                   exsr      zzcmdexc
650 AC                   if        cmdexcerr = '1'
650 AC                   endif
650 A*
650 AC                   if        mscdup = '*YES'
650 AC                   eval      qcmd = 'rmvm file('
650 AC                             + %trim(mltlib)
650 AC                             + '/'
650 AC                             + 'impfpodm'
650 AC                             + ')'
650 AC                             + ' mbr('
650 AC                             + %trim($pmbr)
650 AC                             + ')'
650 AC                   eval      qlen = %len(%trim(qcmd))
650 AC                   exsr      zzcmdexc
650 AC                   if        cmdexcerr = '1'
650 AC                   endif
650 AC                   endif
650 A*
650 AC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWRTPID  Write out p/o detail records for current warehouse
     *
     C     zzwrtpid      begsr
     *
     C     mltwhs        setll     impfpod2m
     C                   dow       forevr = forevr
     C     mltwhs        reade     impfpod2m
     C                   if        %eof(impfpod2m)
     C                   leave
     C                   endif
     C
     C                   eval      rcdstoimport = '1'
     *  Move fields from mult-warehouse file to warehouse import file.
     C                   eval      pidwhs = mw_pidwhs
     C                   eval      pidpo  = mw_pidpo
     C                   eval      pidcdt = mw_pidcdt
     C                   eval      pidctm = mw_pidctm
     C                   eval      pidseq = mw_pidseq
     C                   eval      piditm = mw_piditm
     *
     C                   eval      pidvit = mw_pidvit
     C                   eval      pidspc = mw_pidspc
     C                   eval      pidqo1 = mw_pidqo1
     C                   eval      pidqo2 = mw_pidqo2
     C                   eval      pidqo3 = mw_pidqo3
     C                   eval      pidtyp = mw_pidtyp
     *
     C                   write     pidrec
     *
     C                   enddo
     *
     C                   endsr
DRY A*
DRY A*----------------------------------------------------------------
DRY A*
DRY A*  ZZWRTPID_DRY  Write out p/o detail records for current warehouse
DRY A*
DRY AC     zzwrtpid_dry  begsr
DRY A*
DRY AC                   eval      sv_pidds = *loval
DRY AC                   eval      dtlrcdread = '0'
DRY AC     mltwhs        setll     impfpod2m
DRY AC                   dow       forevr = forevr
DRY AC     mltwhs        reade     impfpod2m
DRY AC                   if        %eof(impfpod2m)
DRY AC
DRY AC                   if            dtlrcdread = '1'
DRY A*      Create p/o header rcd.
DRY AC                   exsr      zzwrtpih_dry
DRY A*
DRY AC                   if        mschup = '*YES'
DRY A*      Create p/o header misc. rcd.
DRY AC                   exsr      zzwrtpihm_dry
DRY AC                   endif
DRY A*
DRY AC                   endif
DRY A*
DRY AC                   leave
DRY AC                   endif
DRY AC
DRY AC                   if            dtlrcdread = '0'
DRY A*      Update hold fields for first record read.
DRY AC                   eval      sv_pidpo  = mw_pidpo
DRY AC                   eval      sv_pidcdt = mw_pidcdt
DRY AC                   eval      sv_pidctm = mw_pidctm
DRY AC                   endif
DRY AC
DRY AC                   if                mw_pidds <> sv_pidds
DRY AC                                 and dtlrcdread = '1'
DRY A*      Create p/o header rcd.
DRY AC                   exsr      zzwrtpih_dry
DRY A*
DRY AC                   if        mschup = '*YES'
DRY A*      Create p/o header misc. rcd.
DRY AC                   exsr      zzwrtpihm_dry
DRY AC                   endif
DRY A*
DRY A*      Update hold fields.
DRY AC                   eval      sv_pidpo  = mw_pidpo
DRY AC                   eval      sv_pidcdt = mw_pidcdt
DRY AC                   eval      sv_pidctm = mw_pidctm
DRY A*
DRY AC                   endif
DRY AC
DRY AC                   eval      rcdstoimport = '1'
DRY AC                   eval      dtlrcdread   = '1'
DRY A*  Move fields from mult-warehouse file to warehouse import file.
DRY AC                   eval      pidwhs = mw_pidwhs
DRY AC                   eval      pidpo  = mw_pidpo
DRY AC                   eval      pidcdt = mw_pidcdt
DRY AC                   eval      pidctm = mw_pidctm
DRY AC                   eval      pidseq = mw_pidseq
DRY AC                   eval      piditm = mw_piditm
DRY A*
DRY AC                   eval      pidvit = mw_pidvit
DRY AC                   eval      pidspc = mw_pidspc
DRY AC                   eval      pidqo1 = mw_pidqo1
DRY AC                   eval      pidqo2 = mw_pidqo2
DRY AC                   eval      pidqo3 = mw_pidqo3
DRY AC                   eval      pidtyp = mw_pidtyp
DRY A*
DRY AC                   write     pidrec
DRY A*
DRY AC                   enddo
DRY A*
DRY AC                   endsr
DRYaA*
DRYaA*----------------------------------------------------------------
DRYaA*
DRYaA*  ZZSTGPID_DRY  Write out Staging p/o detail rcds for current whse.
DRYaA*
DRYaAC     zzstgpid_dry  begsr
DRYaA*
DRYaAC                   eval      sv_pidds = *loval
DRYaAC                   eval      dtlrcdread = '0'
DRYaAC     mltwhs        setll     impfpod2m
DRYaAC                   dow       forevr = forevr
DRYaAC     mltwhs        reade     impfpod2m
DRYaAC                   if        %eof(impfpod2m)
DRYaAC
DRYaAC                   if            dtlrcdread = '1'
DRYaA*      Create p/o header rcd.
DRYaAC                   exsr      zzstgpih_dry
DRYaA*      Update Batch ID header rcd.
DRYaAC                   exsr      zzzend
DRYaA*
DRYaAC                   endif
DRYaA*
DRYaAC                   leave
DRYaAC                   endif
DRYaA*
DRYaAC                   if        mscdup = '*YES'
DRYaAC     keypidm       chain     impfpod2m
DRYaAC                   if        not %found(impfpod2m)
DRYaAC                   eval      mw_pidods = ' '
DRYaAC                   eval      mw_pidpom = ' '
DRYaAC                   eval      mw_pidms1 = ' '
DRYaAC                   eval      mw_pidms2 = ' '
DRYaAC                   eval      mw_pidms3 = ' '
DRYaAC                   eval      mw_pidms4 = ' '
DRYaAC                   eval      mw_pidms5 = ' '
DRYaAC                   endif
DRYaA*
DRYaAC                   endif
DRYaAC
DRYaaC                   if            dtlrcdread = '0'
DRYaA*      Update hold fields for first record read.
DRYaAC                   eval      sv_pidpo  = mw_pidpo
DRYaAC                   eval      sv_pidcdt = mw_pidcdt
DRYaAC                   eval      sv_pidctm = mw_pidctm
DRYaAC                   endif
DRYaAC
DRYaAC                   if                mw_pidds <> sv_pidds
DRYaAC                                 and dtlrcdread = '1'
DRYaA*      Create p/o header rcd.
DRYaAC                   exsr      zzstgpih_dry
DRYaA*
DRYaA*      Update hold fields.
DRYaAC                   eval      sv_pidpo  = mw_pidpo
DRYaAC                   eval      sv_pidcdt = mw_pidcdt
DRYaAC                   eval      sv_pidctm = mw_pidctm
DRYaA*
DRYaAC                   endif
DRYaAC
DRYaA*      Get Batch ID for warehouse. All po's will have same batch#.
DRYaAC                   if        dtlrcdread = '0'
DRYaAC                   exsr      zzzGetBatId
DRYaAC                   endif
DRYaAC
DRYaAC                   eval      rcdstoimport = '1'
DRYaAC                   eval      dtlrcdread   = '1'
DRYaAC                   exsr      zzzGetStamps
DRYaA*
DRYaA*  Move fields from mult-warehouse file to warehouse import file.
DRYaAC                   eval      pidwhs   = mw_pidwhs
DRYaAC                   eval      pidbatid = batid
DRYaAC                   eval      pidpo  = mw_pidpo
DRYaAC                   eval      pidseq = mw_pidseq
DRYaAC                   eval      piditm = mw_piditm
DRYaAC                   eval      pidtyp = mw_pidtyp
DRYaA*
DRYaAC                   eval      pidstatus = 'R'
DRYaAC                   eval      pidststs = stamp
DRYaAC                   eval      pidstsuc = stampuc
DRYaA*
DRYaAC                   eval      pidvit = mw_pidvit
DRYaAC                   eval      pidspc = mw_pidspc
DRYaAC                   eval      pidqo1 = mw_pidqo1
DRYaAC                   eval      pidqo2 = mw_pidqo2
DRYaAC                   eval      pidqo3 = mw_pidqo3
DRYaA*
DRYaAC                   eval      pidods = mw_pidods
DRYaAC                   eval      pidpom = mw_pidpom
DRYaAC                   eval      pidms1 = mw_pidms1
DRYaAC                   eval      pidms2 = mw_pidms2
DRYaAC                   eval      pidms3 = mw_pidms3
DRYaAC                   eval      pidms4 = mw_pidms4
DRYaAC                   eval      pidms5 = mw_pidms5
DRYaAC     *ISO          move      mw_pidcdt     chgdate
DRYaAC     *HMS          move      mw_pidctm     chgtime
DRYaAC                   move      chgdate       pidaddts
DRYaAC                   move      chgtime       pidaddts
DRYaAC                   move      chgdate       pidadduc
DRYaAC                   move      chgtime       pidadduc
DRYaA*
DRYaAC                   write     pidrecs
DRYaA*
DRYaAC                   enddo
DRYaA*
DRYaAC                   endsr
     *
      *----------------------------------------------------------------
     *
     *  ZZWRTPIDM   Write p/o detail misc. records for current warehouse.
     *
     C     zzwrtpidm     begsr
     *
     C     mltwhs        setll     impfpodmm
     C                   dow       forevr = forevr
     C     mltwhs        reade     impfpodmm
     C                   if        %eof(impfpodmm)
     C                   leave
     C                   endif
     C
     C                   eval      rcdstoimport = '1'
     *  Move fields from multi-warehouse file to warehouse import file.
     C                   eval      pidmwh = mw_pidmwh
     C                   eval      pidmpo = mw_pidmpo
     C                   eval      pidmcd = mw_pidmcd
     C                   eval      pidmct = mw_pidmct
     C                   eval      pidmsq = mw_pidmsq
     C                   eval      pidmit = mw_pidmit
     *
     C                   eval      pidods = mw_pidods
     C                   eval      pidpom = mw_pidpom
     C                   eval      pidms1 = mw_pidms1
     C                   eval      pidms2 = mw_pidms2
     C                   eval      pidms3 = mw_pidms3
     C                   eval      pidms4 = mw_pidms4
     C                   eval      pidms5 = mw_pidms5
     *
     C                   write     pidmrc
     *
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWRTPIH   Write p/o header records for current warehouse.
     *
     C     zzwrtpih      begsr
     *
     C     mltwhs        setll     impfpoh2m
     C                   dow       forevr = forevr
     C     mltwhs        reade     impfpoh2m
     C                   if        %eof(impfpoh2m)
     C                   leave
     C                   endif
     C
     C                   eval      rcdstoimport = '1'
     *  Move fields from multi-warehouse file to warehouse import file.
     C                   eval      pihwhs = mw_pihwhs
     C                   eval      pihpo  = mw_pihpo
     C                   eval      pihcdt = mw_pihcdt
     C                   eval      pihctm = mw_pihctm
     *
     C                   eval      pihven = mw_pihven
     C                   eval      pihvna = mw_pihvna
     C                   eval      pihva1 = mw_pihva1
     C                   eval      pihva2 = mw_pihva2
     C                   eval      pihvct = mw_pihvct
     C                   eval      pihvst = mw_pihvst
     C                   eval      pihvzp = mw_pihvzp
     C                   eval      pihdte = mw_pihdte
     C                   eval      pihtim = mw_pihtim
     C                   eval      pihtyp = mw_pihtyp
     *
     C                   write     pihrec
     *
     C                   enddo
     *
     C                   endsr
DRY A*
DRY A*----------------------------------------------------------------
DRY A*
DRY A*  ZZWRTPIH_DRY   Write p/o header rcds for current whse.
DRY A*
DRY AC     zzwrtpih_dry  begsr
DRY A*
DRY AC     keypihm1      chain     impfpoh2m1
DRY AC                   if        not %found(impfpoh2m1)
DRY AC                   leavesr
DRY AC                   endif
DRY AC
DRY AC                   eval      rcdstoimport = '1'
DRY A*  Move fields from multi-warehouse file to warehouse import file.
DRY AC                   eval      pihwhs = mltwhs
DRY AC                   eval      pihpo  = sv_pidpo
DRY AC                   eval      pihcdt = sv_pidcdt
DRY AC                   eval      pihctm = sv_pidctm
DRY A*
DRY AC                   eval      pihven = mw_pihven
DRY AC                   eval      pihvna = mw_pihvna
DRY AC                   eval      pihva1 = mw_pihva1
DRY AC                   eval      pihva2 = mw_pihva2
DRY AC                   eval      pihvct = mw_pihvct
DRY AC                   eval      pihvst = mw_pihvst
DRY AC                   eval      pihvzp = mw_pihvzp
DRY AC                   eval      pihdte = mw_pihdte
DRY AC                   eval      pihtim = mw_pihtim
DRY AC                   eval      pihtyp = mw_pihtyp
DRY A*
DRY AC                   write     pihrec
DRY A*
DRY AC                   endsr
DRYaA*
DRYaA*----------------------------------------------------------------
DRYaA*
DRYaA*  ZZSTGPIH_DRY   Write Staging p/o header rcds for current whse.
DRYaA*
DRYaAC     zzstgpih_dry  begsr
DRYaA*
DRYaAC     keypihm1      chain     impfpoh2m1
DRYaAC                   if        not %found(impfpoh2m1)
DRYaAC                   leavesr
DRYaAC                   endif
DRYaA*
DRYaAC                   if        mschup = '*YES'
DRYaAC     keypihm1      chain     impfpohmm1
DRYaAC                   if        not %found(impfpohmm1)
DRYaAC                   eval      mw_pihmm1 = ' '
DRYaAC                   eval      mw_pihmm2 = ' '
DRYaAC                   eval      mw_pihmm3 = ' '
DRYaAC                   eval      mw_pihmm4 = ' '
DRYaAC                   eval      mw_pihmm5 = ' '
DRYaAC                   endif
DRYaAC                   endif
DRYaAC
DRYaAC                   eval      rcdstoimport = '1'
DRYaA*  Move fields from multi-warehouse file to warehouse import file.
DRYaAC                   eval      pihwhs = mltwhs
DRYaAC                   eval      pihbatid = batid
DRYaAC                   eval      pihpo  = sv_pidpo
DRYaAC                   eval      pihtyp = mw_pihtyp
DRYaA*
DRYaAC                   eval      pihstatus = 'R'
DRYaAC                   eval      pihststs = stamp
DRYaAC                   eval      pihstsuc = stampuc
DRYaA*
DRYaAC                   eval      pihven = mw_pihven
DRYaAC                   eval      pihvna = mw_pihvna
DRYaAC                   eval      pihva1 = mw_pihva1
DRYaAC                   eval      pihva2 = mw_pihva2
DRYaAC                   eval      pihvct = mw_pihvct
DRYaAC                   eval      pihvst = mw_pihvst
DRYaAC                   eval      pihvzp = mw_pihvzp
DRYaAC                   eval      pihdte = mw_pihdte
DRYaAC                   eval      pihtim = mw_pihtim
DRYaA*
DRYaAC                   eval      pihmm1 = mw_pihmm1
DRYaAC                   eval      pihmm2 = mw_pihmm2
DRYaAC                   eval      pihmm3 = mw_pihmm3
DRYaAC                   eval      pihmm4 = mw_pihmm4
DRYaAC                   eval      pihmm5 = mw_pihmm5
DRYaAC                   move      chgdate       pihaddts
DRYaAC                   move      chgtime       pihaddts
DRYaAC                   move      chgdate       pihadduc
DRYaAC                   move      chgtime       pihadduc
DRYaA*
DRYaAC                   write     pihrecs
DRYaA*
DRYaAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWRTPIHM   Write p/o header misc. records for current warehouse.
     *
     C     zzwrtpihm     begsr
     *
     C     mltwhs        setll     impfpohmm
     C                   dow       forevr = forevr
     C     mltwhs        reade     impfpohmm
     C                   if        %eof(impfpohmm)
     C                   leave
     C                   endif
     C
     C                   eval      rcdstoimport = '1'
     *  Move fields from multi-warehouse file to warehouse import file.
     C                   eval      pihmwh = mw_pidwhs
     C                   eval      pihmpo = mw_pihmpo
     C                   eval      pihmcd = mw_pihmcd
     C                   eval      pihmct = mw_pihmct
     *
     C                   eval      pihmm1 = mw_pihmm1
     C                   eval      pihmm2 = mw_pihmm2
     C                   eval      pihmm3 = mw_pihmm3
     C                   eval      pihmm4 = mw_pihmm4
     C                   eval      pihmm5 = mw_pihmm5
     *
     C                   write     pihmrc
     *
     C                   enddo
     *
     C                   endsr
DRY A*
DRY A*----------------------------------------------------------------
DRY A*
DRY A*  ZZWRTPIHM_DRY   Write p/o header misc. records for current warehouse.
DRY A*
DRY AC     zzwrtpihm_dry begsr
DRY A*
DRY AC     keypihm1      chain     impfpohmm1
DRY AC                   if        not %found(impfpohmm1)
DRY AC                   leavesr
DRY AC                   endif
DRY AC
DRY AC                   eval      rcdstoimport = '1'
DRY A*  Move fields from multi-warehouse file to warehouse import file.
DRY AC                   eval      pihmwh = mltwhs
DRY AC                   eval      pihmpo = sv_pidpo
DRY AC                   eval      pihmcd = sv_pidcdt
DRY AC                   eval      pihmct = sv_pidctm
DRY A*
DRY AC                   eval      pihmm1 = mw_pihmm1
DRY AC                   eval      pihmm2 = mw_pihmm2
DRY AC                   eval      pihmm3 = mw_pihmm3
DRY AC                   eval      pihmm4 = mw_pihmm4
DRY AC                   eval      pihmm5 = mw_pihmm5
DRY A*
DRY AC                   write     pihmrc
DRY A*
DRY AC                   endsr
DRYaA
DRYaA*----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------
      /free
       begsr zzzEnd;

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :mw_pidwhs
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        endif;

       endsr; // zzzEnd
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
       begsr zzzGetBatId;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        monitor;
          GetBatId(mw_pidwhs: 'IMPPO': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

       endsr; // zzzGetBatId
      /end-free

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------
      /free
       begsr zzzGetStamps;

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

       endsr; // zzzGetStamps
      /end-free
     *
     *----------------------------------------------------------------
     *
     *  SBMPOIMPORT    Submit Import P/O job
     *
     C     sbmpoimport   begsr
     *
     C                   eval      qcmd = 'SBMJOB CMD(CALL PGM(PI260CL) PARM('
     C                             + ''''
     C                             + %trim($pmbr)
     C                             + ''''
     C                             + ' '
     C                             + ''''
     C                             + '*INTER '
     C                             + ''''
     C                             + ' '
     C                             + ''''
     C                             + %trim($poutq)
     C                             + ''''
     C                             + ' '
     C                             + ''''
     C                             + %trim($pform)
     C                             + ''''
     C                             + ')) Job(PI260CL) Jobq(QS36EVOKE)'
     C                   eval      qlen = %len(%trim(qcmd))
     C                   exsr      zzcmdexc
     C                   if        cmdexcerr = '1'
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMDEXC  Execute call to pgm, QCMDEXC.
     *
     C     zzcmdexc      begsr
     *
     C                   eval      cmdexcerr = '0'
     C                   call (e)  'QCMDEXC'
     C                   parm                    QCMD            250
     C                   parm                    QLEN             15 5
     C                   if        %error
     C                   eval      cmdexcerr = '1'
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
