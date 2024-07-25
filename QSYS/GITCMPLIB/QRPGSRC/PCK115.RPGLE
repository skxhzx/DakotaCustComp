      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PCK115    Create test items for warehouse 900 - Create
     *  11 July 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    06/10/99  DAS  4.11
     *      - Created aisle DC, FC, PC and RC in Aisle maint.
     *      - Created routine CRTCOR to create a corresponding item
     *        (Alias, Contract or Same Slot Bkdn) for items in
     *        these new aisles.
     *      - Added mainline code to call new routine.
     *      - Added logic to create some items as Breakdown items.
     *        The items created will also have a corresponding
     *        Alias or Contract item.
416 A*    07/02/02  RH   4.16
     *      - Recompiled, ITEMMSC changed.
417aA*    04/03/03  RH   4.17a
     *      - Recompiled, ITEMMSC file changed.
     *
520aA*    01/26/09  DAS  5.20a
     *      - Revised to create ITEMMSC record.
     *
520bA*    06/15/09  DAS  5.20b
     *      - Revised to create DX breakdown items.
     *
730aA*    09/03/19  DAS  7.30
     *      - Converted to ILE
     *      - Added warehouse.
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    - Set item DA107 to Bulk='N' (Needed for test 9).
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
     Fpck115fm  cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fslot2     if   e           k disk
     Fpiritem   uf a e           k disk
     Fitemqty   uf a e           k disk
     Fitemdef   uf a e           k disk
411 AFitemlnk   uf a e           k disk
520aMFitemmsc   uf a e           k disk
411 AFitemdsc   uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D typ             s             25    dim(5) ctdata perrcd(1)
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
     D conful          s             15
     D dummy           s              1
     D error           s              1
     D forevr          s              1
     D kywhse          s                   like(slwhse)
     D lstasl          s              3
     D msgk            s              4  0
     D r               s              1  0
     D sclear          s              1
     D temp3a          s              3
     D temp5a          s              5
730aAD i               s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PJTYP  0 - Batch
     *              1 - Interactive
730aA*      $PWHSEA Warehouse
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pjtyp            1
730aAC                   parm                    $pwhsea           3 0
     *----------------------------------------------------------------
     *  Main line
     *
     *  Only work with warehouse 900.
730aA*  Now warehouse is sent in.
     *
730aDC**                 eval      kywhse = 900
      /free
740 A    monitor;
730aM    kywhse = %dec($pwhsea: 3: 0);
740 A    on-error;
740 A      kywhse=900;
740 A    endmon;
730aA    if kywhse < 900;
730aA      dsply 'Whse must be 900+';
730aA      return;
730aA     endif;
      /end-free
     *
     *  Delete all existing item records.
     *
     C                   exsr      delrec
     *
     *  Create new item records.
     *
     C                   eval      lstasl = *blanks
     C     keywh         setll     slot2
     C                   dou       forevr <> forevr
     C     keywh         reade     slot2                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *      Keep user informed if running interactively.
     *
     C                   if        $pjtyp = *on  and
     C                             slaisl <> lstasl
     C                   eval      w1aisl = slaisl
     C                   write     screen1
     C                   eval      lstasl = slaisl
     C                   endif
     *
     *      Only create items for fixed pick slots or 1st level pir slots.
     *
     C                   if        slstyp = 'F'  and
     C                             slpick <> 'Y'  or
     C                             slstyp = 'P'  and
     C                             slrlvl <> 1
     C                   iter
     C                   endif
     *
     *      Create item record.
     *
411 A*        For the below slots, create a Breakdown item . . .
411 A*
411 AC                   if        sldisp = 'DC-101-1'  or
411 AC                             sldisp = 'DC-102-1'  or
411 AC                             sldisp = 'FC-101-1'  or
411 AC                             sldisp = 'FC-102-1'  or
411 AC                             sldisp = 'PC-101-1'  or
411 AC                             sldisp = 'PC-102-1'  or
411 AC                             sldisp = 'RC-101-1'  or
411 AC                             sldisp = 'RC-102-1'  or
520bAC                             sldisp = 'DX-101-1'  or
520bAC                             sldisp = 'DX-102-1'  or
520bAC                             sldisp = 'DX-103-1'  or
520bAC                             sldisp = 'DX-104-1'
411 AC                   exsr      crtbkd
411 A*
411 A*        Otherwise, create a standard item.
411 A*
411 AC                   else
     C                   exsr      crtrec
