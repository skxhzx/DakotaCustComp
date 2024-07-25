      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PCK225    Create random test orders for warehouse 900 - Create
     *  29 July 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
404 A*    08/08/97  DAS  4.04
     *      - Changed to exclude items for compartments that have
     *        a maximum cube of zero.
     *
404 A*    08/27/97  DAS  4.04
     *      - Revised to abort after 100 attempts of trying to put
     *        an item into a compartment. An infinite loop occured
     *        when the qty left to fill the pallet was below the
     *        minimum for the compartment but greater than the minimum
     *        pieces for an item.
     *
404 A*    09/05/97  DAS  4.04
     *      - Passing order type as a parameter.
     *
416 A*    07/16/02  DAS  4.16
     *      - Added FTP option.
     *
640aA*    07/21/11  DAS  6.40
     *      - Converted to ILE
     *      - Added Batch Pick option
     *      - Change FTP to user OI280 '4' files.
     *
640bA*    07/29/11  DAS  6.40b
     *      - Change to SQLRPGLE
     *      - Changed W1FTP option into an Import Method option.
     *      - Added Staging import method
     *
640cA*    05/29/12  DAS  6.40c
     *      - Initialized OIHEST field.
     *      - Revisted to write out OIHEST to IMPSORDH file.
     *
650aA*    10/28/13  DAS  6.50a
     *      - Added warehouse option
     *
700aA*    01/30/16  DAS  7.00a
     *      - Added AMP Pick option
     *
730aA*    12/04/19  DAS  7.30a
     *      - Added logic to populate staging pick slot when
     *        Feature is 3.
     *      - Change missed 900's to kywhse.
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    - The screen for this program must be compiled with
     *      defer write equal to *NO.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpck225fm  cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fworklbl   if   e           k disk
416 D*MPORDH1UF  E           K        DISK                      A
416 D*MPORDD UF  E           K        DISK                      A
416 MFimpordh1  uf a e           k disk    usropn
416 MFimpordd   uf a e           k disk    usropn
640aDF*mpfordh  o  a e           k disk    usropn
640aMFimpfordh4 o  a e           k disk    usropn
     F                                     rename(oihrec:oihrecf)
700aMFimpfordhm o  a e           k disk    usropn
640aDF*mpfordd  o  a e           k disk    usropn
640aMFimpfordd4 o  a e           k disk    usropn
     F                                     rename(oidrec:oidrecf)
640aAFimpforddm o  a e           k disk    usropn
640aAF                                     rename(oimrec:oimrecf)

640bA*----------------------------------------------------------------
640bA*  File data data structure
640bA*----------------------------------------------------------------
640bA
640bAD oihrecs       E ds                  extname(impsordh) inz(*EXTDFT)
640bAD oidrecs       E ds                  extname(impsordd) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D item            s             15    dim(200)
     D cname           s             40    dim(1) ctdata perrcd(1)
     D adr1            s             40    dim(1) ctdata perrcd(1)
     D misc            s             20    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
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
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
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
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D $pmsg           s              4
     D $pprg           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D abort           s              1
640bAD  batId          s             11
     D count           s              3  0
     D dryhgh          s              5  0
     D drylft          s              5  0
     D drylow          s              5  0
     D dummy           s              1
     D error           s              1
     D forevr          s              1
     D frzhgh          s              5  0
     D frzlft          s              5  0
     D frzlow          s              5  0
     D items           s              6  0
     D itmcub          s                   like(lwcube)
     D kylbl#          s                   like(lwlbl#)
     D kytype          s                   like(oihtyp)
     D kywhse          s                   like(oihwhs)
     D maxlbl          s              5  0
     D msgk            s              4  0
     D refhgh          s              5  0
     D reflft          s              5  0
     D reflow          s              5  0
640bAD  rtnCode        s             10
640bAD  rtnMessage     s            200
     D sclear          s              1
     D temp2a          s              2
     D temp4a          s              4
730aAD $gfCmd          s              8
730aAD $gfFeature      s              1
730aAD $gfLight        s              1
730aAD $gfTBType       s              1
730aAD $gfWhse         s              3p 0

640bA*----------------------------------------------------------------
640bA*  Standard SQL variables and constants
640bA*----------------------------------------------------------------
640bA
640bA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     ** SUB PROCEDURE PROTOTYPES
     *----------------------------------------------------------------

730aAd GetPickSlot     pr            12

640bA*----------------------------------------------------------------
640bA* Function prototypes.
640bA*----------------------------------------------------------------

