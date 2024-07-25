      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR736S     Staging Export customer returns - Post
     *  05 Decmeber 2012
     *  Max Blacknik
     *
     *  This program should be identical to OR736 except that it uses
     *  the EXPF files that are overridden in OR736CL.
     *  Custom client code was removed from this program not using this
     *  interface.
     *
     *----------------------------------------------------------------
     *  Revisions
640 A*  12/04/12  MLB  6.40
     *    - Created
     *    - Added client custom code support.
     *
700 A*    04/04/16  MLB  7.00
     *      - Enh: Added INFDS to EXPSRTN.
     *
740a *    04/12/20  RTR  7.40a
     *      - Enh: Added EXPSRTNLT file.
740b *    09/17/20  RTR  7.40b
     *      - Enh: Changes for NetSuite export.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*  04/04/16  MLB  DRY
     *      - Revised pgm to call Host export program, BFCERT03C to send
     *        exported cust returns to Host JDEdwards system.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Forrtn4    uf   e           k disk
740bAfoptions   if   e           k disk
     Fexpsrtn   o  a e           k disk
740aAfexpsrtnlt o  a e           k disk
700 AF                                     infds(file1ds)
     *----------------------------------------------------------------
     *  Customer id
     *
DRY A /COPY QCOPYSRC,ID#dairyla
     *
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pWhse          s              3p 0
     D $pWhse3A        s              3
     *
     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
740bA*----------------------------------------------------------------
740bA* Prototype for NetSuite API Call
740bA /copy qcopysrc,p.intapins

     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D today           s              8  0
     D batId           s             11
     D forever         s               n
     D haveBatId       s               n
DRY Ad hrtn            s              8
     D rtnCode         s             10
     D rtnMessage      s            200
740aAd shipweight      s              7s 2
     D stamp           s               z
     D stampUC         s               z
740aAd wrkItem         s             15a
740aAd wrkLbl          s              7s 0
740aAd wrkTrn          s              7s 0
740aAd wrkWhdp         s              5a
740aAd wrkDisp         s             12a
740aAd wrkLcns         s             15a
740aAd zeroUploadDate  s              8s 0
740aAd hostopts        s             20a
740aAd hostoptint      s             20a
740aAd NetSuite        c                   const('NETSUITE')
     *
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

DRY A*
DRY Ad DryExportPgm    pr                  Extpgm('BFCERT03C')
DRY Ad* Input
DRY Ad   $hWhsen                      3  0
DRY Ad   $hbatid                     11
DRY Ad   $hflib                      10
DRY Ad* Output
DRY Ad   $hrtn                        8

740aA /copy qcopysrc,p.getopint

700 A*----------------------------------------------------------------
700 A*  File info data structures
700  *----------------------------------------------------------------
700 A
700 A /COPY qcopysrc,c#file1ds
740aA
740aA*----------------------------------------------------------------
740aA*  File data structures
740aA*----------------------------------------------------------------
740aAd llrecx        e ds                  extname(LICLOG) inz(*EXTDFT)
740aAd lbrecx        e ds                  extname(LABEL) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pWhse3A

     c                   eval      $pWhse = %dec($pWhse3A: 3: 0)
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  Loop through customer rtns that have not been uploaded yet.
     *  (the end of the loop is at the end of the mainline code)

      /free
         haveBatId = *off;
         setll ($pWhse) orrtn4;

         dow forever = forever;

           reade ($pWhse) orrtn4;

740bM      if %eof(orrtn4)
740bM       or orudte <> 0;
             leave;
           endif;

      /end-free
     *
     *  Add customer returns to staging export file.
     *

     *    If first time, get batch id.
     *      If error, get out.

     C                   if        not haveBatId
     C                   exsr      zzzGetBatId
     C                   if        batId = ' '
     C                   leave
     C                   endif
     C                   eval      haveBatId = *on
     C                   endif

     *    Initialize fields and write record.

     C                   exsr      filoe
     C                   write     oerec                                79

     *    Write license records