411 AC                   endif
411 A*
411 A*      For items in aisle DC, FC, PC or RC . . .
411 A*        Create corresponding Alias, Contract or Same Slot Bkdn item.
411 A*
411 AC                   if        slaisl = ' DC'  or
411 AC                             slaisl = ' FC'  or
411 AC                             slaisl = ' PC'  or
411 AC                             slaisl = ' RC'
411 AC                   exsr      crtcor
411 AC                   endif
     *
     C                   enddo

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
     C     keywh         klist
     C                   kfld                    kywhse
     *
     C     keyit         klist
     C                   kfld                    ilwhse
     C                   kfld                    ilitm2
     *
     *   Open display file if this program is being run interactively.
     *
     C                   if        $pjtyp = *on
     C                   open      pck115fm
     C                   endif
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
     C                   read      pck115fm                               50
     C                   endif
     *
     C                   eval      $pprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CRTBKD  Create Breakdown item record.
     *
     C     crtbkd        begsr
     *
     *   Create ITEMLNK record.
     *
     C                   clear                   ilrec
730aDC**                 eval      ilwhse = 900
730aMC                   eval      ilwhse = kywhse
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm      slaisl        $cstr            30
     C                   movel(p)  $cstr         ilitem
     C                   move      slloc         temp3a
     C     ilitem        cat       temp3a:0      ilitem
     C     ilitem        cat       'B':0         ilitem
     C                   select
     C                   when      sldisp = 'DC-101-1'
     C                   eval      ilitm2 = 'DA101'
     C                   when      sldisp = 'DC-102-1'
     C                   eval      ilitm2 = 'DA102'
     C                   when      sldisp = 'FC-101-1'
     C                   eval      ilitm2 = 'FA101'
     C                   when      sldisp = 'FC-102-1'
     C                   eval      ilitm2 = 'FA102'
     C                   when      sldisp = 'PC-101-1'
     C                   eval      ilitm2 = 'PA101'
     C                   when      sldisp = 'PC-102-1'
     C                   eval      ilitm2 = 'PA102'
     C                   when      sldisp = 'RC-101-1'
     C                   eval      ilitm2 = 'RA101'
     C                   when      sldisp = 'RC-102-1'
     C                   eval      ilitm2 = 'RA102'
520bAC                   when      sldisp = 'DX-101-1'
520bAC                   eval      ilitm2 = 'DA101'
520bAC                   when      sldisp = 'DX-102-1'
520bAC                   eval      ilitm2 = 'DA102'
520bAC                   when      sldisp = 'DX-103-1'
520bAC                   eval      ilitm2 = 'DA103'
520bAC                   when      sldisp = 'DX-104-1'
520bAC                   eval      ilitm2 = 'DA104'
     C                   endsl
     C                   write     ilrec                                78
     *
     *   Create PIRITEM record.
     *
     C                   clear                   ititem
     C                   eval      itwhse = ilwhse
     C                   eval      ititem = ilitem
     C                   clear                   itdesc
     C     typ(5)        cat       ilitm2:1      itdesc
     C                   eval      itstyp = slstyp
     C                   eval      itwhdp = slwhdp
     C                   eval      itdesg = sldesg
     C                   eval      itactv = slactv
     C                   eval      ittype = 'B'
     C                   eval      itflgd = 'N'
     C                   eval      itflgb = 'N'
     C                   eval      itupc = *blanks
     C                   eval      itven# = 0
     C                   eval      itvit# = *blanks
     C                   eval      itrepl = 0
     C     'Pack'        cat       temp3a:1      itpdsc
     C                   eval      itum1 = 'EA'
     C                   eval      itum2 = *blanks
     C                   eval      itumq2 = 0
     C                   eval      itflg1 = 'N'
     C                   eval      itum3 = *blanks
     C                   eval      itumq3 = 0
     C                   eval      itflg2 = 'N'
     C                   eval      itulen = 3
     C                   eval      ituwdt = 3
     C                   eval      ituhgt = 3
     C                   eval      itcube = .25
     C                   eval      itswgt = 2.5
     C                   eval      itcwgt = 'N'
     C                   eval      itbld = slbld
     C                   eval      itslif = 0
     C                   eval      itnday = 0
     *
     C                   write     itrec                                78
