      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO)
     H BNDDIR('YAJL': 'HTTPAPI': 'QC2LE')
770aA*  This program requires library LIBHTTPBFC
770aA*  It does not need to be on library list
      *------------------------------------------------------------------*
      * Program:    DOCK002R                                             *
      * Date:       28/05/2021                                           *
      * Created By: Jitin Chopra                                         *
      * Called By:  DOCK001R                                             *
      * Purpose:    This program will receive input parameters from      *
      *             DOCK001R and will create JSON request and send it to *
      *             below mentioned URL and update the status in POSTATUS*
      *------------------------------------------------------------------*
     *  Revisions:
750 A*    11/01/21  TDC 7.50
     *      - Correct the response data in the transaction log.
     *
750 A*    11/30/21  JC01
     *      - PHSTAT will be sent with ph_status key in header section.
     *
760c *    09/29/22  TDC  7.60c
     *      - Change the sql to read POHHDR to a setgt/readp.
     *        There are possibly multiple history records for a PO.
     *        This was causing a 'trapped' failure in the select.
     *
770aA*    08/27/22  TDC  7.70a
     *      - Change copy for YAJL_H to qcopysrc.
     *
770bA*    09/10/22  TDC  7.70b
     *      - Change detail quantities.
     *      - Marked JC02.
     *                                                                  *
770cA*    03/08/23  DAS  7.70c                                          *
     *      - Moved H specs to top of program                           *
     *      - Added comments in definitions                             *
     *      - Revised to get ifsio_h from qcopysrc                      *
     *                                                                  *
770dA*    04/06/23  JIC  7.70d
     *      - It will check if the path from DOCK002PA exists or not, if*
     *        not then it will create that path.                        *
     *      - Log json request in case of any failure.                  *
     *                                                                  *
770eA*    05/22/23  LMC
     *      - In timeformat subr this code was using the date not the if*
     *      - time field.                                               *
     *      If InTime <> *Zeros;                                        *
     *         OutTime = %Time(InDate:*HMS);                            *
     *      EndIf;                                                      *
     *                                                                  *
770fA*    07/03/23  DAS  7.70f                                          *
     *      - Revised dateformat/timeformat routines to catch errors.   *
     *                                                                  *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Status codes
     *
     *   A - This is an example for documenting the status codes. This
     *       code should be replace with an actual status code.
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     fPOHDR     IF   E           k disk
     fPOHHDR    IF   E           k disk
     fPODTL     IF   E           k disk
     fPOHDTL    IF   E           k disk
     fPIRITEM   IF   E           k disk
     fITEMMSC   IF   E           k disk
     fDOCK001PA UF A E             disk

     *----------------------------------------------------------------
     *  File data structure
     *----------------------------------------------------------------

     d ds_pohhdr     E ds                  extname(pohhdr)
     d ds_pohdr      E ds                  extname(pohdr)
     d ds_pohdtl     E ds                  extname(pohdtl)
     d ds_podtl      E ds                  extname(podtl)

     *----------------------------------------------------------------
     * Program prototype
     *----------------------------------------------------------------

     d DOCK002R        pr                  extpgm('DOCK002R')
     d p_poswhs                       3  0
     d p_pospo                        9
      *
     d DOCK002R        pi
     d p_poswhs                       3  0
     d p_pospo                        9

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     D memcpy          PR              *   ExtProc('memcpy')
     D   dest                          *   value
     D   src                           *   value
     D   size                        10I 0 value
      *
     D ifnull          PR          1000A
     D   nval                      1000A   value
770dA *
  .  D RunCmd          pr                  extpgm('QCMDEXC')
  .  d  parmcmd                     250
  .  d  parmlen                      15  5
