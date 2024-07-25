     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IV565     FTP Export Pre-Post Inventory Quantity
     *  03 November 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
530 A*   11/03/09  MLB  5.30
     *     - Created.
     *     - Included custom client code support in program.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Inter County Bakers
     *
     *  03/06/12  LMC  ICB
     *    - Revised program to process the slot2 file instead of Invslot2
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Saval Foods
     *
SVL A*  11/12/09  MLB  SVL
     *    - Revised program to only send records from INVSLOT
     *      where IVSITM is greater than blanks. Per Gary P.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Grave's Menu Maker
     *
GMM A*  08/28/12  MLB  GMM
     *    - Revised program to process the slot2 file instead of Invslot2
     *    - Added GMM to ICB mod.
GMMaA*  08/28/12  MLB  GMMa
     *    - Revised program to retrieve base slot and send base slot in-
     *      stead of virtual slot to NDS.
     *    - Added file VSLOT1 to program.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Kohl Wholesale
     *
KHL A*  08/13/14  RTR  KHL
     *    - Revised program to process the slot2 file instead of Invslot2
     *    - Added KHL to ICB mod.
     *    - Revised program to retrieve base slot and send base slot in-
     *      stead of virtual slot to NDS.
     *    - Added file VSLOT1 to program.
KHLaA*  12/11/14  MLB  KHLa
     *    - Revised KHL mod to use SLOT2 file only when $PWHDP = *PSLT.
     *      This option is used to update each item's pick slot in NDS.
     *      Now when $PWHDP = *ALL, then all rcds from INVSLOT2 file
     *      will be sent. This will allow them to do physical inventory
     *      for a select set of slots.
KHLbA*  12/11/14  MLB  KHLb
     *    - Revised program to only send records from INVSLOT
     *      where IVSITM is greater than blanks. Per Gary P.
     *    - Added KHLb to SVL mod.
KHLcA*  12/18/14  MLB  KHLc
     *    - Revised program to retrieve SSB item number for parent item
     *      and load EVSDSG. Jim - NDS will mod his pgm to create 2
     *      rcds in his work file; 1 for case item/qty and 1 for
     *      each item/qty.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Williams Foods
     *
WIFa *  12/16/19  RTR  WIFa
     *    - Revised program to process the slot2 file instead of Invslot2
     *    - Added WIF to ICB mod.
WIFcA*  06/02/21  MLB  WIFc
     *    - Revised program to retrieve SSB item number for parent item
     *      and load EVSDSG. Jim - NDS will mod his pgm to create 2
     *      rcds in his work file; 1 for case item/qty and 1 for
     *      each item/qty.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Finvslot2  if   e           k disk
ICB AFslot2     if   e           k disk
KHLcAFitemlnk1  if   e           k disk
KHLcAFpiritem   if   e           k disk
GMM AFvslot1    if   e           k disk
     Fexpfinvs  o    e           k disk
     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------
     D client          s             10
     D clientloc       s             10
     D @getcl          c                   const('GETCLIENT')
SVL A /copy qcopysrc,id#saval
ICB A /copy qcopysrc,id#icb
GMM A /copy qcopysrc,id#gmm
KHL A /copy qcopysrc,id#khl
WIFaA /copy qcopysrc,id#wif
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3  0
     D forever         s              1
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     *
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
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $WHSE   Warehouse
     *      $WHDP   Warehouse department or *ALL
     *      $SECTN  Section type (B,F,P)
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $pwhdp            5
     C                   parm                    $pstyp            1
     *
     C                   move      $pwhs         $pwhse
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   select
     *      Process slots for all departments.
     C                   when      $pwhdp = '*ALL'
     C                   exsr      zzall
KHL A*
KHL A*      Default to *ALL for Kohl
KHL AC                   when      $pwhdp = '*PSLT'
KHL AC                             and (client = kohl
WIFaAC                             or client = WilliamsFoods)
KHL AC                   exsr      zzall
KHL A*
     C                   other
     *
     *      Process slots for single department.
     C                   exsr      zzdept
     C                   endsl
     *
     C                   eval      *inlr = *on
     C                   return
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
     *  Get client id
     *
     C                   call      @getcl
     C                   parm                    client
     C                   parm                    clientloc