520aA*
520aA*   Create ITEMMSC record.
520aA*
520aAC                   eval      imwhse = itwhse
520aAC                   eval      imitem = ititem
520aAC                   eval      immflg = 'N'
520aAC                   eval      imapck = 'N'
520aAC                   eval      imnrpk = 1
520aAC                   eval      imlot = 'N'
520aAC                   eval      imltrk = 'L'
520aA*
520aAC                   write     imrec                                78
     *
     *   Create ITEMQTY record.
     *
     C                   clear                   iqrec
     C                   eval      iqwhse = itwhse
     C                   eval      iqitem = ititem
     C                   write     iqrec                                78
     *
     *   Create ITEMDEF record.
     *
     C                   eval      idwhse = itwhse
     C                   eval      iditem = ititem
     C                   eval      idsdef = slsdef
     C                   eval      idtie = 40
     C                   eval      idhigh = 5
     C                   eval      idum = 'N'
     C                   eval      idpref = 'Y'
     C                   write     idrec                                78
     *
     C                   endsr
     *----------------------------------------------------------------
     *
411 A*  CRTCF   Create corresponding Contract full case item record.
     *
     C     crtcf         begsr
     *
     C                   dow       forevr = forevr
     *
     *   Create ITEMLNK record.
     *
     C                   eval      ilitem = ilitm3                              Contract Item
     C                   movel(p)  ilitm3        temp5a
     C                   eval      ilitm2 = temp5a                              Base Item
     C                   eval      ilitm3 = *blanks
     C                   write     ilrec                                78
     *
     *   Create PIRITEM record.
     *
     *     Note: By definition, the PIRITEM record for an Alias,
     *           Contract or SSB item should be identical to its
     *           Base item, except for the item number and description.
     *
     C     keyit         chain     piritem                            78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   eval      ititem = ilitem
     C                   clear                   itdesc
     C     typ(2)        cat       ilitm2:1      itdesc
     C                   eval      ittype = 'C'
     *
     C                   write     itrec                                78
     *
     *   Create ITEMQTY record for Contract item.
     *
     *     Note: By definition, an Alias and SSB item share the
     *           ITEMQTY record of their Base item, while a
     *           Contract item tracks its own quantities.
     *
     C                   if        ittype = 'C'
     C                   clear                   iqrec
     C                   eval      iqwhse = itwhse
     C                   eval      iqitem = ititem
     C                   write     iqrec                                78
     C                   endif
     *
     *   Create ITEMDEF record.
     *
     *     Note: By definition, the ITEMDEF records for an Alias,
     *           Contract or SSB item should be identical to its
     *           Base item.
     *
     C                   eval      idwhse = itwhse
     C                   eval      iditem = ititem
     C                   eval      idsdef = slsdef
     C                   eval      idtie = 10
     C                   eval      idhigh = 5
     C                   eval      idum = 'N'
     C                   eval      idpref = 'Y'
     C                   write     idrec                                78
     *
     C                   leave
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
411 A*  CRTCOR  Create corresponding item record.
     *
     C     crtcor        begsr
     *
     C                   dow       forevr = forevr
     *
     *   Determine which type of record to create.
     *
     C                   if        r >= 3
     C                   eval      r = 1
     C                   else
     C                   add       1             r
     C                   endif
     *
     C                   eval      conful = *blanks
     C                   select
     C                   when      r = 1                                        Alias
     C                   if        ittype <> ' '  and
     C                             ittype <> 'B'  and
     C                             ittype <> 'S'
     C                   iter
     C                   endif
     C                   eval      ittype = 'A'
     C                   when      r = 2                                        Contract
     C                   if        ittype <> ' '  and
     C                             ittype <> 'B'
     C                   iter
     C                   endif
     C                   if        ittype = 'B'
     C                   select
     C                   when      ititem = 'DC101B'
     C                   eval      conful = 'DA101C'
     C                   when      ititem = 'DC102B'
     C                   eval      conful = 'DA102C'
     C                   when      ititem = 'FC101B'
     C                   eval      conful = 'FA101C'
     C                   when      ititem = 'FC102B'
     C                   eval      conful = 'FA102C'
     C                   when      ititem = 'PC101B'
     C                   eval      conful = 'PA101C'
     C                   when      ititem = 'PC102B'
     C                   eval      conful = 'PA102C'
     C                   when      ititem = 'RC101B'
     C                   eval      conful = 'RA101C'
     C                   when      ititem = 'RC102B'
     C                   eval      conful = 'RA102C'
     C                   endsl
     C                   endif
     C                   eval      ittype = 'C'
     C                   when      r = 3                                        SSB
     C                   if        ittype <> ' '
     C                   iter
     C                   endif
     C                   eval      ittype = 'S'
     C                   endsl
     *
     *   Create ITEMLNK record.
     *
     C                   clear                   ilrec
     C                   eval      ilwhse = itwhse
     C     ititem        cat       ittype:0      ilitem                         New Item
     C                   eval      ilitm2 = ititem                              Base Item
     C                   eval      ilitm3 = conful                              Contract Full Case
     C                   write     ilrec                                78
     *
     *   Create PIRITEM record.
     *
     *     Note: By definition, the PIRITEM record for an Alias,
     *           Contract or SSB item should be identical to its
     *           Base item, except for the item number and description.
     *
     C                   eval      ititem = ilitem
     C                   clear                   itdesc
     C     typ(r)        cat       ilitm2:1      itdesc
     *
     C                   write     itrec                                78
     *
     *   Create ITEMQTY record for Contract item.
     *
     *     Note: By definition, an Alias and SSB item share the
     *           ITEMQTY record of their Base item, while a
     *           Contract item tracks its own quantities.
     *
     C                   if        ittype = 'C'
     C                   clear                   iqrec
     C                   eval      iqwhse = itwhse
     C                   eval      iqitem = ititem
     C                   write     iqrec                                78
     C                   endif
     *
     *   Create ITEMDEF record.
     *
     *     Note: By definition, the ITEMDEF records for an Alias,
     *           Contract or SSB item should be identical to its
     *           Base item.
     *
     C                   eval      idwhse = itwhse
     C                   eval      iditem = ititem
     C                   eval      idsdef = slsdef
     C                   eval      idtie = 10
     C                   eval      idhigh = 5
     C                   eval      idum = 'N'
     C                   eval      idpref = 'Y'
     C                   write     idrec                                78
     *
     C                   leave
     C                   enddo
     *
     *   Create Contract full case item if necessary.
     *
     C                   if        conful <> *blanks
     C                   exsr      crtcf
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CRTREC  Create item records for slot.
     *
     C     crtrec        begsr
     *
     *   Create PIRITEM record.
     *
