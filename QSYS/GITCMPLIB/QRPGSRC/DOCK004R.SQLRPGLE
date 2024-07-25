      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO)
     H BNDDIR('YAJL': 'HTTPAPI': 'QC2LE')
770aA*  This program requires library LIBHTTPBFC
770aA*  It does not need to be on library list
      *------------------------------------------------------------------*
      * Program:    DOCK004R                                             *
      * Date:       26/05/2022                                           *
      * Created By: Damco Solutions                                      *
      * Called By:                                                       *
      * Purpose:    This program will receive JSON from URL and create   *
      *             the file data.                                       *
      *------------------------------------------------------------------*
      *  Revisions                                                       *
      *                                                                  *
770 A *  07/28/22  JIC                                                   *
      *   - CHANGE THE DUE DATE FROM 6 POSITIONS TO 8.                   *
     *                                                                  *
770aA*    08/10/22  TDC  7.70a                                          *
     *      - Change copy for YAJL_H to qcopysrc.                       *
     *                                                                  *
770bA*    08/16/22  TDC  7.70b                                          *
     *      - Change the resopnse list to results, not data.            *
     *                                                                  *
770cA *  09/21/22  TDC 770c                                              *
      *   - Add the write to EXPSDOCKVU on updates to PODOCKVUE.         *
     *                                                                  *
770dA *  11/11/22  TDC 770d                                              *
      *   - Modifications for the new deleted schedule field.            *
     *                                                                  *
765aA *  11/17/22  JIC 765a                                              *
      *   - Modifications for the new deleted schedule field at po level.*
     *                                                                  *
770fA*    03/08/23  DAS  7.70f                                          *
     *      - Moved H specs to top of program                           *
     *      - Added comments in definitions                             *
     *      - Revised to get ifsio_h from qcopysrc                      *
     *                                                                  *
770gA*    04/10/23  JIC  7.70g                                          *
     *      - It will check if the path from DOCK002PA exists or not, if*
     *        not then it will create that path.                        *
     *                                                                  *
      *------------------------------------------------------------------*

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     fPODOCKVUE UF A E           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     D memcpy          PR              *   ExtProc('memcpy')
     D   dest                          *   value
     D   src                           *   value
     D   size                        10I 0 value

     D ifnull          PR          1000A
     D   nval                      1000A   value
770gA *
  .  D RunCmd          pr                  extpgm('QCMDEXC')
  .  d  parmcmd                     250
  .  d  parmlen                      15  5
770gA *

770fM /copy qcopysrc,c#ifsio_h
      /include qcopysrc,httpapi_h

     *----------------------------------------------------------------
     *  YAJL Header
     *----------------------------------------------------------------

      /copy qcopysrc,yajl_h

     D respdata        S                   Like(yajl_val)
     D DocNode         S                   Like(yajl_val)
     D Node            S                   Like(yajl_val)
     D w_Node          S                   Like(yajl_val)
     D List            S                   Like(yajl_val)
     D List1           S                   Like(yajl_val)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D p_Buf           s               *
     d url             s           1024A   varying
     d token           s           1024A   varying
     d DockJson        s            200A
     d DockDebug       s            200A
     d Path            s            200A
     d Emsg            s            500    varying
     D rc              s             10I 0
     D i               s             10I 0
     D j               s             10I 0
     D w_TS            s             26A
     D w_TSDate        s               D
     D w_TSTime        s               T
     D k_WareHouse     S                   Like(PDVWHSE)
     D k_PoNumber      S                   Like(PDVPO)
      *
     D w_WareHouse     S                   Like(PDVWHSE)
     D p_WareHouse     S                   Like(PDVWHSE)
     D w_PoNumber      S                   Like(PDVPO)
     D w_PoStatus      s                   Like(PDVPOSTS)
     d w_LoadId        s                   Like(PDVLDID)
     d w_LoadStatus    s                   Like(PDVLDSTS)
     D w_DeliveryDate  s                   Like(PDVDUEDT)
     d w_InitSchTS     s                   Like(PDVINITDT)
     d w_SchTS         s                   Like(PDVSCHDT)
     d w_LandedTS      s                   Like(PDVLNDDT)
     d w_Landed        s                   Like(PDVLND)
     d w_HistoryTS     s                   Like(PDVCHGTS)
     d batId           s             11a
     d rtnCode         s             10
     d rtnMessage      s            200
     d stamp           s               z
     d stampUC         s               z
     d w_PoStatusN     s              1  0
     d w_LoadStatusN   s              2  0
     d w_LoadStatusX   s              1