KHLcA*
KHLcA*  Define key for ITEMLNK1 - Partial
KHLcA*
KHLcAC     keyil         klist
KHLcAC                   kfld                    $pwhse
KHLcAC                   kfld                    ivsitm
KHLcA*
KHLcA*  Define key for PIRITEM - Full
KHLcA*
KHLcAC     keyit         klist
KHLcAC                   kfld                    $pwhse
KHLcAC                   kfld                    ilitem
     *
     *  Define key for INVSLOT2 - Partial
     *
     C     keyivw        klist
     C                   kfld                    $pwhse
     *
     *  Define key for INVSLOT2 - Partial
     *
     C     keyivd        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     *
     *  Define key for INVSLOT2 - Full
     *
     C     *like         define    ivsstp        kystyp
     C     keyivf        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    kystyp
GMMbA*
GMMbA*  Define full key for VSLOT1 file.
GMMbA*
GMMbAC     keyvs1        klist
GMMbAC                   kfld                    slwhse
GMMbAC                   kfld                    slwhdp
GMMbAC                   kfld                    sldisp
     *
     C                   endsr
     *
     *------------------------------------------------------------
     *
     *  ZZALL   Process slots for all departments
     *
     C     zzall         begsr
     *
ICB AC                   if        client = ICB
GMM AC                             or client = menumaker
WIFaAC                             or client = WilliamsFoods
WIFaAC                                and $pwhdp = '*PSLT'
KHL AC                             or client = kohl
KHLaAC                             and $pwhdp = '*PSLT'
ICB AC     keyivw        setll     slot2
ICB AC                   else
     C     keyivw        setll     invslot2
ICB Ac                   endif
     *
     C                   dow       forever = forever
ICB AC                   if        client = ICB
GMM AC                             or client = menumaker
WIFaAC                             or client = WilliamsFoods
WIFaAC                                and $pwhdp = '*PSLT'
KHL AC                             or client = kohl
KHLaAC                                and $pwhdp = '*PSLT'
ICB AC     keyivw        reade     slot2
ICB AC                   else
     C     keyivw        reade     invslot2
ICB Ac                   endif
     C                   select
     *
GMM DC*                  when      %eof(slot2)  and client = ICB
GMM MC                   when      %eof(slot2)
GMM AC                             and (client = ICB
KHL AC                               or client = kohl
KHLaAC                                  and $pwhdp = '*PSLT'
WIFaAC                               or client = WilliamsFoods
WIFaAC                                  and $pwhdp = '*PSLT'
GMM AC                               or client = menumaker)
ICB AC                   leave
ICB A*
     C                   when      %eof(invslot2)
     C                   leave
     *
     *      Export both Fixed and PIR slots.
     C                   when          $pstyp = 'B'
     *      Export Fixed section slots.
     C                             or  $pstyp = 'F'
     C                             and ivsstp = $pstyp
ICB AC                             and client <> ICB
GMM AC                             and client <> menumaker
KHL AC                             and client <> kohl
WIFaAC                             and client <> WilliamsFoods
ICB A*
ICB AC                             or  $pstyp = 'F'
ICB AC                             and slstyp = $pstyp
GMM DC*                            and client = ICB
GMM MC                             and (client = ICB
KHL AC                              or  client = kohl
WIFaAC                              or  client = WilliamsFoods
GMM AC                              or  client = menumaker)
     *      Export PIR section slots.
     C                             or  $pstyp = 'P'
     C                             and ivsstp = $pstyp
ICB AC                             and client <> ICB
KHLaDC*                            and  client = kohl
KHLaMC                             and client <> kohl
GMM AC                             and client <> menumaker
WIFaAC                             and client <> WilliamsFoods
ICB A
ICB AC                             or  $pstyp = 'P'
ICB AC                             and slstyp = $pstyp
GMM DC*                            and client =  ICB
GMM MC                             and (client = ICB
KHL AC                              or  client = kohl
WIFaAC                              or  client = WilliamsFoods
GMM AC                              or  client = menumaker)
SVL A *
SVL AC                   if        client = Savalfoods
WIFaAC                             or client = WilliamsFoods
KHLbAC                             or client = Kohl
SVL A
KHLbAC                   select
KHLbAC                   when      client = Savalfoods
KHLbAC                             or client = Kohl
KHLbAC                                and $pwhdp = '*ALL'
WIFcAC                             or client = WilliamsFoods
WIFcAC                                and $pwhdp = '*ALL'
SVL A*      Export only slot rcds with item number assigned.
SVL AC                   if        ivsitm = ' '
SVL AC                   iter
SVL AC                   endif
SVL A
KHLbMC                   when          client = Kohl
KHLbAC                             and $pwhdp = '*PSLT'
WIFaAC                             or client = WilliamsFoods
WIFaAC                             and $pwhdp = '*PSLT'
KHLbA*      Export only slot rcds with item number assigned.
KHLbAC                   if        slitem = ' '
KHLbAC                   iter
KHLbAC                   endif
KHLbA
KHLbAC                   endsl
SVL A
SVL AC                   endif
     *
     *      Populate export file fields.