730aDC**                 eval      itwhse = 900
730aMC                   eval      itwhse = kywhse
411 AC                   clear                   ititem
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm      slaisl        $cstr
     C                   movel(p)  $cstr         ititem
     C                   move      slloc         temp3a
     C     ititem        cat       temp3a:0      ititem
411 AC                   clear                   itdesc
411 MC     typ(4)        cat       ititem:1      itdesc
411 D*R         ITITEM    CAT  'Item':1  ITDESC
     C                   eval      itstyp = slstyp
     C                   eval      itwhdp = slwhdp
     C                   eval      itdesg = sldesg
     C                   eval      itactv = slactv
     C                   eval      ittype = ' '
     C                   eval      itflgd = 'N'
     C                   if        ititem = 'DA107'
     C                   eval      itflgb = 'N'
     C                   else
     C                   eval      itflgb = 'Y'
     C                   endif
     C                   eval      itupc = *blanks
     C                   eval      itven# = 0
     C                   eval      itvit# = *blanks
     C                   eval      itrepl = 0
     C     'Pack'        cat       temp3a:1      itpdsc
     C                   eval      itum1 = 'CS'
411 D*R                   MOVE *BLANKS   ITUM2
411 D*R                   Z-ADD0         ITUMQ2
411 MC                   eval      itum2 = 'EA'
411 MC                   eval      itumq2 = 4
     C                   eval      itflg1 = 'N'
     C                   eval      itum3 = *blanks
     C                   eval      itumq3 = 0
     C                   eval      itflg2 = 'N'
     C                   eval      itulen = 12
     C                   eval      ituwdt = 12
     C                   eval      ituhgt = 12
     C                   eval      itcube = 1
     C                   eval      itswgt = 10
     C                   eval      itcwgt = 'N'
     C                   eval      itbld = slbld
     C                   eval      itslif = 0
     C                   eval      itnday = 0
     *
     C                   write     itrec                                78