740aAc                   exsr      zzcrtlic
     *
     *  Update customer return file with upload date and time.
     *
     C                   eval      orudte = today
     C                   time                    orutim
     C                   update    orrec
     *
      /free
         enddo;

         if haveBatId;
           exsr zzzEnd;
DRY A
DRY A      if client = Dairyland;
DRY A        if sqlstt = sqlSuccess;
DRY A          callp(e) DryExportPgm($pwhse:batid:f1library:hrtn);
DRY A        endif;
DRY A      endif;
DRY A
         endif;

      /end-free
     C     bottom        tag
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
740bAc                   parm                    clientinit        3
740bAc                   parm                    clienthost       10
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Define partial key for OPTIONS file.
     *
740aAc     keyop         klist
740aAc                   kfld                    $pwhse
740aAc                   kfld                    opcode
     *
740aA*  Get Host ERP from OPTIONS
740aAc                   eval      opwhse = 1
740aAc                   eval      opcode = '*HOST   '
740aAc     keyop         chain     options
740aAc                   if        not %found(options)
740aAc                   eval      hostopts = '*NONE'
740aAc                   else
740aAc                   movel     opdata        hostopts
740aAc                   endif
740aA *  Get Host ERP from OPTIONINT
740aA /free
740aA   // Get debug flag
740aA   optint.type = 'Interface   ';
740aA   optint.cat  = 'General Options     ';
740aA   optint.name = 'Host ERP System     ';
740aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
740aA             optint.valn: optint.vala: optint.return);
740aA   if optint.return = '*OK';
740aA     hostoptint = optint.vala;
740aA   else;
740aA     hostoptint = '*NONE';
740aA   endif;
740aA
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILOE    Fill export fields.
     *
     C     filoe         begsr
     *
     *  Initialize record
     *
     C                   clear                   oerec
     *
     *  Move fields from item adjustment file to export file.
     *
     C                   eval      oewhse = orwhse
     C                   eval      oeord  = orord
     C                   eval      oeitem = oritem
     C                   eval      oeqty1 = orqty1
     C                   eval      oeqty2 = orqty2
     C                   eval      oeqty3 = orqty3
     C                   eval      oecwtr = orcwtr
     C                   eval      oerdte = orrdte
     C                   eval      oertim = orrtim
     C                   eval      oerusr = orrusr
     C                   eval      oetype = ortype
     C                   eval      oetrn# = ortrn#
     C                   eval      oecitm = orcitm
     C                   eval      oercod = orrcod
     C                   eval      oedcod = ordcod
     C                   eval      oeiinv = oriinv
     C                   move      orolb#        oeolb#
     C                   eval      oeinv# = orinv#
     C                   eval      oermem = orrmem

     C                   exsr      zzzGetStamps
     C                   eval      oebatid = batId
     C                   eval      oestatus = 'R'
     C                   eval      oeststs = stamp
     C                   eval      oestsuc = stampuc
     C                   eval      oeaddts = stamp
     C                   eval      oeadduc = stampuc
     *
     C                   endsr