KHLcAC                   select
KHLcMC                   when      client = ICB
GMM AC                             or client = menumaker
WIFaAC                             or client = WilliamsFoods
WIFaAC                                and $pwhdp = '*PSLT'
KHL AC                             or client = kohl
KHLaAC                                and $pwhdp = '*PSLT'
ICB Ac                   exsr      zzfillevsicb
KHLcA*
KHLcAC                   when          client = Kohl
KHLcAC                             and $pwhdp = '*ALL '
KHLcAc                   exsr      zzfillevskhl
WIFcA*
WIFcAC                   when          client = WilliamsFoods
WIFcAC                             and $pwhdp = '*ALL '
WIFcAc                   exsr      zzfillevswif
KHLcA*
KHLcMc                   other
     C                   exsr      zzfillevs
KHLcMc                   endsl
     *
     *      Write record to export file.
     C                   exsr      zzwrite
     *
     C                   endsl
     *
     C                   enddo
     *
     C     endall        endsr
     *
     *------------------------------------------------------------
     *
     *  ZZDEPT   Process slots for single department
     *
     C     zzdept        begsr
     *
     C                   select
ICB A*      Process both Fixed/PIR slots in department for ICB
ICB AC                   when      client = ICB
GMM AC                             or client = menumaker
KHL AC                             or client = kohl
WIFaAC                             or client = WilliamsFoods
ICB AC     keyivd        setll     slot2
     *      Process both Fixed/PIR slots in department.
     C                   when      $pstyp = 'B'
     C     keyivd        setll     invslot2
     *
     C                   other
     *      Process either Fixed or PIR slots in department.
     C                   eval      kystyp = $pstyp
     C     keyivf        setll     invslot2
     C                   endsl
     *
     *
     C                   dow       forever = forever
     C                   select
ICB A*      Process both Fixed/PIR slots in department for icb
ICB AC                   when      client = ICB
GMM AC                             or client = menumaker
KHL AC                             or client = kohl
WIFaAC                             or client = WilliamsFoods
ICB AC     keyivd        reade     slot2
     *      Process both Fixed/PIR slots in department.
     C                   when      $pstyp = 'B'
     C     keyivd        reade     invslot2
     C                   other
     *      Process either Fixed or PIR slots in department.
     C     keyivf        reade     invslot2
     C                   endsl
     *
     C                   select
GMM DC*                  when      %eof(slot2) and client = ICB
GMM MC                   when      %eof(slot2)
GMM AC                             and (client = ICB
KHL AC                               or client = kohl
WIFaAC                               or client = WilliamsFoods
GMM AC                               or client = menumaker)
ICB AC                   leave
     C                   when      %eof(invslot2)
     C                   leave
     *
     C                   other
SVL A *
SVL AC                   if        client = Savalfoods
WIFaAC                             or client = WilliamsFoods
KHLbAC                             or client = Kohl
SVL A
SVL A*      Export only slot rcds with item number assigned.
SVL AC                   if        ivsitm = ' '
SVL AC                   iter
SVL AC                   endif
SVL A
SVL AC                   endif
     *
     *      Populate export file fields.
KHLcAc                   select
KHLcMc                   when      client = ICB
GMM Ac                             or client = menumaker
WIFaAC                             or client = WilliamsFoods
WIFaAC                                and $pwhdp = '*PSLT'
KHL Ac                             or client = kohl
KHLaAC                                and $pwhdp = '*PSLT'
ICB Ac                   exsr      zzfillevsicb
KHLcA*
KHLcAC                   when          client = Kohl
KHLcAC                             and $pwhdp = '*ALL '
KHLcAc                   exsr      zzfillevskhl
KHLcA*
WIFcAC                   when          client = WilliamsFoods
WIFcAC                             and $pwhdp = '*ALL '
WIFcAc                   exsr      zzfillevswif
KHLcA*
KHLcMc                   other
     C                   exsr      zzfillevs