640bAD dktimport       pr                  extpgm('DKTIMPORT')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pBatId                      11    const
     D   pRunType                     1    const
     D   pProgram                    10    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

640bAD GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

730aA /copy qcopysrc,p.getfeat

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PJTYP  0 - Batch
     *              1 - Interactive
     *      $PRTE   Route
     *      $PDRY   Maximum cube for Dry compartment
     *      $PREF   Maximum cube for Refridgerated compartment
     *      $PFRZ   Maximum cube for Frozen compartment
404 A*      $PTYPE  ' ' - Normal
404 A*              'W' - Normal
416 A*      $PFTP   'Y' - Yes
416 A*              'N' - No
640aA*      $PBPCK  'Y' - Yes
640aA*              'N' - No
700aA*      $PAPCK  'Y' - Yes
700aA*              'N' - No
700aA*      $PACOD  AMP Staging area code
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pjtyp            1
     C                   parm                    $prte             5
     C                   parm                    $ptruk           10
     C                   parm                    $pitm1           15 5
     C                   parm                    $pitm2           15 5
     C                   parm                    $ppcs1           15 5
     C                   parm                    $ppcs2           15 5
     C                   parm                    $pdry            15 5
     C                   parm                    $pref            15 5
     C                   parm                    $pfrz            15 5
     C                   parm                    $ptype            1
416 AC                   parm                    $pftp             1
640aAC                   parm                    $pbpck            1
650aAC                   parm                    $pwhse            3 0
700aAC                   parm                    $papck            1
700aAC                   parm                    $pacod            3
650aA
     C                   z-add     $pdry         wodry
     C                   z-add     $pref         woref
     C                   z-add     $pfrz         wofrz
     *----------------------------------------------------------------
     *  Main line
     *
     *  Only work with warehouse 900.
     *
650aDC**                 eval      kywhse = 900
650aMC                   eval      kywhse = $pwhse
650aAC                   eval      w1whse = $pwhse
     *
     *  Keep user informed.
     *
     C                   if        $pjtyp = *on
     C                   z-add     $pdry         wodry
     C                   z-add     $pref         woref
     C                   z-add     $pfrz         wofrz
     C                   write     screen1
     C                   endif
730aA*
730aA*  Get Feature code
730aA*
730aA /free
730aA      $gfWhse = kywhse;
730aA      GetFeat ('*GET': $gfwhse: $gfFeature: $gfLight: $gfTBType);
730aA /end-free
416 A*
416 A*   Skip delete for FTP.
416 A*
640bDC**   $pftp         cabeq     'Y'           skpdel
640bMC     $pftp         cabne     'X'           skpdel
     *
     *   Delete any existing orders from import files.
     *
     *     Delete IMPORDH records.
     *
     C     keyoih        setll     impordh1
     C                   dou       forevr <> forevr
     C     keyoih        reade     impordh1                               78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *       Delete IMPORDD records.
     *
     C     keyoid        setll     impordd
     C                   dou       forevr <> forevr
     C     keyoid        reade     impordd                                77
     C                   if        *in77
     C                   leave
     C                   endif
     C                   delete    oidrec
     C                   enddo
     *
     C                   delete    oihrec
     C                   enddo
     *
416 AC     skpdel        tag
     *
     *  Set ranges for each compartment.
     *
     C                   if        $pdry > 0
     C     $pdry         sub       10            drylow
     C     $pdry         add       10            dryhgh
     C                   eval      drylft = dryhgh
     C                   endif
     *
     C                   if        $pref > 0
     C     $pref         sub       10            reflow
     C     $pref         add       10            refhgh
     C                   eval      reflft = refhgh
     C                   endif
     *
     C                   if        $pfrz > 0
     C     $pfrz         sub       10            frzlow
     C     $pfrz         add       10            frzhgh
     C                   eval      frzlft = frzhgh
     C                   endif
     *
     *  Get number of items in WORKLBL file.
     *
     C     *loval        setll     worklbl
     C                   read      worklbl                                79
     C     lwlbl#        cabge     0             bottom
     C                   z-sub     lwlbl#        maxlbl
640bA*
640bA*  Get batch id to use with Staging files
640bA*
640bAC                   if        $pftp = 'S'
640bAC                   exsr      GetBatchId
640bAC                   endif
     *
     *  Loop until all compartments have been filled or we have
     *  created 99 orders.
     *
     C                   clear                   oihrec
700aAC                   clear                   ohmrec
     C                   eval      oihwhs = kywhse
700aAC                   eval      ohmwhs = oihwhs
     C                   eval      oihrte = $prte
     C                   eval      oihtrk = $ptruk
