      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2021 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  GetSelMth   Get Selection method.
      *  29 June 2021
      *  Lynn McMahon
      *
      *  Revisions:
      *
750 A *    06/29/21  LMC  7.50
      *      - Created.
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
     fupc5      if   e           k disk
     fgloucicd  if   e           k disk
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
     d GetItem         pr
     *----------------------------------------------------------------
     *  *GENPICK -  General picking options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N)
     *    OPRFWC  -  Using RF will call (Y,N).
     *    OPNRSC  -  Number of pallet sections (1-9).
     *    OPHPWC  -  Host pick Will Call (Y/N).
     *    OPMRGA  -  Merge Add-on order(s) with Open Routes.
     *    OPPLSQ  -  Pallet number sequence. 1=Unload, 2=Load.
     *    OPEADJ  -  Close short labels without adjustment (Y,N).
     *    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
     *    OPGPK1  -  <Not Used / Available>
     *    OPGPK2  -  <Not Used / Available>
     *               task has been assigned. (Y/N)
     *    OPJITR  -  Create JIT Letdown or JIT Replenishment
     *                 0=None. No replenishments are created.
     *                 1=Letdowns are created during Truck Builder
     *                   Pick/Print processing.
     *                 2=Priority Replenishments are created during
     *                   Truck Builder Pick/Print processing.
     *                 3=JIT Letdowns created when transaction is
     *                   checked out.
     *                 4=JIT Priority Replenishments created when
     *                   transaction is checked out.
     *    OPPSET  -  Print separate set summary label for each pallet.
     *    OPRFUC  -  RF Pick Verify item with UPC.
     *    OPRFLC  -  RF Pick Verify item with license.
     *    OPUSF1  -  USF Option: Allow merge items for stop to be split.
     *               across truck pallets.
     *    OPRFSL  -  RF Pick Verify slot (Y/N)
     *    OPRBN1  -  Round robin printing compatable (Y/N)
     *    OPRBN2  -  Round robin Type ing compatable (Y/N)
     *               1=Off
     *               2=By route
     *               3=By transaction
     *    OPSUBT  -  Allow Customer Item Substitution (Y/N)
     *    OPRFQT  -  RF Pick Allow Qty Entry (Y,N)
     *    OPRFCS  -  RF Pick Allow Change Slot (Y,N)
     *    OPPMTA  -  USF Option: Allow multi-truck assignments.
     *    OPMAXA  -  USF Option: Staged route selection limit.
     *    OPDOCK  -  USF Option: Dock door prompt choice.
     *    OPRFQO  -  RF with Qty over.
     *    OPRFPM  -  RF Pick Method.
     *    OPRPLT  -  Print Pallet Label.
     *    OPRFUI  -  Scan individual UPC for each unit.
     *    OPRFZP  -  Zone Pickup.
     *    OPRFUW  -  Auto load weight if found in individual upc
     *    OPRVUP  -  RF Location verification UPC
     *    OPRVSL  -  RF Location verification Slot
     *    OPRVCD  -  RF Location verification Check Digit
     *
     * Data structure
     *
     D opdata          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4  0
     D  ophpwc                 5      5
     D  opmrga                 6      6
     D  opplsq                 7      7
     D  opeadj                 8      8
     D  opnopk                 9      9
     D  opjitr                12     12
     D  oppset                13     13
     D  oprfuc                14     14
     D  oprflc                15     15
     D  opusf1                16     16
     D  oprfsl                17     17
     D  oprbn1                18     18
     D  oprbn2                19     19
     D  opsubt                20     20
     D  oprfqt                21     21
     D  oprfcs                22     22
     D  oppmta                23     23
     D  opmaxa                24     25  0
     D  opmaxab               24     25
     D  opdock                26     26
     D  oprfqo                27     29  0
     D  oprfpm                30     30
     D  oprplt                31     31
     D  oprfui                32     32
     D  oprfzp                33     33
     D  oprfuw                34     34
     D  oprvup                36     36  0
     D  oprvsl                37     37  0
     D  oprvcd                38     38  0
     D  optend               117    117
      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pCommand       s             10
     D  pWhse          s              3p 0
     D  pItem          s             15
     D  plbutyp        s              1
     D  plbucod        s              2
     D  pUPCExist      s              1
     D  pSelmth        s             20

     *
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     d driItemCalled   s               n
     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------
     D locvfysl        s                   like(oprvsl)
     D locvfyup        s                   like(oprvup)
     D locvfycd        s                   like(oprvcd)
     D locpriority     s                   like(pselmth)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)
     *----------------------------------------------------------------
     * DRI Parms
     *----------------------------------------------------------------


      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------
      /copy qcopysrc,p.driitem


     *----------------------------------------------------------------
     *  Command Notes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D ibrec         e ds                  extname(itembrd)

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pCommand     Command
     *      pWhse        Warehouse
     *      pItem        Item
     *      plbutyp      label unit type
     *      plbucod      label uom code
     *      pUPCExist    Returned UPC Exist
     *      pSelMth      Returned Selection method
     *
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pCommand
     c                   parm                    pWhse
     c                   parm                    pItem
     c                   parm                    plbutyp
     c                   parm                    plbucod
     c                   parm                    pUPCExist
     c                   parm                    pSelMth

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;
        // get selection type
        getItem();
        pselmth = ' ';
        pUPCExist = ' ';
        // do we have a upc on file
        chain (pwhse:pitem:plbutyp:plbucod) upc5;
        if %found(upc5);
          pUPCExist = 'Y';
        endif;
        select;
          when $ifsltmth = '1' and oprfuc = 'Y';
            if pUPCExist = 'Y';
              Pselmth = 'UPC Verification';
            else;
              Pselmth = 'Standard';
            endif;
          when $ifsltmth = '2';
            exsr zzmthdesc;
          when $ifsltmth = '4';
            exsr zzmthdesc;
          when $ifsltmth = '5';
            exsr zzmthdesc;
          when $ifsltmth = '6';
            exsr zzmthdesc;
          when locvfysl > 0 or locvfyup > 0 or locvfycd >0;
            // location verification priority
            Select;
              when locvfysl = 1;
                locpriority = 'Slot';
              when locvfyup = 1 and pUPCExist = 'Y';
                locpriority = 'UPC';
              when locvfycd = 1;
                locpriority = 'CD';
            endsl;
            Select;
              when locvfysl = 2;
                if locpriority <> ' ';
                  locpriority = %trim(locpriority) + ',';
                endif;
                locpriority = %trim(locpriority) + 'Slot';

              when locvfyup = 2 and pUPCExist = 'Y';
                if locpriority <> ' ';
                  locpriority = %trim(locpriority) + ',';
                endif;
                locpriority = %trim(locpriority)  + 'UPC';
              when locvfycd = 2;
                if locpriority <> ' ';
                  locpriority = %trim(locpriority) + ',';
                endif;
                locpriority = %trim(locpriority) +  'CD';
            endsl;
            Select;
              when locvfysl = 3;
                if locpriority <> ' ';
                  locpriority = %trim(locpriority) + ',';
                endif;
                locpriority = %trim(locpriority) +  'Slot';
              when locvfyup = 3 and pUPCExist = 'Y';
                if locpriority <> ' ';
                  locpriority = %trim(locpriority) + ',';
                endif;
                locpriority = %trim(locpriority) + 'UPC';
              when locvfycd = 3;
                if locpriority <> ' ';
                  locpriority = %trim(locpriority) + ',';
                endif;
                locpriority = %trim(locpriority) + 'CD';
            endsl;
            pselMth = %trim(locpriority);
          when $ifsltmth = '1' or $ifsltmth = '3';
            exsr zzmthdesc;
            //pselMth = 'Scan Not Enabled';
        endsl;
        if driItemCalled;
           driItem('%CLOSE': $pprogram: $drireturn: $drimessage:
                    $dridata: $dridata2);
        endif;
      /end-free
      *----------------------------------------------------------
      *  zzmthdesc get method description
      *----------------------------------------------------------

      /free
        begsr zzmthdesc;

          // get description for selection method
          chain ('UCI3': $ifsltmth) gloucicd;
          pselmth= ' ';
          if %found(gloucicd);
            pselmth= gucdsc;
          endif;

         endsr;

      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
          begsr *INZSR;

         chain (pWhse:'*GENPICK') options;
         if not %found(options);
           oprfuc = 'N';
           oprvup = 0;
           oprvsl = 0;
           oprvcd = 0;
         endif;
         Monitor;
         Eval locvfyup= %Dec(oprvup:1:0);
         On-Error;
         Eval locvfyup= 0;
         Endmon;
         Monitor;
         Eval locvfysl= %Dec(oprvsl:1:0);
         On-Error;
         Eval locvfysl= 0;
         Endmon;
         Monitor;
         Eval locvfycd= %Dec(oprvcd:1:0);
         On-Error;
         Eval locvfycd= 0;
         Endmon;

           endsr;

      /end-free

     *----------------------------------------------------------------
     *  getItem  Get item info.
     *----------------------------------------------------------------

     p GetItem         b
     d GetItem         pi

      /free

         error = *off;

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itwhse = pwhse;
         $ititem = pitem;
         $dridata = $item;
         $dridata2 = $item2;

         driItemCalled = *on;
         driItem('%GETALL': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;


      /end-free

     p GetItem         e