KHLcMc                   endsl
     *
     *      Write record to export file.
     C                   exsr      zzwrite
     *
     C                   endsl
     *
     C                   enddo
     *
     C     enddept       endsr
     *
     *------------------------------------------------------------
     *
     *  ZZFILLEVS   Move file fields to export file fields.
     *
     C     zzfillevs     begsr
     *
     C                   clear                   evsrec
     *
     C                   eval      evswhs = ivswhs
     C                   eval      evspag = ivspag
     C                   eval      evsdsp = ivsdsp
     C                   eval      evssta = ivssta
     C                   eval      evswhd = ivswhd
     C                   eval      evsasl = ivsasl
     C                   eval      evsloc = ivsloc
     C                   eval      evslvl = ivslvl
     C                   eval      evshnd = ivshnd
     C                   eval      evsstp = ivsstp
     C                   eval      evsitm = ivsitm
     C                   eval      evssid = ivssid
     C                   eval      evsqt1 = ivsqt1
     C                   eval      evsqt2 = ivsqt2
     C                   eval      evsqt3 = ivsqt3
     C                   eval      evspdt = ivspdt
     C                   eval      evsptm = ivsptm
     C                   eval      evsedt = ivsedt
     C                   eval      evsetm = ivsetm
     C                   eval      evseby = ivseby
     C                   eval      evscdt = ivscdt
     C                   eval      evsctm = ivsctm
     C                   eval      evscby = ivscby
     C                   eval      evspex = ivspex
     C                   eval      evsadj = ivsadj
     C                   eval      evsdsg = ivsdsg
     C                   eval      evspck = ivspck
     *
     C     endfillevs    endsr