770dAd w_SchedDel      s                   Like(PDVSDEL)
770gAD Cmd             s            250
  .  d cmdl            s             15  5
  .  D File_found      S             10I 0
  .  D pos             s              3  0

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getbatid

      /free

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *Initialize Subroutine
          ExSr Init;

     *Retrieve Data from Json File
          If Sqlcode = 0;
             ExSr RcvData ;
          EndIf;

          *inlr = *on ;

      *------------------------------------------------------------------*
     *Initialize all the parameters
      *------------------------------------------------------------------*

          BegSr Init;
            Clear respdata ;
            Clear Emsg     ;

     *Get URL & Token
            Exec Sql
             Select po2url,po2tokn,po2path into
              :url,:token,:path
              from DOCK002PA
              where po2app = 'DOCKVUEGET';

            If Sqlcode = 0;
770gA         File_found = access(%trim(Path):F_Ok);
   .          If File_found <> 0;
   .            ExSr CreateIFS;
770gA         EndIf;
               DockJson = %trim(Path) + 'DockJson' + '.txt';
            Else ;
               Emsg = 'No record Found in DOCK002PA';
            EndIf;

          EndSr;

770gA *------------------------------------------------------------------*
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
770gA     EndSr;

      *------------------------------------------------------------------*
     *Receive Data from URL
      *------------------------------------------------------------------*

          BegSr RcvData  ;

            http_debug(*ON);
            http_xproc( HTTP_POINT_DEBUG: %paddr(Debug_Proc));

            http_setCCSIDs( 1208: 0 );

            http_xproc( HTTP_POINT_ADDL_HEADER
                         : %paddr(add_headers) );

            rc = http_url_get(url:DockJson) ;

            If rc <> 1  ;
               Emsg = 'Incorrect URL' ;
            Else ;
               Exsr GetResp ;
            Endif ;

          EndSr;

      *------------------------------------------------------------------*
     *Get response from stream file in a variable.
      *------------------------------------------------------------------*

          BegSr GetResp;

            DocNode = yajl_stmf_Load_tree(%trim(DockJson):Emsg);

            If Emsg = ' ' ;
     *Search Data in string >> 'results-Array'
770bM         List = yajl_object_find( docNode: 'results') ;
770bD *       List = yajl_object_find( docNode: 'data') ;
              i =0 ;
              Dow Yajl_Array_Loop(List: i: Node) ;
                Exsr BuildData1 ;

     *Search Subdata in results-Array string >> 'po_headers'
                List1 = yajl_object_find( Node: 'po_headers') ;
                j =0 ;
                Dow Yajl_Array_Loop(List1: j: Node) ;
                  Exsr BuildData ;
                  If w_warehouse <> p_warehouse ;
                     p_warehouse = w_warehouse;
                     ExSr GetBatIdSr;
                  EndIf;
                  Exsr WriteData ;
                  w_SchedDel = ' ';
                Enddo ;
              Enddo ;
            Endif ;

            Yajl_tree_free( Docnode) ;
          EndSr;

      *------------------------------------------------------------------*
     *Build File data - Field Mapped from PO_Header JSON
      *------------------------------------------------------------------*

            BegSr BuildData ;

     *WareHouse
              w_Node      = yajl_object_find( Node :'warehouse') ;
              w_WareHouse = %int(yajl_Get_String(w_Node));

     *PO Number
              w_Node      = yajl_object_find( Node :'po_number') ;
              w_PoNumber  = yajl_Get_String(w_Node);

     *PO Status
              w_Node      = yajl_object_find( Node :'ph_status') ;
              w_PoStatusN = yajl_Get_Number(w_Node);
              w_PoStatus  = %editc(w_PoStatusN:'X');

     *Delivery/Due Date
              w_Node = yajl_object_find( Node :'delivery_date') ;