770dA *

      /copy qcopysrc,c#ifsio_h
      /include qcopysrc,httpapi_h

     *----------------------------------------------------------------
     *  YAJL Header
     *----------------------------------------------------------------

      /copy qcopysrc,yajl_h

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D p_Buf           s               *
     d Emsg            s            500    varying
     d JSONstr         s          64512A
     D TZ              s               Z   inz
     D rc              s             10I 0
     d url             s           1024A   varying
     d token           s           1024A   varying
     D InDate          s              8  0
     D OutDate         s               D   DATFMT(*ISO)
     D InTime          s              6  0
     D OutTime         s               T   TIMFMT(*HMS)
     d DockJson        s            200A
     d DockResp        s            200A
     d DockDebug       s            200A
     d Path            s            200A
     D respdata        S            500A
     D H_Flag          S              1    inz
     D w_stat          S              1    inz
770d D Cmd             s            250
  .  d cmdl            s             15  5
  .  D File_found      S             10I 0
  .  D pos             s              3  0
770dAd LogJson         s            200A

      /free

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

          ExSr Init;
          ExSr ReadFiles;

          Exsr log;

          return;

      *------------------------------------------------------------------*
      *Initialize all the parameters                                     *
      *------------------------------------------------------------------*

          BegSr Init;
           Clear respdata;
           Clear Emsg    ;
           Clear JSONstr ;
           H_Flag = 'N';

           Exec Sql
            Select po2url,po2tokn,po2path into
             :url,:token,:path
             from DOCK002PA
             where po2app = 'DOCKVUE';

           If Sqlcode = 0;
770dA         File_found = access(%trim(Path):F_Ok);
   .          If File_found <> 0;
   .            ExSr CreateIFS;
770dA         EndIf;
              DockJson = %trim(Path) + 'DockJson' + '.txt';
              DockResp = %trim(Path) + 'DockResp' + '.txt';

              DockDebug= %trim(Path) + 'DockDebug' + %editc(p_poswhs:'X') +
                         '.txt';
              ExSr CheckDebugFile;
           EndIf;

          EndSr;

770dA *------------------------------------------------------------------*
 .    *Create IFS path.                                                  *
 .    *------------------------------------------------------------------*
 .
 .        BegSr CreateIFS;
 .
 .        pos = %scan('/':Path:2);
 .        dow pos <> 0;
 .          Monitor;
 .            cmd = 'CRTDIR DIR(' + '''' + %subst(Path:1:pos-1) + '''' + ')';
 .            cmdl = %len(%trim(cmd));
 .            RunCmd (cmd : cmdl);
 .          On-Error;
 .          EndMon;
 .          pos = %scan('/':Path:pos+1);
 .        EndDo;
770dA     EndSr;

      *------------------------------------------------------------------*
      *Read all four tables based on the input parameters and then call  *
      *subroutines to create JSON .                                      *
      *------------------------------------------------------------------*

          BegSr ReadFiles;

            If Sqlcode = 0;
              Exec Sql
                Select POSSTAT into :w_stat
                 from postatus
                 where POSWHS = :p_poswhs
                   and POSPO  = :p_pospo;
               Chain (p_poswhs:p_pospo) POHDR;
               If %found(POHDR);
               Else;
                  If w_stat = '4';
760cM *            Exec Sql
760cM *             Select * into :ds_pohhdr
760cM *              from pohhdr
760cM *              where PHHWHS = :p_poswhs
760cM *                and PHHPO  = :p_pospo;
760cM *            If sqlcode = 0;
760cA
760cA
760cA              Setgt  (p_poswhs:p_pospo) POHHDR;
760cA              Readpe (p_poswhs:p_pospo) POHHDR;
760cA              If not %eof(pohhdr);
                     H_Flag = 'Y';
                     ds_pohdr = ds_pohhdr;
                   Else;
                     Respdata = 'Record not found in POHDR & POHHDR for WH: '
                                + %char(p_poswhs) + ' & PO: ' + p_pospo ;
                     TZ = %timestamp();
                     Exec Sql
                       Update POSTATUS
                         Set POSEXPTS = :TZ ,
                             POSSTAT = 'F'
                         where POSPO = :p_pospo;
                     LeaveSr;
                   EndIf;
                  Else;
                    Respdata = 'Record not found in POHDR for WH: '
                               + %char(p_poswhs) + ' & PO: ' + p_pospo ;
                    TZ = %timestamp();
                    Exec Sql
                      Update POSTATUS
                        Set POSEXPTS = :TZ ,
                            POSSTAT = 'F'
                        where POSPO = :p_pospo;
                    LeaveSr;
                  EndIf;
               EndIf;
               Exsr CreateJson;
               If H_flag <> 'Y';
                 Setll (p_poswhs:p_pospo) PODTL;
                 Reade (p_poswhs:p_pospo) PODTL;
               Else;
                 Setll (p_poswhs:p_pospo) POHDTL;
                 Reade (p_poswhs:p_pospo) POHDTL;
                 ds_podtl = ds_pohdtl;
               EndIf;
               Dow not %EOF;
                 Chain(e) (p_poswhs:pditem) PIRITEM;
                 Chain(e) (p_poswhs:pditem) ITEMMSC;
                 ExSr arritem;