404 AC                   eval      oihtyp = $ptype
     C     1             do        99            oihord
700aAC                   eval      ohmord = oihord
     *
     C                   if        w1dryc >= drylow  and
     C                             w1refc >= reflow  and
     C                             w1frzc >= frzlow
     C                   leave
     C                   endif
     *
     *    Keep user informed.
     *
     C                   if        $pjtyp = *on
     C                   z-add     oihord        w1ord
     C                   write     screen1
     C                   endif
     *
     *    Create order header record.
     *
     C                   eval      oihcus = 1000 + oihord
     C                   move      oihcus        temp4a
     C                   eval      oihcpo = %trimr('PO') + temp4a
     C                   move      oihord        temp2a
     C                   eval      oihcnm = %trimr(cname(1)) + ' ' + temp2a
     C                   movea     temp4a        adr1(1)
     C                   eval      oihca1 = adr1(1)
     C                   eval      oihca2 = *blanks
     C                   eval      oihcct = %trimr('Test') + ' ' + 'City'
     C                   eval      oihcst = 'IL'
     C                   eval      oihczp = %trimr('9') + temp4a
     C                   z-add     oihord        oihstp
640cAC                   eval      oihest = oihstp + 100
     C                   eval      oihmsc = %trimr(misc(1)) + ' ' + temp2a
700aAC                   if        $papck = 'Y'
700aAC                   eval      %subst(ohmms4: 13: 1) = 'Y'
700aAC                   eval      %subst(ohmms4: 14: 3) = $pacod
700aAC                   endif
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
416 AC                   write     oihrecf                              78
700aAC                   if        $papck = 'Y'
700aAC                   write     ohmrec                               78
700aAC                   endif
640bAC                   when      $pftp = 'S'
640bAC                   exsr      WriteOIHREC
640bDC**                 else
640bMC                   when      $pftp = 'X'
     C                   write     oihrec                               78
416 AC                   endsl
     *
     *    Get number of items for the order.
     *
     C                   call      'RANDOM2'
     C                   parm                    $rseed            9 9
     C                   parm      $pitm1        $rmin             6 0
     C                   parm      $pitm2        $rmax             6 0
     C                   parm                    $rnum             6 0
     C                   eval      items = $rnum
     *
     *    Loop for the number of items in the order.  Stop adding items
     *    when all compartments are filled.
     *
     C                   clear                   oidrec
     C                   eval      oidwhs = oihwhs
     C                   eval      oidord = oihord
     C     1             do        items         oidseq
     *
     C                   if        w1dryc >= drylow  and
     C                             w1refc >= reflow  and
     C                             w1frzc >= frzlow
     C                   leave
     C                   endif
     *
     *      Randomly select the item.  Loop until we get an item
     *      that fits within the remaining space of one of the compartments.
     *
404 AC                   eval      count = 0
404 AC                   eval      abort = *off
     C                   dow       forevr = forevr
404 A*
404 A*         Quit after 100 unsuccessful tries.
404 A*
404 AC                   add       1             count
404 AC                   if        count = 100
404 AC                   eval      abort = *on
404 AC                   leave
404 AC                   endif
     *
     C                   call      'RANDOM2'
     C                   parm                    $rseed
     C                   parm      1             $rmin
     C                   parm      maxlbl        $rmax
     C                   parm                    $rnum
     C                   eval      kylbl# = -($rnum)
     C     keylw         chain     worklbl                            79
     C                   if        *in79
     C                   iter
     C                   endif
404 AC                   if        $pdry = 0  and
404 AC                             lwcomp = 'D'  or
404 AC                             $pref = 0  and
404 AC                             lwcomp = 'R'  or
404 AC                             $pfrz = 0  and
404 AC                             lwcomp = 'F'
404 AC                   iter
404 AC                   endif
     C                   eval      oiditm = lwitem
     *
     *        Randomly determine pieces for item.
     *
     C                   call      'RANDOM2'
     C                   parm                    $rseed
     C                   parm      $ppcs1        $rmin
     C                   parm      $ppcs2        $rmax
     C                   parm                    $rnum
     *
     *        If item doesn't fit then try again.
     *
     C     $rnum         mult      lwucub        itmcub
     *
     C                   select
     C                   when      lwcomp = 'D'  and
     C                             itmcub > drylft
     C                   iter
     C                   when      lwcomp = 'R'  and
     C                             itmcub > reflft
     C                   iter
     C                   when      lwcomp = 'F'  and
     C                             itmcub > frzlft
     C                   iter
     C                   endsl