770 D         //w_DeliveryDate = %int(%char(%date(yajl_Get_String(w_Node)
770 D         //                      :*ISO):*YMD0)) ;
770 A         w_DeliveryDate = %dec(%char(%date(yajl_Get_String(w_Node))
770 A                                   :*ISO0):8:0);

     *Initial Schedule TS
              clear w_TS;
              w_Node = yajl_object_find( Node :'initial_scheduled_timestamp');
              w_TS   = yajl_Get_String(w_Node);
              If w_TS <> ' ' ;
                 w_TSDate = %Date(%subst(w_TS:1:10):*ISO)   ;
                 w_TSTime = %Time(%Subst(w_TS:12:2) + '.' +
                                  %Subst(w_TS:15:2) + '.' +
                                  %Subst(w_TS:18:2) : *ISO) ;
                 W_InitSchTS = w_TSDate + w_TSTime;
              Endif ;

     *Landed TS
              clear w_TS;
              w_Node = yajl_object_find( Node :'landed_timestamp');
              w_TS   = yajl_Get_String(w_Node);
              If w_TS <> ' ' ;
                 w_TSDate = %Date(%subst(w_TS:1:10):*ISO);
                 w_TSTime = %Time(%Subst(w_TS:12:2) + '.' +
                                  %Subst(w_TS:15:2) + '.' +
                                  %Subst(w_TS:18:2) : *ISO);
                 w_LandedTS = w_TSDate + w_TSTime;
              Endif ;

     *Is Landed
              w_Node   = yajl_object_find( Node :'is_landed');
              w_Landed = %Char(yajl_is_true(w_Node));

765aA*Is Deleted
765aA         w_Node     = yajl_object_find( Node :'is_deleted');
765aA         If w_SchedDel <> '1';
765aA            w_SchedDel = %Char(yajl_is_true(w_Node));
765aA         EndIf;

            EndSr;

      *------------------------------------------------------------------*
     *Build File data1 - Remaining field mapping in PODOCKVUE file.
      *------------------------------------------------------------------*

            BegSr BuildData1;

     *Load Number
              w_Node       = yajl_object_find( Node :'id');
              w_LoadId     = yajl_Get_Number(w_Node);

     *Load Status
              w_Node       = yajl_object_find( Node :'status');
              w_LoadStatusN= yajl_Get_Number(w_Node);
              w_LoadStatus = %editc(w_LoadStatusN:'X');
              w_LoadStatusX= %subst(w_LoadStatus:2:1);

     *Schedule TS
              clear w_TS;
              w_Node = yajl_object_find( Node :'schedule_timestamp');
              w_TS   = yajl_Get_String(w_Node);
              If w_TS <> ' ' ;
                 w_TSDate = %Date(%subst(w_TS:1:10):*ISO);
                 w_TSTime = %Time(%Subst(w_TS:12:2) + '.' +
                                  %Subst(w_TS:15:2) + '.' +
                                  %Subst(w_TS:18:2) : *ISO);
                 w_SchTS  = w_TSDate + w_TSTime;
              Endif;

     *History Chage Status
              clear w_TS;
              w_Node = yajl_object_find( Node :'history_date');
              w_TS   = yajl_Get_String(w_Node);
              If w_TS <> ' ' ;
                 w_TSDate = %Date(%subst(w_TS:1:10):*ISO);
                 w_TSTime = %Time(%Subst(w_TS:12:2) + '.' +
                                  %Subst(w_TS:15:2) + '.' +
                                  %Subst(w_TS:18:2) : *ISO);
                 w_HistoryTS = w_TSDate + w_TSTime;
              Endif ;