JC02             ExSr arrdetail;
               If H_flag <> 'Y';
                 Reade (p_poswhs:p_pospo) PODTL;
               Else;
                 Reade (p_poswhs:p_pospo) POHDTL;
JC02             ds_podtl = ds_pohdtl;
               EndIf;
JC02        // ExSr arrdetail;
               Enddo;
               yajl_endArray();
               Exsr header;
               yajl_saveBuf(%trim(DockJson):Emsg);
               yajl_genClose();
               Exsr SendRequest;
            Else;
               Respdata = 'Record missing in DOCK002PA ' + %char(p_poswhs)
                             + ' ' + p_pospo ;
            EndIf;
          EndSr;

      *------------------------------------------------------------------*
      *Create JSON header.                                               *
      *------------------------------------------------------------------*
          BegSr CreateJson;

           yajl_genOpen(*On);
             yajl_beginObj();
              yajl_beginArray('po_details');

          EndSr;

      *------------------------------------------------------------------*
      *Create array JSON for item and item miscellaneous                 *
      *------------------------------------------------------------------*

       BegSr arritem;
         yajl_beginObj();
          yajl_beginObj('item');
            yajl_addchar('warehouse':%char(ITWHSE));
            yajl_addchar('warehouse_dept':%trim(ITWHDP));
            yajl_addchar('item_number':%trim(ITITEM));
            yajl_addchar('item_type':%trim(ITTYPE));
            yajl_addchar('item_description':%trim(ITDESC));
            yajl_addchar('section_type':%trim(ITSTYP));
            yajl_addchar('designation':%trim(ITDESG));
            yajl_addchar('activity':%trim(ITACTV));
            yajl_addchar('upc_code':%trim(ITUPC));
            yajl_addchar('build_code':%trim(ITBLD));
            yajl_addchar('vendor_number':%char(ITVEN#));
            yajl_addchar('vendor_name':%trim(IMVNAM));
            yajl_addchar('vendor_item_number':%trim(ITVIT#));
            yajl_addchar('pack_description':%trim(ITPDSC));
            yajl_addchar('normal_um':%trim(ITUM1));
            yajl_addchar('breakdown1_um':%trim(ITUM2));
            If ITUMQ2 <> *Zeros;
              yajl_addnum('breakdown1_um_qty':%char(ITUMQ2));
            Else;
              yajl_addnum('breakdown1_um_qty':'0');
            EndIf;
            If ITFLG1 = 'Y';
              yajl_addBool('allow_brk1_sale':*ON);
            Else;
              yajl_addBool('allow_brk1_sale':*OFF);
            EndIf;
            yajl_addchar('breakdown2_um':%trim(ITUM3));
            If ITUMQ3 <> *Zeros;
              yajl_addnum('breakdown2_um_qty':%char(ITUMQ3));
            Else;
              yajl_addnum('breakdown2_um_qty':'0');
            EndIf;
            If ITFLG2 = 'Y';
              yajl_addBool('allow_brk2_sale':*ON);
            Else;
              yajl_addBool('allow_brk2_sale':*OFF);
            EndIf;
            If ITULEN < 1;
              yajl_addnum('unit_length':'0' + %char(ITULEN));
            Else;
              yajl_addnum('unit_length':%char(ITULEN));
            EndIf;
            If ITUWDT < 1;
              yajl_addnum('unit_width':'0' + %char(ITUWDT));
            Else;
              yajl_addnum('unit_width':%char(ITUWDT));
            EndIf;
            If ITUHGT < 1;
              yajl_addnum('unit_height':'0' + %char(ITUHGT));
            Else;
              yajl_addnum('unit_height':%char(ITUHGT));
            EndIf;
            If ITCUBE < 1;
              yajl_addnum('cube_per_unit':'0' + %char(ITCUBE));
            Else;
              yajl_addnum('cube_per_unit':%char(ITCUBE));
            EndIf;
            If ITSWGT < 1;
              yajl_addnum('shipping_weight':'0' + %char(ITSWGT));
            Else;
              yajl_addnum('shipping_weight':%char(ITSWGT));
            EndIf;
            If ITCWGT = 'Y';
              yajl_addBool('catch_weight':*ON);
            Else;
              yajl_addBool('catch_weight':*OFF);
            EndIf;
            yajl_addchar('reorder_level':%char(ITREOR));
            yajl_addchar('replenish_level':%char(ITREPL));
            InDate = ITRCVD;
            ExSr DateFormat;
            yajl_addchar('last_received_date':%char(OutDate));
            If ITFLGD = 'Y';
              yajl_addBool('date_sensitive':*ON);
            Else;
              yajl_addBool('date_sensitive':*OFF);
            EndIf;
            If ITFLGB = 'Y';
              yajl_addBool('allow_bulk_pick':*ON);
            Else;
              yajl_addBool('allow_bulk_pick':*OFF);
            EndIf;
            If ITSLIF <> *Zeros;
              yajl_addnum('shelf_life_days':%char(ITSLIF));
            Else;
              yajl_addnum('shelf_life_days':'0');
            EndIf;
            If ITNDAY <> *Zeros;
              yajl_addnum('notice_days':%char(ITNDAY));
            Else;
              yajl_addnum('notice_days':'0');
            EndIf;
            If IMTIE  <> *Zeros;
              yajl_addnum('item_tie':%char(IMTIE));
            Else;
              yajl_addnum('item_tie':'0');
            EndIf;
            If IMHIGH <> *Zeros;
              yajl_addnum('item_high':%char(IMHIGH));
            Else;
              yajl_addnum('item_high':'0');
            EndIf;
            If IMMFLG = 'Y';
              yajl_addBool('manufacturing_date':*ON);
            Else;
              yajl_addBool('manufacturing_date':*OFF);
            EndIf;
            If IMDDAY <> *Zeros;
              yajl_addnum('distributor_days':%char(IMDDAY));
            Else;
              yajl_addnum('distributor_days':'0');
            EndIf;
            If IMUDAY <> *Zeros;
              yajl_addnum('end_user_days':%char(IMUDAY));
            Else;
              yajl_addnum('end_user_days':'0');
            EndIf;
            If IMMDAY <> *Zeros;
              yajl_addnum('mfg_shelf_life_days':%char(IMMDAY));
            Else;
              yajl_addnum('mfg_shelf_life_days':'0');
            EndIf;
            If IMWRNC = 'Y';
              yajl_addBool('perform_cw_check':*ON);
            Else;
              yajl_addBool('perform_cw_check':*OFF);
            EndIf;
            If IMRG1C < 1;
              yajl_addnum('item_cw_low_variance_percent':'0' + %char(IMRG1C));
            Else;
              yajl_addnum('item_cw_low_variance_percent':%char(IMRG1C));
            EndIf;
            If IMRG2C < 1;
              yajl_addnum('item_cw_high_variance_percent':'0' + %char(IMRG2C));
            Else;
              yajl_addnum('item_cw_high_variance_percent':%char(IMRG2C));
            EndIf;
            If IMAPCK = 'Y';
              yajl_addBool('automatically_assign_pick_slot':*ON);
            Else;
              yajl_addBool('automatically_assign_pick_slot':*OFF);
            EndIf;
            If IMNRPK <> *Zeros;
              yajl_addnum('number_of_pick_slots':%char(IMNRPK));
            Else;
              yajl_addnum('number_of_pick_slots':'0');
            EndIf;
            If IMNSLT = 'Y';
              yajl_addBool('non_slotted_item':*ON);
            Else;
              yajl_addBool('non_slotted_item':*OFF);
            EndIf;
            If IMXDCK = 'Y';
              yajl_addBool('cross_dock_item':*ON);
            Else;
              yajl_addBool('cross_dock_item':*OFF);
            EndIf;
            yajl_addchar('buyer_number':%char(IMBNBR));
            yajl_addchar('buyer_name':%trim(IMBNAM));
            yajl_addchar('brand':%trim(IMBRND));
            If IMLOT = 'Y';
              yajl_addBool('lot_code_item':*ON);
            Else;
              yajl_addBool('lot_code_item':*OFF);
            EndIf;
            yajl_addchar('track_by_license':%trim(IMLTRK));
            If IMODAY <> *Zeros;
              yajl_addnum('days_out':%char(IMODAY));
            Else;
              yajl_addnum('days_out':'0');
            EndIf;
          //yajl_addchar('notes':'string');
          //yajl_addchar('pick_slot_aisle':'string');
          //yajl_addchar('pick_slot_display':'string');
          //yajl_addnum('warehouse_tie':'0');
          //yajl_addnum('warehouse_high':'0');
          yajl_endObj();
        EndSr;

      *------------------------------------------------------------------*
      *Create array JSON for PO detail                                   *
      *------------------------------------------------------------------*

        BegSr arrdetail;
          If PDSEQ <> *Zeros;
            yajl_addnum('sequence_number':%char(PDSEQ));
          Else;
            yajl_addnum('sequence_number':'0');
          EndIf;
          yajl_addchar('vendor_item_number':%trim(PDVITM));
          yajl_addchar('special_order_code':%trim(PDSPCL));
          If PDQOR1 <> *Zeros;
            yajl_addnum('normal_qty_ordered':%char(PDQOR1));
          Else;
            yajl_addnum('normal_qty_ordered':'0');
          EndIf;
          If PDQOR2 <> *Zeros;
            yajl_addnum('breakdown1_qty_ordered':%char(PDQOR2));
          Else;
            yajl_addnum('breakdown1_qty_ordered':'0');
          EndIf;
          If PDQOR3 <> *Zeros;
            yajl_addnum('breakdown2_qty_ordered58':%char(PDQOR3));
          Else;
            yajl_addnum('breakdown2_qty_ordered58':'0');
          EndIf;
          If PDQRC1 <> *Zeros;
            yajl_addnum('normal_qty_received':%char(PDQRC1));
          Else;
            yajl_addnum('normal_qty_received':'0');
          EndIf;
          If PDQRC2 <> *Zeros;
            yajl_addnum('breakdown1_qty_received':%char(PDQRC2));
          Else;
            yajl_addnum('breakdown1_qty_received':'0');
          EndIf;
          If PDQRC3 <> *Zeros;
            yajl_addnum('breakdown2_qty_received':%char(PDQRC3));
          Else;
            yajl_addnum('breakdown2_qty_received':'0');
          EndIf;
          //yajl_addnum('breakdown':'0');
          //yajl_addnum('total_received_cube':'0');
          //yajl_addchar('notes':'string');
          yajl_endObj();
          EndSr;


      *------------------------------------------------------------------*
      *Create JSON for PO header                                         *
      *------------------------------------------------------------------*

          BegSr header;
            yajl_addchar('state':%trim(ifnull(PHVST)));
          //yajl_addchar('state':yajl_addNull(PHVST));
            yajl_addchar('warehouse':%char(PHWHSE));
            yajl_addchar('po_number':%trim(PHPO));
            yajl_addchar('vendor_number':%char(PHVEN));
            yajl_addchar('vendor_name':%trim(PHVNAM));
            yajl_addchar('address_line1':%trim(PHVAD1));
            yajl_addchar('address_line2':%trim(PHVAD2));
            yajl_addchar('city':%trim(PHVCTY));
            yajl_addchar('zip_code':%trim(PHVZP1));
          //yajl_addnum('country':'0');
            InDate = PHDATE;
            ExSr DateFormat;
            yajl_addchar('delivery_date':%char(OutDate));

            InTime = PHTIME;
            ExSr TimeFormat;
            yajl_addchar('delivery_time':%char(OutTime));

            InDate = PHUDTE;
            ExSr DateFormat;
            yajl_addchar('upload_date':%char(OutDate));

            InTime = PHUTIM;
            ExSr TimeFormat;
            yajl_addchar('upload_time':%char(OutTime));

JC01        yajl_addchar('ph_status':%trim(PHSTAT));
JC01      //If PHSTAT = 'Y';
JC01      //  yajl_addBool('status':*ON);
JC01      //Else;
JC01      //  yajl_addBool('status':*OFF);
JC01      //EndIf;
          //yajl_addchar('user_field1':PHMM1);
          //yajl_addchar('user_field2':PHMM2);
          //yajl_addchar('user_field3':PHMM3);
          //yajl_addchar('user_field4':PHMM4);
          //yajl_addchar('notes':'string');
            yajl_addchar('po_status_dakota':w_stat);
            yajl_endObj();
          EndSr;

      *------------------------------------------------------------------*
      *Send Request to below mentioned URL                               *
      *------------------------------------------------------------------*

          BegSr SendRequest;
          http_debug(*ON);
          http_xproc( HTTP_POINT_DEBUG: %paddr(Debug_Proc));

          http_setCCSIDs( 1208: 0 );

          http_xproc( HTTP_POINT_ADDL_HEADER
                       : %paddr(add_headers) );

          rc = http_url_post_stmf(%trim(url)
                                   : %trim(DockJson)
                                   : %trim(DockResp)
                                   : HTTP_TIMEOUT
                                   : HTTP_USERAGENT
                                   : 'text/json');


          TZ = %timestamp();
          Select;
            When rc = 201;
              Exec Sql
                Update POSTATUS
                  Set POSEXPTS = :TZ ,
                      POSSTAT = 'Y'
                  where POSPO = :p_pospo;
            When rc < 0;
              Exec Sql
                Update POSTATUS
                  Set POSEXPTS = :TZ ,
                      POSSTAT = 'F'
                  where POSPO = :p_pospo;
750 D *     respdata = 'API call ended up in error-' + %char(rc) + '-'
750 D *               + %char(sqlcode) + ' po nbr:' +  p_pospo;
750 A       respdata = 'API call ended in error. RC: ' + %char(rc) +
750 A                 ' SQLCODE: ' + %char(sqlcode) + ' WH: ' +
750 A                 %char(p_poswhs) + ' PO: ' +  p_pospo;
770dA         ExSr LogJsonSr;
            Other;
              Exec Sql
                Update POSTATUS
                  Set POSEXPTS = :TZ ,
                      POSSTAT = 'F'
                  where POSPO = :p_pospo;
770dA         ExSr LogJsonSr;
          EndSl;

          EndSr;

      *------------------------------------------------------------------*
      *Log Request and response in DOCK001PA                             *
      *------------------------------------------------------------------*

          BegSr log;

              If Respdata = ' ';
                 Exsr GetResp;
              EndIf;

              TZ = %timestamp();

              POID     = p_pospo;
              POTS     = TZ;
750 A
750 D *       PORESP   = %trim(respdata) + ' ' + p_pospo;
              PORESP   = %trim(respdata);
750 A
750 A         if %scan('success': PORESP) > 0;
750 A           PORESP = %trim(PORESP) + ' WH: ' + %char(p_poswhs) +
750 A           ' PO: ' + p_pospo;
750 A         endif;
750 A
              POURL    = url;
              write DOCK001R;

          EndSr;
770dA *------------------------------------------------------------------*
  .   *Log json request in case of any failure.                          *
  .   *------------------------------------------------------------------*
  .
770dA     BegSr LogJsonSr;
  .
  .         LogJson = %trim(Path) + 'LogJson_' +  %TRIM(p_pospo) +
  .                    '_' + %CHAR(TZ) + '.txt';
  .         cmd = 'CPY OBJ(' + '''' + %trim(DockJson) + '''' + ') ' +
  .               'TOOBJ(' + '''' + %trim(LogJson ) + '''' + ')';
  .         cmdl = %len(%trim(cmd));
  .         RunCmd (cmd : cmdl);
  .
770dA     EndSr;
      *------------------------------------------------------------------*
      *Convert numeric date into 'YYYY-MM-DD' format                     *
      *------------------------------------------------------------------*

            BegSr DateFormat;

            Clear OutDate;

            If InDate <> *Zeros;
770fA         monitor;
               OutDate = %Date(InDate:*ISO);
770fA         on-error;
770fA         endmon;
            EndIf;

            EndSr;

      *------------------------------------------------------------------*
      *Convert numeric time into 'hh:mm:ss' format                       *
      *------------------------------------------------------------------*

            BegSr TimeFormat;

            Clear OutTime;

            If InTime <> *Zeros;
770eD          //OutTime = %Time(InDate:*HMS);
770fA         monitor;
770eM          OutTime = %Time(InTime:*HMS);
770fA         on-error;
770fA         endmon;
            EndIf;

            EndSr;

      *------------------------------------------------------------------*
      *Get response from stream file in a variable.                      *
      *------------------------------------------------------------------*

            BegSr GetResp;

              rc = open(%trimr(DockResp):O_RDONLY + O_TEXTDATA:
                        S_IRGRP : 37);

              If rc >= 0;
                 callp read(rc: %addr(respdata): %size(respdata));
                 unlink(%trimr(DockResp));
              endif;

            EndSr;
      *------------------------------------------------------------------*
      *Check existence of debug file.                                    *
      *------------------------------------------------------------------*

            BegSr CheckDebugFile;

              rc = open(%trimr(DockDebug):o_creat + o_append + o_wronly
                       :(6+64) + (6+8) + (4):1208);
              callp  close(rc);

            EndSr;
      /End-free

      *------------------------------------------------------------------*
      *header proc for authentication of API call.                       *
      *------------------------------------------------------------------*
     P add_headers     B
     D                 PI
     D   headers                  32767a   varying
     D CRLF            C                   x'0d25'

        headers =   'api-key: ' + token + CRLF
                  + 'Content-Disposition: form-data; name="file"; '
                  + 'filename="' +  %trim(DockJson) + '"' + CRLF;

     P                 E

      *------------------------------------------------------------------*
      *header proc for authentication of API call.                       *
      *------------------------------------------------------------------*
     P Debug_Proc      B
     D                 PI
     D   Dataptr                       *   value
     D   Datalen                     10I 0 value

     c                   alloc     Datalen       p_Buf
     c                   callp     memcpy(p_buf: Dataptr: Datalen)
     c                   callp     http_xlatep(Datalen: p_Buf: TO_EBCDIC)
     c                   eval      rc = open(%trimr(DockDebug):o_append +
     c                             o_wronly :(6+64) + (6+8) + (4):1208)
     c                   callp     write(rc: p_buf: Datalen)
     c                   callp     close(rc)
     c                   dealloc                 p_Buf

     P                 E
      *------------------------------------------------------------------*
      *Checking blank and replacing with 'null'.                         *
      *------------------------------------------------------------------*
     P ifnull          B
     D ifnull          PI          1000A
     D   nval                      1000A   value
     D   nval2         s           1000A

          nval2 = nval;

          if nval2 = *Blanks;
             nval2 = 'null';
          endif;

          return nval2;

     P                 E