640aA
640aA*        Add item detail misc record if necessary.
640aA
640aAC                   if        $pftp = 'Y'
640aAC                   if        $pbpck = 'Y'
640aAC                   clear                   oimrecf
640aAC                   eval      oimwhs = oidwhs
640aAC                   eval      oimord = oidord
640aAC                   eval      oimseq = oidseq
640aAC                   eval      oimitm = oiditm
640aAC                   eval      oimms1 = 'Y'
640aAC                   write     oimrecf                              78
640aAC                   endif
640aAC                   endif
     *
     *        Otherwise, add item to order and update totals.
     *
     C                   z-add     $rnum         oidq1
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec
416 AC                   endsl
     *
     C                   select
     C                   when      lwcomp = 'D'
     C                   add       oidq1         w1dryp
     C                   add       itmcub        w1dryc
     C                   sub       itmcub        drylft
     C                   when      lwcomp = 'R'
     C                   add       oidq1         w1refp
     C                   add       itmcub        w1refc
     C                   sub       itmcub        reflft
     C                   when      lwcomp = 'F'
     C                   add       oidq1         w1frzp
     C                   add       itmcub        w1frzc
     C                   sub       itmcub        frzlft
     C                   endsl
     *
     *        Keep user informed.
     *
     C                   if        $pjtyp = *on
     C                   write     screen1
     C                   endif
     *
     C                   leave
     C                   enddo
     *
404 AC                   if        abort = *on
404 AC                   leave
404 AC                   endif
     C                   enddo
     *
404 AC                   if        abort = *on
404 AC                   leave
404 AC                   endif
     C                   enddo
     *
     C     bottom        tag
     *
     *  Keep user informed.
     *
     C                   if        $pjtyp = *on
     C                   eval      *in98 = *on
     C                   exfmt     screen1
     C                   endif
640bA*
640bA*  For staging files, immediatly do import
640bA*
640bAC                   if        $pftp = 'S'
640bAC                   exsr      DoImport
640bAC                   endif

     C                   eval      *inlr = *on
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
     *  Initialize variables
     *
     C                   eval      forevr = *on
     C                   eval      error = *off
     *
     *   Define keys
     *
     C                   eval      kytype = *blanks
     C     keyoih        klist
     C                   kfld                    kywhse
     C                   kfld                    kytype
     C                   kfld                    $prte
     *
     C     keyoid        klist
     C                   kfld                    oihwhs
     C                   kfld                    oihord
     *
     C     keylw         klist
     C                   kfld                    kylbl#
     *
     *   Open display file if this program is being run interactively.
     *
     C                   if        $pjtyp = *on
     C                   open      pck225fm
     C                   endif
416 A*
416 A*   Open import files.
416 A*
640bDC**                 if        $pftp = 'Y'
640bMC                   select
640bMC                   when      $pftp = 'F'
640aMC                   open      impfordh4
700aAC                   open      impfordhm
640aMC                   open      impfordd4
640aAC                   open      impforddm
640bDC**                 else
640bMC                   when      $pftp = 'X'
416 AC                   open      impordh1
700aAC                   open      impfordhm
416 AC                   open      impordd
416 AC                   endsl
     *
     *   Initialize message handling
     *
     C                   if        $pjtyp = *on
     C                   exsr      zmimsg
     C                   endif
     *
     *   Fool the compiler.
     *
     C                   eval      dummy = *blanks
     C                   if        dummy <> *blanks
     C                   read      pck225fm                               50
     C                   endif
     *
     C                   eval      $pprg = #prog
     C                   endsr

640bA*----------------------------------------------------------------
640bA*  DoImport     Call DktImport
640bA*----------------------------------------------------------------
640bA
640bA /free
640bA  begsr DoImport;

730aD    //DktImport(900: 'IMPROUTE': batId: 'I':
730aM    DktImport(kywhse: 'IMPROUTE': batId: 'I':
                   'PCK225': rtnCode: rtnMessage);

         if rtnCode <> '*OK';
           dsply rtnCode;
           dsply %subst(rtnMessage:1:32);
           return;
         endif;

       endsr;
      /end-free

640bA*----------------------------------------------------------------
640bA*  GetBatchId   Get batch id
640bA*----------------------------------------------------------------
640bA
640bA /free
640bA  begsr GetBatchId;

730aD    //GetBatId(900: 'IMPROUTE': 'R':
730aM    GetBatId(kywhse: 'IMPROUTE': 'R':
                  batId: rtnCode: rtnMessage);

         if rtnCode <> '*OK';
           dsply rtnCode;
           dsply %subst(rtnMessage:1:32);
           return;
         endif;

       endsr;
      /end-free