740aA*----------------------------------------------------------------
740aA*  ZZCRTLIC   Create license export records
740aA*----------------------------------------------------------------
740aA /free
740aA   begsr zzcrtlic;
740aA
740aA     // get tran #s from label file
740aA     if orcitm <> *blanks;
740aA       wrkItem = orcitm;
740aA     else;
740aA       wrkItem = oritem;
740aA     endif;
740aA
740aA     // read label records for returned licenses
740aA     exec sql declare lbcsr cursor for
740aA               select * from label
740aA                where lbpbat = :orpbat
740bM                  and lbitem = :wrkItem;
740bD            //    and lbitem = :orcitm;
740aA
740aA     exec sql open lbcsr;
740aA     if sqlstt = '24502';
740aA       exec sql close lbcsr;
740aA       exec sql open lbcsr;
740aA     endif;
740aA
740aA     exec sql fetch next from lbcsr into :lbrecx;
740aA     if sqlstt <> sqlSuccess;
740aA     endif;
740aA
740aA     // get license from liclog
740aA     exec sql select lllcns,lldisp into :wrkLcns,:wrkDisp
740aA                from liclog
740aA               where llitem   = :wrkItem
740bA                 and lllbl#   = :lblbl#
740bA                 and lltrn#   = :lbtrn#
740bA                 and llaction = 'RTN';
740aA     if sqlstt <> sqlsuccess;
740aA       wrkLcns = *blanks;
740aA     endif;
740aA
740aA     // write license record
740aA     clear orltrec;
740aA     orltwhse   = orwhse;
740aA     orltbatid  = batid;
740aA     orltstatus = 'R';
740aA     orltststs  = stamp;
740aA     orltstsuc  = stampuc;
740aA     orlttext   = *blanks;
740bA     orltord    = orord;
740aA     orltitem   = orItem;
740aA     orltqty1r  = orqty1;
740aA     orltqty2r  = orqty2;
740aA     orltqty3r  = orqty3;
740aA     orltcwtr   = orcwtr;
740aA     orltrdte   = orrdte;
740aA     orltrtim   = orrtim;
740aA     orltusr    = orrusr;
740aA     orlttype   = ortype;
740aA     orlttrn#   = ortrn#;
740aA     orltcitm   = orcitm;
740aA     orltrcod   = ORRCOD;
740aA     orltdcod   = ORDCOD;
740aA     orltiinv   = ORIINV;
740aA     orltolb#   = OROLB#;
740aA     orltinv#   = ORINV#;
740aA     orltrmem   = orrmem;
740aA   //orlthstlot =
740aA     orltlitem  = wrkItem;
740aA     orltqty1   = orqty1;
740aA     orltqty2   = orqty2;
740aA     orltqty3   = orqty3;
740aA     orltlcns   = wrkLcns;
740aA     orltolcns  = wrkLcns;
740aA   //orltpo     =
740aA   //orltposeq  =
740aA   //orltuci    =
740aA   //orltuciseq =
740aA   //orltgtin   =
740aA   //orltdate   =
740aA   //orltdatecd =
740aA   //orltdatenm =
740aA   //orltlot    =
740aA   //orltserial =
740aA   //orltwgt    =
740aA   //orlttrax   =
740aA   //orlttrn    =
740aA     orltaddts  = stamp;
740aA     orltadduc  = stampuc;
740aA
740aA     write orltrec;
740aA
740aA   endsr;
740aA /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------

     c     zzzGetBatId   begsr
      /free

        monitor;
          GetBatId($pWhse: 'EXPRETURN': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------

     c     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

710cA*----------------------------------------------------------------
710cA*  zzzGetWeight   Get item case weight
710cA*----------------------------------------------------------------
710cA /free
710cA  begsr zzzGetWeight;
710cA
710cA   exec sql
710cA     select itswgt into :shipweight from piritem
710cA      where itwhse = :orwhse
710cA        and ititem = :oritem;
710cA
710cA   if sqlstt <> sqlSuccess;
710cA     shipweight = 0;
710cA   endif;
710cA
710cA  endsr; // zzzGetWeight
710cA /end-free

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------

     c     zzzEnd        begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        endif;

740bA   if (hostopts = NetSuite
740bA    or hostoptint = NetSuite
740bA    or clienthost = NetSuite)
740bA    and BatID <> *blanks;
740aA     exec sql insert into EXPTRIG
740aA                values(:orwhse, 'EXPRETURN', :BatId, 'R',
740aA                      current_timestamp,
740aA                      current_timestamp - current_timezone,
740aA                      current_timestamp,
740aA                      current_timestamp - current_timezone);
740bA     if sqlstt <> sqlSuccess;
740bA     endif;

740bA     ApiNS.Whse = %editc($pwhse:'X');
740bA     ApiNS.Batch = BatId;
740bA     ApiNS.Type = 'EXPRETURN';
740bA     IntApiNS(ApiNS.Whse: ApiNS.Batch: ApiNS.Type:
740bA              ApiNS.Ret: ApiNS.Msg);
740bA     if ApiNS.Ret <> '*OK';
740bA     endif;
740bA   endif;

      /end-free
     c                   endsr