ICB A*------------------------------------------------------------
ICB A*
ICB A*  ZZFILLEVSICB Move file fields to export file fields.
ICB A*
ICB AC     zzfillevsicb  begsr
ICB A*
ICB AC                   clear                   evsrec
ICB A*
ICB AC                   eval      evswhs = slwhse
ICB AC                   eval      evspag = 0
GMMbA*
GMMbAC                   if        client = menumaker
KHL AC                             or client = kohl
WIFaAC                             or client = WilliamsFoods
GMMbA*     Retrieve base slot to send to Host.
GMMbAC                   if        slrsrv = 'V'
GMMbAC     keyvs1        chain     vslot1
GMMbAC                   if        %found(vslot1)
GMMbAC                   eval      sldisp = vspdis
GMMbAC                   endif
GMMbAC                   endif
GMMbA*
GMMbAC                   endif
GMMbA*
ICB AC                   eval      evsdsp = sldisp
ICB AC                   eval      evssta = slstat
ICB AC                   eval      evswhd = slwhdp
ICB AC                   eval      evsasl = slaisl
ICB AC                   eval      evsloc = slloc
ICB AC                   eval      evslvl = slrlvl
ICB AC                   eval      evshnd = slhand
ICB AC                   eval      evsstp = slstyp
ICB AC                   eval      evsitm = slitem
ICB AC                   eval      evssid = slside
ICB AC                   eval      evsqt1 = slstk1
ICB AC                   eval      evsqt2 = slstk2
ICB AC                   eval      evsqt3 = slstk3
ICB AC                   eval      evspdt = #jobdt
ICB AC                   eval      evsptm = #jobtm
ICB AC                   eval      evsedt = #jobdt
ICB AC                   eval      evsetm = #jobtm
ICB AC                   eval      evseby = #user
ICB AC                   eval      evscdt = 0
ICB AC                   eval      evsctm = 0
ICB AC                   eval      evscby = ' '
ICB AC                   eval      evspex = 'N'
ICB AC                   eval      evsadj = ' '
ICB AC                   eval      evsdsg = sldesg
ICB AC                   eval      evspck = slpick
ICB A*
ICB AC     endfillevsicb endsr
KHLcA*
KHLcA*------------------------------------------------------------
KHLcA*
KHLcA*  ZZFILLEVSKHL Move file fields to export file fields.
KHLcA*
KHLcAC     zzfillevskhl  begsr
KHLcA*
KHLcAC                   clear                   evsrec
KHLcA*
KHLcAC                   eval      evswhs = ivswhs
KHLcAC                   eval      evspag = ivspag
KHLcAC                   eval      evsdsp = ivsdsp
KHLcAC                   eval      evssta = ivssta
KHLcAC                   eval      evswhd = ivswhd
KHLcAC                   eval      evsasl = ivsasl
KHLcAC                   eval      evsloc = ivsloc
KHLcAC                   eval      evslvl = ivslvl
KHLcAC                   eval      evshnd = ivshnd
KHLcAC                   eval      evsstp = ivsstp
KHLcAC                   eval      evsitm = ivsitm
KHLcAC                   eval      evssid = ivssid
KHLcAC                   eval      evsqt1 = ivsqt1
KHLcAC                   eval      evsqt2 = ivsqt2
KHLcAC                   eval      evsqt3 = ivsqt3
KHLcAC                   eval      evspdt = ivspdt
KHLcAC                   eval      evsptm = ivsptm
KHLcAC                   eval      evsedt = ivsedt
KHLcAC                   eval      evsetm = ivsetm
KHLcAC                   eval      evseby = ivseby
KHLcAC                   eval      evscdt = ivscdt
KHLcAC                   eval      evsctm = ivsctm
KHLcAC                   eval      evscby = ivscby
KHLcAC                   eval      evspex = ivspex
KHLcAC                   eval      evsadj = ivsadj
KHLcAC**                 eval      evsdsg = ivsdsg
KHLcA*
KHLcA*      Look for SSB item linked to parent item. If found, load into
KHLcA*      slot designation field.
KHLcAC     keyil         setll     itemlnk1
KHLcAC                   dow       forever = forever
KHLcAC     keyil         reade     itemlnk1
KHLcAC                   if        %eof(itemlnk1)
KHLcAC                   leave
KHLcAC                   endif
KHLcA*
KHLcAC     keyit         chain     piritem
KHLcAC                   if            %found(piritem)
KHLcAC                             and ittype = 'S'
KHLcAC                   eval      evsdsg = %subst(ititem:1:5)
KHLcAC                   leave
KHLcAC                   endif
KHLcA*
KHLcAC                   enddo
KHLcA*
KHLcAC                   eval      evspck = ivspck
KHLcA*
KHLcAC     endfillevskhl endsr
WIFcA*
WIFcA*------------------------------------------------------------
WIFcA*
WIFcA*  ZZFILLEVSWIF Move file fields to export file fields.
WIFcA*
WIFcAC     zzfillevswif  begsr
WIFcA*
WIFcAC                   clear                   evsrec
WIFcA*
WIFcAC                   eval      evswhs = ivswhs
WIFcAC                   eval      evspag = ivspag
WIFcAC                   eval      evsdsp = ivsdsp
WIFcAC                   eval      evssta = ivssta
WIFcAC                   eval      evswhd = ivswhd
WIFcAC                   eval      evsasl = ivsasl
WIFcAC                   eval      evsloc = ivsloc
WIFcAC                   eval      evslvl = ivslvl
WIFcAC                   eval      evshnd = ivshnd
WIFcAC                   eval      evsstp = ivsstp
WIFcAC                   eval      evsitm = ivsitm
WIFcAC                   eval      evssid = ivssid
WIFcAC                   eval      evsqt1 = ivsqt1
WIFcAC                   eval      evsqt2 = ivsqt2
WIFcAC                   eval      evsqt3 = ivsqt3
WIFcAC                   eval      evspdt = ivspdt
WIFcAC                   eval      evsptm = ivsptm
WIFcAC                   eval      evsedt = ivsedt
WIFcAC                   eval      evsetm = ivsetm
WIFcAC                   eval      evseby = ivseby
WIFcAC                   eval      evscdt = ivscdt
WIFcAC                   eval      evsctm = ivsctm
WIFcAC                   eval      evscby = ivscby
WIFcAC                   eval      evspex = ivspex
WIFcAC                   eval      evsadj = ivsadj
WIFcAC**                 eval      evsdsg = ivsdsg
WIFcA*
WIFcA*      Look for SSB item linked to parent item. If found, load into
WIFcA*      slot designation field.
WIFcAC     keyil         setll     itemlnk1
WIFcAC                   dow       forever = forever
WIFcAC     keyil         reade     itemlnk1
WIFcAC                   if        %eof(itemlnk1)
WIFcAC                   leave
WIFcAC                   endif
WIFcA*
WIFcAC     keyit         chain     piritem
WIFcAC                   if            %found(piritem)
WIFcAC                             and ittype = 'S'
WIFcAC                   eval      evsdsg = %subst(ititem:1:5)
WIFcAC                   leave
WIFcAC                   endif
WIFcA*
WIFcAC                   enddo
WIFcA*
WIFcAC                   eval      evspck = ivspck
WIFcA*
WIFcAC     endfillevswif endsr
     *
     *------------------------------------------------------------
     *
     *  ZZWRITE   Write export record to file.
     *
     C     zzwrite       begsr
     *
     C                   write     evsrec
     *
     C     endwrite      endsr