640bA*----------------------------------------------------------------
640bA*  WriteOrdD    Write Order Detail record
640bA*----------------------------------------------------------------
640bA
640bA /free
640bA  begsr WriteOIDREC;

         oidstatus = 'R';

730aA    // For Feature 3, fill in pick slot
730aA
730aA    if $gfFeature = '3';
730aA      oidslt = GetPickSlot;
730aA      oidblk = 'N';
730aA    endif;

         exec sql insert into impsordd
                  (oidwhs, oidbatid, oidordid,
                   oidstatus, oidststs, oidstsuc, oidtext,
                   oidord, oidseq, oiditm, oidq1, oidq2, oidq3,
                   oidwh2, oidor2, oidoit, oidspc, oidpo,
                   oimdsc, oimpds, oimrds, oimbox, oimexp,
                   oimms1, oimms2, oimms3, oimms4, oimms5,
730aA              oidslt, oidblk,
                   oidaddts, oidadduc)
                  values(:oidwhs, :batid, :oidordid, :oidstatus,
                         current_timestamp,
                         current_timestamp - current_timezone,
                         :oidtext, :oidord, :oidseq, :oiditm,
                         :oidq1, :oidq2, :oidq3,
                         :oidwh2, :oidor2, :oidoit, :oidspc, :oidpo, :oimdsc,
                         :oimpds, :oimrds, :oimbox, :oimexp, :oimms1, :oimms2,
                         :oimms3, :oimms4, :oimms5,
730aA                    :oidslt, :oidblk,
                         current_timestamp,
                         current_timestamp - current_timezone);

        if sqlstt <> sqlSuccess;
           rtnMessage = 'ORDD error - ' + sqlstt;
           dsply %subst(rtnMessage:1:32);
        endif;

       endsr;
      /end-free

640bA*----------------------------------------------------------------
640bA*  WriteOrdH    Write Order Header record
640bA*----------------------------------------------------------------
640bA
640bA /free
640bA  begsr WriteOIHREC;

         oihstatus = 'R';

         exec sql insert into impsordh
                  (oihwhs, oihbatid, oihrteid, oihordid,
                   oihstatus, oihststs, oihstsuc, oihtext,
                   oihord, oihtyp, oihcus, oihcpo, oihcnm,
                   oihca1, oihca2, oihcct, oihcst, oihczp,
                   oihrte, oihstp, oihtrk, oihmsc, ohmms1,
                   ohmms2, ohmms3, ohmms4, ohmms5,
640cM              oihaddts, oihadduc, oihest)
                  values(:oihwhs, :batid, :oihrteid, :oihordid, :oihstatus,
                         current_timestamp,
                         current_timestamp - current_timezone,
                         :oihtext, :oihord, :oihtyp, :oihcus, :oihcpo, :oihcnm,
                         :oihca1, :oihca2, :oihcct, :oihcst, :oihczp, :oihrte,
                         :oihstp, :oihtrk, :oihmsc, :ohmms1, :ohmms2, :ohmms3,
                         :ohmms4, :ohmms5,
                         current_timestamp,
640cM                    current_timestamp - current_timezone,
640cA                    :oihest);

        if sqlstt <> sqlSuccess;
           rtnMessage = 'ORDH error - ' + sqlstt;
           dsply %subst(rtnMessage:1:32);
        endif;

       endsr;
      /end-free

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
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCSBF  Clear message subfile.
     *
     C     zmcsbf        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
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
     C                   eval      $msgf = #msgf
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   UT81201  Item recalculated successfully.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'UT81201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81221  Item not recalculated - No ITEMQTY record.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'UT81221'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81222  Item not recalculated - Item does not exist.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'UT81222'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81223  Item not recalculated - Error updating ITEMQTY.
     *
     C     zm23          begsr
     C                   eval      #msgid = 'UT81223'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *---------------------------------------------------------------
     *  Sub Procedures
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     ** GetPickSlot
     *---------------------------------------------------------------
     *
     p GetPickSlot     b
     d GetPickSlot     pi            12
     *
     * Local Variables
     *
     d pWhse           s              3  0
     d pUser           s             10
     d pSlot           s             12
     d
     c                   call      'GETPCKSLT'
     c                   parm      kywhse        pwhse
     C                   parm                    oiditm
     c                   parm      ''            pUser
     c                   parm      ''            pSlot

     c                   return    pSlot
     P                 e

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**  CNAME
Test Customer
**  CADR1
9999 Mulberry Street
**  MISC
Order for Test