770dA
770dA *Is Deleted
770dA         w_Node     = yajl_object_find( Node :'is_deleted');
770dA         w_SchedDel = %Char(yajl_is_true(w_Node));

            EndSr;

      *------------------------------------------------------------------*
     *WriteData - Write or Update date in file PODOCKVUE .
      *------------------------------------------------------------------*

            BegSr WriteData ;

              Chain (w_WareHouse:w_PoNumber) PODOCKVUE ;
              If %found(PODOCKVUE) ;
                 PDVPOSTS  =   w_PoStatus    ;
                 PDVLDID   =   w_LoadId      ;
                 PDVLDSTS  =   w_LoadStatus  ;
                 PDVDUEDT  =   w_DeliveryDate;
                 PDVINITDT =   w_InitSchTS   ;
                 PDVSCHDT  =   w_SchTS       ;
                 PDVLNDDT  =   w_LandedTS    ;
                 PDVLND    =   w_Landed      ;
770dA            PDVSDEL   =   w_SchedDel    ;
770cA            If w_HistoryTS > PDVCHGTS   ;
                   PDVCHGTS  =   w_HistoryTS   ;
                   Update PDVREC  ;
770cA              ExSr GetStamps;
770cA              ExSr WrtExpsDock;
770cA            Endif;
              else ;
                 PDVWHSE   =   w_WareHouse   ;
                 PDVPO     =   w_PoNumber    ;
                 PDVPOSTS  =   w_PoStatus    ;
                 PDVLDID   =   w_LoadId      ;
                 PDVLDSTS  =   w_LoadStatus  ;
                 PDVDUEDT  =   w_DeliveryDate;
                 PDVINITDT =   w_InitSchTS   ;
                 PDVSCHDT  =   w_SchTS       ;
                 PDVLNDDT  =   w_LandedTS    ;
                 PDVLND    =   w_Landed      ;
                 PDVCHGTS  =   w_HistoryTS   ;
770dA            PDVSDEL   =   w_SchedDel    ;
                 Write PDVREC;
770cA            ExSr GetStamps;
770cA            ExSr WrtExpsDock;
              Endif ;

            EndSr;

     *----------------------------------------------------------------
     *  GetBatIdSr    Get batch id
     *----------------------------------------------------------------
      /free
        begsr GetBatIdSr;

        monitor;
          GetBatId(p_WareHouse: 'EXPDOCKVUE': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

        endsr;
     *----------------------------------------------------------------
     *  GetStamps   Get timestamps
     *----------------------------------------------------------------

        begsr GetStamps;

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

        endsr;

770cA*----------------------------------------------------------------
770cA*  WrtExpsDock  Update EXPSDOCKVU
770cA*----------------------------------------------------------------
      /free
770cA   begsr WrtExpsDock;

          Exec Sql
           Insert into EXPSDOCKVU
            values(:p_WareHouse, :batid, :w_PoNumber, 'R',
                   :stamp, :stampUC, ' ', :w_PoStatus,
                   :w_LoadId, :w_LoadStatusX, :w_DeliveryDate,
                   :W_InitSchTS, :w_SchTS, :w_LandedTS, :w_Landed,
770dD              // :stamp, :stamp, :stampUC
770dM              :w_SchedDel, :stamp, :stamp, :stampUC
                  );

          If Sqlcode = 0;

             Exec Sql
               update stgbatch
                 set sbstatus = 'R',
                     sbststs  = :stamp,
                     sbstsuc  = :stampUC
                 where sbwhse = :p_WareHouse
                   and sbbatid = :batid;
          EndIf;

770cA   endsr;

      /end-free

      *------------------------------------------------------------------*
     *header proc for authentication of API call.
      *------------------------------------------------------------------*
     P add_headers     B
     D                 PI
     D   headers                  32767a   varying
     D CRLF            C                   x'0d25'

        headers =   'api-key: ' + token   + CRLF
                  + 'Content-Disposition: form-data; name="file"; '
                  + 'filename="' +  %trim(DockJson) + '"' + CRLF;

     P                 E
      *------------------------------------------------------------------*
     *header proc for authentication of API call.
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