520aA*
520aA*   Create ITEMMSC record.
520aA*
520aAC                   eval      imwhse = itwhse
520aAC                   eval      imitem = ititem
520aAC                   eval      immflg = 'N'
520aAC                   eval      imapck = 'N'
520aAC                   eval      imnrpk = 1
520aAC                   eval      imlot = 'N'
520aAC                   eval      imltrk = 'L'
520aA*
520aAC                   write     imrec                                78
     *
     *   Create ITEMQTY record.
     *
     C                   clear                   iqrec
     C                   eval      iqwhse = itwhse
     C                   eval      iqitem = ititem
     C                   write     iqrec                                78
     *
     *   Create ITEMDEF record.
     *
     C                   eval      idwhse = itwhse
     C                   eval      iditem = ititem
     C                   eval      idsdef = slsdef
     C                   eval      idtie = 10
     C                   eval      idhigh = 5
     C                   eval      idum = 'N'
     C                   eval      idpref = 'Y'
     C                   write     idrec                                78
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  DELREC  Delete existing item records for warehouse 9.
     *
     C     delrec        begsr
     *
     *   Keep user informed if running interactively.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1aisl = 'DEL'
     C                   write     screen1
     C                   eval      lstasl = slaisl
     C                   endif
     *
     *   Delete PIRITEM records.
     *
     C     keywh         setll     piritem
     C                   dou       forevr <> forevr
     C     keywh         reade     piritem                                78
     C                   if        *in78
     C                   leave
     C                   else
     C                   delete    itrec
     C                   endif
     C                   enddo
     *
     *   Delete ITEMQTY records.
     *
     C     keywh         setll     itemqty
     C                   dou       forevr <> forevr
     C     keywh         reade     itemqty                                78
     C                   if        *in78
     C                   leave
     C                   else
     C                   delete    iqrec
     C                   endif
     C                   enddo
     *
     *   Delete ITEMDEF records.
     *
     C     keywh         setll     itemdef
     C                   dou       forevr <> forevr
     C     keywh         reade     itemdef                                78
     C                   if        *in78
     C                   leave
     C                   else
     C                   delete    idrec
     C                   endif
     C                   enddo
     *
411 A*   Delete ITEMLNK records.
     *
     C     keywh         setll     itemlnk
     C                   dou       forevr <> forevr
     C     keywh         reade     itemlnk                                78
     C                   if        *in78
     C                   leave
     C                   else
     C                   delete    ilrec
     C                   endif
     C                   enddo
     *
411 A*   Delete ITEMMSC records.
     *
     C     keywh         setll     itemmsc
     C                   dou       forevr <> forevr
     C     keywh         reade     itemmsc                                78
     C                   if        *in78
     C                   leave
     C                   else
     C                   delete    imrec
     C                   endif
     C                   enddo
     *
411 A*   Delete ITEMDSC records.
     *
     C     keywh         setll     itemdsc
     C                   dou       forevr <> forevr
     C     keywh         reade     itemdsc                                78
     C                   if        *in78
     C                   leave
     C                   else
     C                   delete    ixrec
     C                   endif
     C                   enddo
     *
     C                   endsr
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
**  TYP  -  Record types
Alias item for
Contract item for
Same Slot Bkdn item for
Standard item
Breakdown item for
