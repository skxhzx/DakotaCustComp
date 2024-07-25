      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  SAPIMP     Import SAP route file to BFC import files
     *  March 15, 2011
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640a *    03/15/12  RTR  6.40a
     *      - Created.
640b *    06/07/12  RTR  6.40b
     *      - Changed Stop break from 'AG' record to 'WE' record.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     fsapimpf   if   e           k disk
     fimpfitm3  uf a e           k disk
     fimpfitmm  uf a e           k disk
     fimpfstuf3 uf a e           k disk
     fimpfordh5 uf a e           k disk
     fimpfordhm uf a e           k disk
     fimpfordd5 uf a e           k disk
     fimpforddm uf a e           k disk
     ftruckdft  if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
      /copy qcopysrc,id#agar

     *----------------------------------------------------------------
     *  SAP Formats
     *----------------------------------------------------------------
      /copy qcopysrc,s#edidc40
      /copy qcopysrc,s#e1adrm1
      /copy qcopysrc,s#e1adrm4
      /copy qcopysrc,s#e1edk33
      /copy qcopysrc,s#e1edl20a
      /copy qcopysrc,s#e1edl24a
      /copy qcopysrc,s#e1edl26a
      /copy qcopysrc,s#e1edl27
      /copy qcopysrc,s#e1edt10
      /copy qcopysrc,s#e1edt20
      /copy qcopysrc,s#e1edt22
      /copy qcopysrc,s#z1deldta
      /copy qcopysrc,s#z1itmdta
      /copy qcopysrc,s#z1shpdta

     *----------------------------------------------------------------
     *  BFC Import Formats
     *----------------------------------------------------------------
      /copy qcopysrc,ikmsc4_asc

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     d forever         s               n   inz('1')
     d sapformat       s             10a
     d client          s             10a
     d clientloc       s             10a
     d holdroute       s              3a
     d holdstop        s              3s 0
     d holdcust        s             11a
     d holddseq        s              3s 0
     d loadwhse        s              3s 0 inz(306)
     d workcube        s             10s 5
     d workweight      s             10s 5
     d workuom1        s              2a
     d workuom2        s              2a
     d workumq2        s              3s 0
     d workumf1        s              1a
     d worktruck       s             10a

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------
     d editw3          c                   '0   '

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *----------------------------------------------------------------
     d GetClientPgm    pr                  extpgm('GETCLIENT')
     d  pclient                      10a
     d  pClientloc                   10a

     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------
      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Program Prototype
     *----------------------------------------------------------------
     d SapMain         pr                  extpgm('SAPIMP')
     d                                5
     d SapMain         pi
     d  rtnrte                        5a

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

         // Only do this if customer is Agar
         dow client = agar;

           read sapimpr;
           if %eof(sapimpf);
             leave;
           endif;

           // Get first 10 for record format
           sapformat = %subst(saprec:1:10);

           // Process based on record format
           select;

             // SAP IDoc Central Address Seg Grp, Main Seg 1
             when sapformat = sap_e1adrm1;
               exsr ze1adrm1;

             // SAP IDoc Central Address Seg Grp, Main Seg 4
             when sapformat = sap_e1adrm4;
               exsr ze1adrm4;

             // SAP IDoc Shipment Stage
             when sapformat = sap_e1edk33;
               exsr ze1edk33;

             // SAP IDoc Delivery Header
             when sapformat = sap_e1edl20;
               exsr ze1edl20;

             // SAP IDoc Delivery Item
             when sapformat = sap_e1edl24;
               exsr ze1edl24;

             // SAP IDoc Delivery Item Addl Data Desc
             when sapformat = sap_e1edl26;
               exsr ze1edl26a;

             // SAP IDoc Delivery Item Addl Data Desc
             when sapformat = sap_e1edl27;
               exsr ze1edl27;

             // SAP IDoc Control Date
             when sapformat = sap_e1edt10;
               exsr ze1edt10;

             // SAP IDoc Shipment Record
             when sapformat = sap_e1edt20;
               exsr ze1edt20;

             // SAP IDoc Shipment Descriptions
             when sapformat = sap_e1edt22;
               exsr ze1edt22;

             // SAP Delivery Header (for pick file to Lucas)
             when sapformat = sap_z1deldta;
               exsr zz1deldta;

             // SAP Item Header (for pick file to Lucas)
             when sapformat = sap_z1itmdta;
               exsr zz1itmdta;

             // SAP Shipment Header (for file to Lucas)
             when sapformat = sap_z1shpdta;
               exsr zz1shpdta;

           endsl;

         enddo;

         rtnrte = sap_route;
         *inlr = *on;
      /end-free

     *----------------------------------------------------------------
     *          Subroutines in Alphabetical Order
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Write Item Records
     *----------------------------------------------------------------
      /free
        begsr WrtItem;

          // write info to Item Import file
          IUWHSE = loadwhse;
          if %subst(sap_matnr:1:3) = '000';
             IUITEM = %subst(sap_matnr:4:15);
          else;
             IUITEM = sap_matnr;
          endif;

          IUUTYP = 'U';
          IUTYPE = ' ';
          IUSTYP = 'F';
          IUDESC = sap_arktx;
          IUWHDP = %subst(sap_picksection:1:5);
          IUPDSC = sap_paksizdsc;
          if sap_catchwgtflg = '1';
            IUCWGT = 'Y';
          else;
            IUCWGT = 'N';
          endif;

          //workcube = %dec(sap_umvkz:6:0) * %dec(sap_itemcube:5:3)
          //           / %dec(sap_umvkn:6:0);
          //workweight = %dec(sap_umvkz:6:0) * %dec(sap_ntgew:7:2)
          //             / %dec(sap_umvkn:6:0);
          //else;
          //workcube = %dec(sap_itemcube:5:3);
          //workweight = %dec(sap_ntgew:7:2);

          // If UOM = PCE or PC
          // Cube and weight provided by SAP are ALWAYS at case level.
          // Per Agar, if we get piece (each) here it is ALWAYS sold
          //   at piece (each) level so use that for item UOM in BFC
          if sap_vrkme = 'PCE'
           or sap_vrkme = 'PC ';     // if this record is piece order
            workuom1 = 'CS';        // set normal unit as case
            workuom2 = 'PC';        // set breakdown as piece
            workumf1 = 'Y';         // set breakdown flag
            if %dec(sap_umvkn:6:0) > 0;
              workumq2 = %dec(sap_umvkn:6:0) / %dec(sap_umvkz:6:0);
            else;
              workumq2 = %dec(sap_umvkn:6:0);
            endif;
          else;
            workuom1 = 'CS';        // set normal unit as case
            workuom2 = '  ';        // set breakdown off
            workumq2 = 0;           // set breakdown qty 0
            workumf1 = ' ';         // set breakdown flag off
          endif;
          workcube = %dec(sap_itemcube:5:3);
          workweight = %dec(sap_ntgew:7:2) / %dec(sap_ormng:15:5);

          chain (iuwhse : iuitem) iurec;
          if not %found(impfitm3);
            IUCUBE = workcube;
            IUSWGT = workweight;
            IUUM1  = workuom1;
            IUUM2  = workuom2;
            IUUMQ2 = workumq2;
            IUFLG1 = workumf1;
            write iurec;
          else;
            if IUCUBE = 0;  // only update cube if stored cube is zero
              IUCUBE = workcube;
            endif;
            if IUSWGT = 0;  // only update weight if stored weight is zero
              IUSWGT = workweight;
            endif;
            if IUUM1 = *blank;  // only update UOM1 if stored UOM1 is blank
              IUUM1  = workuom1;
            endif;
            if IUUM2 = *blank;  // only update UOM2 if stored UOM2 is blank
              IUUM2  = workuom2;
              IUUMQ2 = workumq2;
              IUFLG1 = workumf1;
            endif;
            update iurec;
          endif;

          // write info to Item Import Misc file
          IMPUTP = 'C';
          IMPWHS = loadwhse;
          IMPITM = IUITEM;
          %subst(IMPMS1:1:1) = sap_enfcatchwgt;
          %subst(IMPMS1:2:1) = sap_pctabswgtfl;
          %subst(IMPMS1:33:1) = sap_expdatflg;
          %subst(IMPMS1:34:1) = sap_enfexpdat;
          %subst(IMPMS1:35:1) = sap_expdatfmt;
          %subst(IMPMS1:36:3) = sap_daystoexp;
          %subst(IMPMS1:39:1) = sap_upcflag;
          IMPMS2 = sap_upcchkfrq + sap_itemprice + sap_upc1
                 + sap_pirpick + sap_isflow;
          IMPMS3 = sap_upc2 + sap_upc3;
          ascik4_vendorco = sap_vendcode;
          ascik4_prodh = sap_prodh;
          IMPMS4 = ascik4_base;

          chain (impwhs : impitm) imprec;
          if not %found(impfitmm);
            write imprec;
          else;
            update imprec;
          endif;

          // write info to Order Detail file
          holddseq = holddseq + 1;
          oidwhs = loadwhse;
          oidord = oihord;
          oidseq = holddseq;
          oiditm = iuitem;

          if sap_vrkme = 'PCE'
           or sap_vrkme = 'PC ';     // if this record is piece order
            if sap_ormng = *blanks;
              oidq2 = 0;
              oidq1 = 0;
            else;
              oidq2  = %dec(sap_ormng:15:5);
              oidq1 = 0;
            endif;
          else;
            if sap_ormng = *blanks;
              oidq2 = 0;
              oidq1 = 0;
            else;
              oidq2 = 0;
              oidq1  = %dec(sap_ormng:15:5);
            endif;
          endif;

          oidslt = sap_lgpbe;
          oidblk = 'N';
          write oidrec;

          // write info to Order Detail Misc file
          oimwhs = loadwhse;
          oimord = oihord;
          oimseq = holddseq;
          oimitm = iuitem;
          oimms1 = sap_vbeln + sap_posnr;
          oimms2 = sap_prodh_bez;  // Commodity Desc
          if %subst(sap_lgpbe:3:1) = '-';
            oimms3 = %subst(sap_lgpbe:1:2) + %subst(sap_lgpbe:4:2) +
                     %subst(sap_lgpbe:7:2);
          else;
            oimms3 = %subst(sap_lgpbe:1:6);
          endif;
          %subst(oimms4:1:8) = sap_minweight;
          %subst(oimms4:9:8) = sap_maxweight;
          %subst(oimms4:17:8) = sap_absminwgt;
          %subst(oimms4:25:8) = sap_absmaxwgt;
          %subst(oimms4:33:8) = sap_avgwgt;
          write oimrec;

          // write info to Slot Stuffit file
          SIWHSE = loadwhse;
          SIWHDP = %subst(sap_picksection:1:5);
          SIDISP = sap_lgpbe;
          SIITEM = *blank;
          SIFIFO = 0;
          SISTYP = 'F';
          SIPICK = 'Y';
          SIRSRV = 'Y';
          SIQTY1 = 0;
          SIQTY2 = 0;
          SIQTY3 = 0;
          if SIDISP <> *blanks;
            chain (siwhse : siwhdp : sidisp) sirec;
            if not %found(impfstuf3);
              write sirec;
            else;
              update sirec;
            endif;
          endif;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *   Write Order/Route Records
     *----------------------------------------------------------------
      /free
        begsr WrtOrder;

          holdstop = holdstop + 1;
          oihwhs = loadwhse;
          oihrte = sap_route;
          oihord = %dec(sap_route + %trim(%editw(holdstop:editw3)):6:0);
          oihcus = %dec(sap_partner_id1:10:0);
          if %error();
            oihcus = 0;
          endif;
          oihcnm = sap_name11;      // Cust Name
          oihca1 = sap_street11;    // Cust Addr1
          oihca2 = sap_street21;    // Cust Addr2
          oihcct = sap_city1;
          oihcst = sap_region;      // State
          oihczp = sap_postl_cod1;  // Zip
          oihest = holdstop;
          //oihmsc = sap_ntanf + sap_country1; // Ship Date + Country
          if sap_palletstop = 'Y';
            oihmsc = '#SP';
          endif;

          // Get default truck template from Dakota Table
          exsr zzgettruck;
          oihtrk = worktruck;

          write oihrec;

          ohmwhs = loadwhse;
          ohmord = oihord;
          ohmms1 = sap_route_bez;
          ohmms2 = %subst(sap_telephone1:1:10)
                 + %subst(sap_telephone2:1:10);
          ohmms3 = sap_drivername;
          ohmms4 = sap_dispatchtim + sap_auditpct
                 + sap_drivercode + sap_trailernumb
                 + sap_country1 + sap_ntanf;
          write ohmrec;

          holdcust = sap_partner_id1;
          holddseq = 0;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *   Move Flat Records to SAP Formats
     *----------------------------------------------------------------
      /free
        begsr ze1adrm1;
          s#e1adrm1 = saprec;

          // If customer has changed, it is new stop and BFC order
        // 640bD  if sap_partner_q1 = 'AG '
          if sap_partner_q1 = 'WE '
           and holdcust <> sap_partner_id1;
            exsr WrtOrder;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr ze1adrm4;
          s#e1adrm4 = saprec;
        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr ze1edk33;
          s#e1edk33 = saprec;
        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr ze1edl20;
          s#e1edl20a = saprec;
        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr ze1edl24;
          s#e1edl24a = saprec;
        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr ze1edl26a;
          s#e1edl26a = saprec;
        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr ze1edl27;
          s#e1edl27 = saprec;
          exsr WrtItem;
        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr ze1edt10;
          s#e1edt10 = saprec;
        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr ze1edt20;
          s#e1edt20 = saprec;
        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr ze1edt22;
          s#e1edt22 = saprec;
        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr zz1deldta;
          s#z1deldta = saprec;
        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr zz1itmdta;
          s#z1itmdta = saprec;
        endsr;
      /end-free
     *----------------------------------------------------------------
      /free
        begsr zz1shpdta;
          s#z1shpdta = saprec;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *  zzgettruck  Get Default Truck
     *----------------------------------------------------------------
      /free
        begsr zzgettruck;

          worktruck = *blanks;
          setll (loadwhse : *blanks) truckdft;
          dou forever <> forever;
            read truckdft;
            if %eof(truckdft);
              leave;
            endif;
            if %subst(sap_trailernumb:1:4) = %subst(tdrte:1:4);
              worktruck = tdtruk;
              leave;
            endif;
          enddo;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
      /free
        begsr *inzsr;

          // Get client id.
          callp GetClientPgm (client: clientloc);

        endsr;
      /end-free
