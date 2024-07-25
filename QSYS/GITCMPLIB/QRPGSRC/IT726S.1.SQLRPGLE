640aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT726S    Stage Export - Item adjustments
     *  21 January 2011
     *  Dave Sommerville
     *
     *  This program was based on IT726. All IT726 revision comments
     *  were kept in this program. See 640 notes.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
213 A*    05/20/96  DAS
213 A*      - Added fields IAWHDP, IADISP and IACWTA.
     *
411 A*    07/04/99  DAS 4.11
     *      - Created this program from IT725.
     *
416 A*    12/27/01  DAS  4.16
     *      - Added file ADJMISC.
     *      - Revised to only write a record to the export file if
     *        the adjustment code is defined for updating the Host
     *        system.
     *
500 A*    12/06/05  MLB  5.00
     *      - Enh: Revised program to not write adjustments to export
     *        file that have blank item numbers.
     *
510 A*    07/14/06  MLB  5.10
     *      - Enh: Added client custom code support to program.
510aA*    07/14/06  MLB  5.10a
     *      - Enh: Converted program to ILE.
510aA*    07/17/06  RMC  5.10a
     *      - Enh: Recompile only - added misc. fields to ITEMEXT.
510bA*    08/27/06  MLB  5.10b
     *      - Enh: ITEMEXT file changed. Recompiled program.
610aA*    01/06/10  RH   610a
     *      - Enh: Revised program to NOT export '@' system adjustment
     *
640aA*    01/21/11  DAS  640a
     *      - IT726S created.
     *      - Revised to use new LF ITEMADJ4 instead of opnqryf file.
     *      - Revised to use staging file EXPSADJ instead of EXPFADJ.
     *      - Packers code stripped out.
     *
650 A*    12/04/13  MLB  6.50
     *      - Enh: Added INFDS to EXPSADJ.
     *
700  *    06/23/15  RTR  7.00
     *      - Added check and call to send returns as adjustments.
     *
720a *    03/24/18  RTR  7.20a
     *      - Changed to not send MV adjustments EVER.
     *
730a *    01/15/19  LMC  7.30a
     *      - Added new FlexCap Canopy Adjustment Export file
730b *    10/04/19  LMC   7.30b
     *      - Enh: Adding EXPTRIG for Real Time Export.
730c *    11/11/19  LMC   7.30c
     *      - Enh: We are using a new export file for adjustments.
     *        This file will replace both EXPSADJ & EXPSADJF files.
730d *    06/16/20  RTR   7.30c
     *      - Enh: added type R to Chef's LT creation.
     *
740a *    02/12/20  LMC   7.40a
     *      - Enh: Change the exptrig type to match what we had on
     *        testing on 10.44.0.12 environment.
740bA*    03/09/20  LMC  7.40b
     *      - Revised GetClient to get parms 3 (client initials)
     *        and 4 (Host Sytem Id).
     *      - Added /copy to get Host System Id's
740c *    06/03/20  RTR  7.40c
     *      - Added call to NetSuite Interface API.
740d *    11/04/20  RTR  7.40d
     *      - fix host lot.
750a *    12/17/21  RH   7.50a
     *      - added missed mod 720b  10/14/18  RTR  7.20b
     *      - Changed to call V2 for decimal qty hosts.
760aA*    06/01/22  LMC  7.60a
     *      - Clients using host software FRESHBYTE need to have the  ted
     *        lot number send in the host lot code field ielthstlot
     *        the lot number is stored in the licinfo file.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Aspen Clients
     *
ASPaA*    03/09/20  LMC  ASPa
     *      - Revised to append '-ww' to item numbers, where ww is
     *        the 2-digit warehouse
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*    09/07/09  RH   SVLa
     *      - Revised program to NOT export '@' system adjustments.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hasey
     *
HALaA*    11/11/09  JCJ  HALa
     *      - Revised program to NOT export '@' system adjustments.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
     *
HKW A*    01/18/13  MLB  HKW
     *      - Revised program to map MO adj code to 17 and MP to 18.
     *        Per Carl W. Foodman doesn't support alpha adj codes.
     *      - Added file, ADJCODE to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    12/04/13  MLB  DRY
     *      - Revised pgm to call Host export program, BFCEIA05C to send
     *        exported adjustments to Host JDEdwards system.
     *      - Added /copy mbr, C#FILE1DS to retrieve files library to
     *        pass to Host pgm, along with whse number.
DRYaA*    01/15/19  LMC  DRYa
     *      - Canopy warehouses use the new
DRYb *    10/05/19  RTR  DRYb
     *      - Change references to DM01 for any DM (Del Monte) warehouse.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic
     *
EOPa *    10/11/18  RTR  EOPa
     *      - Revised pgm to break down UOM for adjustment
     *      - Revised pgm to handle -DZ special repack items
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for ITEMADJ
     *
     *----------------------------------------------------------------
     * File Specs
     *
640aDF*temadj   up   e           k disk
640aMFitemadj4  uf   e           k disk
HKW AFadjcode   if   e           k disk    usropn
416 AFadjmisc   if   e           k disk
EOPaAfpiritem   if   e           k disk
640aDF*xpfadj   o  a e           k disk
640aMFexpsadj   o  a e           k disk
730aAFexpsadjF  o  a e           k disk
730cAfexpsadjlt o  a e           k disk
730aAfitemmsc   if   e           k disk
730aAflabel91   if   e           k disk
650 AF                                     infds(file1ds)
730aA*----------------------------------------------------------------
730aA*  File field data structure.
730aA*----------------------------------------------------------------
730aA
730aAD uirec         e ds                  extname(UCIINFO) inz(*EXTDFT)
730aAD uiarec        e ds                  extname(UCIINFOEXA) inz(*EXTDFT)
730aAD ulrec         e ds                  extname(ucilog) inz(*EXTDFT)
730aAD llrec         e ds                  extname(liclog) inz(*EXTDFT)
730cAD lnrec         e ds                  extname(licinfo) inz(*EXTDFT)
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
SVLaA /COPY QCOPYSRC,ID#saval
HALaA /COPY QCOPYSRC,ID#halsey
HKW A /COPY QCOPYSRC,ID#hkw
DRY A /COPY QCOPYSRC,ID#dairyla
EOPaA /COPY QCOPYSRC,ID#eop
740aA /copy qcopysrc,hostsystem
640aA
640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
510 A*
700aA*----------------------------------------------------------------
700aA* Data structure
700aA*
700aA*----------------------------------------------------------------
700aA*  *RETURNS -  Customer Returns options
700aA*----------------------------------------------------------------
700aA*
700aA* Fields
700aA*
700aA*    OPRQCH  -  Allow changes to return quantity. (Y,N).
700aA*    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
700aA*    OPRFLB  -  Force return label entry. (Y/N)
700aA*    OPREXQ  -  Export Quick returns.(Y/N)
700aA*    OPRULB  -  Use label for putaway.(Y/N)
700aA*    OPREAD  -  Export as adjustments. (Y/N)
700aA*    OPREAC  -  Adjustment code to use.
700aA*
700aA* Data structure
700aA*
700aAD oprdta          ds
700aAD  oprqch                 1      1
700aAD  oprqec                 2      2
700aAD  oprflb                 3      3
700aAD  oprexq                 4      4
700aAD  oprulb                 5      5
700aAD  opread                 6      6
700aAD  opreac                 7      8
700aAD  oprend               117    117
700aAD  oprdata                1    117
700aA*
510aA*----------------------------------------------------------------
510aA*  Working variables
510aA*
640aAD batId           s             11
730bAd ExportType      s            117a
640aAD forever         s               n
640aAD haveBatId       s               n
740cAd hostopts        s             20a
740cAd hostoptint      s             20a
DRY Ad hrtn            s              8
EOPaAD pos             s              8s 0
740cAd*NetSuite        c                   const('NETSUITE')
730bAd RealType        s             10
730bAd RealStatus      s              1
730bAd Realststs       s               z
730bAd Realstsuc       s               z
640aAD rtnCode         s             10
640aAD rtnMessage      s            200
640aAD stamp           s               z
640aAD stampUC         s               z
510aAD today           s              8  0
510aAD updhst          s              1
640aAD zeroUploadDate  s              8s 0
     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
760a D freshbyte       c                   const('FRESHBYTE')
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
730cAD*@cvtbar         c                   const('CVTBAR')

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

730bA /copy qcopysrc,p.getoptio
740cA* Prototype for NetSuite API Call
740cA /copy *libl/qcopysrc,p.intapins
740cA /copy *libl/qcopysrc,p.getopint

730cA*----------------------------------------------------------------
730cA*  Data Formats
730cA*----------------------------------------------------------------
730cA /COPY *libl/qcopysrc,C#BARCODE

DRY A*
DRY Ad DryExportPgm    pr                  Extpgm('BFCEIA05C')
DRY Ad* Input
DRY Ad   $hWhsen                      3  0
DRY Ad   $hbatid                     11
DRY Ad   $hflib                      10
DRY Ad* Output
DRY Ad   $hrtn                        8

720bAd it726s2         pr                  extpgm('IT726S2')
720bAd   pWhsea                       3a   const

650 A*----------------------------------------------------------------
650 A*  File info data structures
650  *----------------------------------------------------------------
650 A
650 A /COPY qcopysrc,c#file1ds
650 A

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

640aAc     *entry        plist
640aAc                   parm                    $pWhse3A
640aA
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
640aA
640aA*  Loop through adjustments that have not been uploaded yet.
640aA*  (the end of the loop is at the end of the mainline code)
640aA
640aA /free
640aA    haveBatId = *off;
640aA    setll ($pWhse: zeroUploadDate) itemadj4;
640aA
640aA    dow forever = forever;
640aA
640aA      reade ($pWhse: zeroUploadDate) itemadj4;
640aA
640aA      if %eof(itemadj4);
640aA        leave;
640aA      endif;
640aA
640aA /end-free
416 A*
416 A*  Get system to update.
416 A*
416 AC     iacode        chain     adjmisc                            79
416 AC                   if        not *in79  and
416 AC                             admsys = 'D'
416 AC                   eval      updhst = *off
416 AC                   else
416 AC                   eval      updhst = *on
416 AC                   endif
HKW A*
HKW AC                   select
HKW AC                   when      client = Hearnkirkwood
HKW A*    Retrieve adjcode desc. for mapping adj codes.
HKW AC     iacode        chain     adjcode
HKW AC                   if        not %found(adjcode)
HKW AC                   eval      addesc = ' '
HKW AC                   endif
HKW A*
HKW AC                   endsl
SVLa *
SVLaA*  Saval - Do not export system adj begin with '@'
SVLaAC                   if        client = saval
HALaAC                             or client = halsey
SVLaAC                   movel     iacode        temp1
SVLaAC                   if        temp1 = '@'
SVL AC                   eval      updhst = *off
SVL AC                   endif
SVL AC                   endif
     *
610aA*  Do not export system adj begin with '@'
610aAC                   movel     iacode        temp1             1
610aAC                   if        temp1 = '@'
610aAC                   eval      updhst = *off
610aAC                   endif
720aA
720aA*  Do not export MV adjustments EVER.
720aAC                   if        iacode = 'MV'
720aAC                   eval      updhst = *off
720aAC                   endif
720aA
     *  Add item adjustments to export file.
     *
416 AC                   if        updhst = *on  and
500 AC                             iaitem > *blanks
720aAC                             and iacode <> 'MV'
640aA
640aA*    If first time, get batch id.
640aA*      If error, get out.
640aA
640aAC                   if        not haveBatId
640aAC                   exsr      zzzGetBatId
640aAC                   if        batId = ' '
640aAC                   leave
640aAC                   endif
640aAC                   eval      haveBatId = *on
640aAC                   endif
640aA
640aA*    Initialize fields and write record.
640aA
     C                   exsr      filie
EOPaA /free
EOPaA    //  For Earl's, convert qtys
EOPaA    if client = EarlsOrganic;
EOPaA      exsr zzEOPconvert;
EOPaA    endif;
EOPaA /end-free
730dA /free
730dA      GetOptions(%editc(0:'X'):
730dA                 '*FTP': '001': '001': ExportType);
730dA /end-free
ASPaDc*                  if        client = Dairyland
ASPaDc*                            and %subst(clientloc:1:2) = 'DM'
730dAc*                            or ExportType = 'R'
ASPaMc                   if        clienthost = Aspen
730aAC                   write     iefrec                               79
730cAc                   write     ieltrec
730aAc                   else
     C                   write     ierec                                79
730cAc                   write     ieltrec
730aAc                   endif
640aA
416 AC                   endif
     *
     *  Update item adjustment file with upload date and time.
     *
     C                   eval      iaudte = today
     C                   time                    iautim
     C                   update    iarec
     *
640aA /free
640aA    enddo;
700aA
700aA   // Check to see if returns need to be sent.
700aA   // Get options record for returns.
700aA   exec sql select opdata into :oprdata from options
700aA             where opwhse = :$pwhse
700aA               and opcode = '*RETURNS';
700aA   if sqlstt <> sqlSuccess;
700aA     clear oprdata;
700aA   endif;
700aA /end-free
700aAC                   if        opread = 'Y'
700aAC                   call      'OR737S'
700aAC                   parm                    $pWhse3a
700aAC                   parm                    BatId
700aAC                   parm                    rtnCode
700aAC                   parm                    rtnMessage
700aAC                   if        BatId <> *blank
700aAC                   eval      haveBatId = *on
700aAC                   endif
700aAC                   endif
700aA /free
640aA
640aA    if haveBatId;
640aA      exsr zzzEnd;
DRY A
DRY A      if client = Dairyland
ASPaM       and clienthost <> Aspen;
ASPaD       //and %subst(clientloc:1:2) <> 'DM';
DRY A        if sqlstt = sqlSuccess;
DRY A          callp(e) DryExportPgm($pwhse:batid:f1library:hrtn);
DRY A        endif;
DRY A      endif;
DRY A
730bA      // Is this real time staging
730bA      GetOptions(%editc(0:'X'):
730bA                 '*FTP': '001': '001': ExportType);
730bA      if ExportType = 'R';
740aD        //RealType = 'ITEMADJ';
740aM        RealType = 'EXPADJUST';
730bA        RealStatus = 'R';
730bA        exsr zzzGetStamps;
730bA        Realststs  = stamp;
730bA        Realstsuc  = stampuc;
730bA        exec sql
730bA         insert into exptrig
730bA         values (:$pWhse,:RealType,:batid,:RealStatus,
730bA                 :Realststs,:Realstsuc,:Realststs,:Realstsuc);
730bA
730bA      endif;
640aA    endif;
640aA
640aA /end-free
     C     bottom        tag
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510 A*
510 A* Get client id.
510 A*
510 AC                   call      'GETCLIENT'
510 AC                   parm                    client           10
510 AC                   parm                    clientloc        10
740aAC                   parm                    cliInit           3
740aAC                   parm                    clienthost       10
510 A*
HKW AC                   select
HKW AC                   when      client = Hearnkirkwood
HKW AC                   if        not %open(adjcode)
HKW AC                   open      adjcode
HKW AC                   endif
720bA /free
EOPaA   when client = EarlsOrganic;
EOPaA     callp it726s2($pWhse3A);
EOPaA     return;
720bA /end-free
HKW AC                   endsl
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
740cA /free
740cA *  Get Host ERP from OPTIONS
740cA    GetOptions(%editc(0:'X'):
740cA                 '*HOST': '001': '010': ExportType);
740cA    hostopts = ExportType;
740cA *  Get Host ERP from OPTIONINT
740cA   // Get debug flag
740cA   optint.type = 'Interface   ';
740cA   optint.cat  = 'General Options     ';
740cA   optint.name = 'Host ERP System     ';
740cA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
740cA             optint.valn: optint.vala: optint.return);
740cA   if optint.return = '*OK';
740cA     hostoptint = optint.vala;
740cA   else;
740cA     hostoptint = '*NONE';
740cA   endif;
740cA /free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILIE    Fill export fields.
     *
     C     filie         begsr
     *
     *  Initialize record
     *
     C                   clear                   ierec
730aAC                   clear                   iefrec
730cAC                   clear                   ieltrec
     *
     *  Move fields from item adjustment file to export file.
     *
     C                   eval      iewhse = iawhse
     C                   eval      ieitem = iaitem
     C                   eval      iedate = iadate
     C                   eval      ietime = iatime
     C                   eval      ieby = iaby
213 AC                   eval      iewhdp = iawhdp
213 AC                   eval      iedisp = iadisp
213 AC                   eval      iecwta = iacwta
     C                   eval      ieqty1 = iaqty1
     C                   eval      ieqty2 = iaqty2
     C                   eval      ieqty3 = iaqty3
730cA * loading up the new file
730cAC                   eval      ieltwhs = iawhse
730cAC                   eval      ieltitem = iaitem
730cAC                   eval      ieltadate = iadate
730cAC                   eval      ieltatime = iatime
730cAC                   eval      ieltby = iaby
730cAC                   eval      ieltwhdp = iawhdp
730cAC                   eval      ieltdisp = iadisp
730cAC                   eval      ieltqty1 = iaqty1
730cAC                   eval      ieltqty2 = iaqty2
730cAC                   eval      ieltqty3 = iaqty3
730cAC                   eval      ieltwgt  = iacwta
HKW A*
HKW AC                   select
HKW AC                   when      client = hearnkirkwood
HKW A*
HKW AC                   if           (iacode = 'MO'
HKW AC                              or iacode = 'MP')
HKW AC                             and %subst(addesc:29:2) > ' '
HKW AC                   eval      iecode = %subst(addesc:29:2)
730cAC                   eval      ieltadjcd = %subst(addesc:29:2)
HKW AC                   else
HKW AC                   eval      iecode = iacode
730cCC                   eval      ieltadjcd = iacode
HKW AC                   endif
HKW AC
HKW AC                   other
HKW A*
     C                   eval      iecode = iacode
730aCC                   eval      ieltadjcd = iacode
     C                   endsl
HKW A*
     C                   eval      iememo = iamemo
730cAC                   eval      ieltmemo = iamemo

640aAC                   exsr      zzzGetStamps
640aAC                   eval      iebatid = batId
640aAC                   eval      iestatus = 'R'
640aAC                   eval      ieststs = stamp
640aAC                   eval      iestsuc = stampuc
640aAC                   eval      ieaddts = stamp
640aAC                   eval      ieadduc = stampuc
730cA *  more fields
730cAC                   eval      ieltbatid = batId
730cAC                   eval      ieltstatus = 'R'
730cAC                   eval      ieltststs = stamp
730cAC                   eval      ieltstsuc = stampuc
730cAC                   eval      ieltaddts = stamp
730caC                   eval      ieltadduc = stampuc
730aAc*** fill new file fields
730cDc*                  if        client = Dairyland
730cDc*                            and %subst(clientloc:1:2) <> 'DM'
730aA /free
730aA   // is this Item UCI tracked?
730aA   chain (iawhse:iaitem) itemmsc;
730aA   if not %found(itemmsc);
730aA     clear imrec;
730aA   endif;
730aA   if imltrk = 'U';
730aA     chain (iawhse: iaitem: iadate: iatime) label91;
730aA     if %found(label91);
730aA       // now I need the ucilog record
730aA       exec sql select * into :ulrec from ucilog
730aA               where ulwhse = :iawhse
730aA                 and ullbl# = :lblbl#;
730aA       if sqlstt = sqlSuccess;
730aA         exec sql select * into :uirec from uciinfo
730aA                 where uiwhse = :ulwhse
730aA                   and uiuci = :uluci
730cA                   and uiseltrn# = 0;
730aA         if sqlstt = sqlSuccess;
730aA           exec sql select * into :uiarec from uciinfoexa
730aA                   where uiaaddts = :uiaddts
730aA                     and uiaucilcns = :uiucilcns
730aA                     and uialcns = :uilcns;
730aA           if sqlstt = sqlSuccess;
730aA             // finally now I can write the ieucilot field
730aA             // we are using the ieucilot as the host lot field
730aA             // I'm using the same logic we use in PO726 to
730aA             // hierachy of the data for the IELLCNS field
730aA             select;
760aA               when clienthost = freshbyte and uialot <> ' ';
760aA                 ieucilot= uialot;
760aA                 ielthstlot= ' ';
760aA                 // get the licinfo for original so we can get lot
760aA                 exec sql select * into :lnrec from licinfo
760aA                      where lnwhse = :iawhse
760aA                        and lnlcns = :uiaolcns
760aA                        and lnseq = 1;
760aA                 if sqlstt = sqlSuccess;
760aA                   ielthstlot = lnlot;
760aA                 endif;
730aA               when uiserial <> ' ';
730aA                 ieucilot= uiserial;
730cA                 ielthstlot= uiserial;
730aA               when uialot <> ' ';
730aA                 ieucilot= uialot;
730cA                 ielthstlot= uialot;
730aA               when %subst(uiuci:1:3) = '99I';
730aA                 ieucilot= uiuci;
730cA                 ielthstlot= uiuci;
730aA               other;
730aA                 //ieucilot= ullcns;
730aA                 ieucilot = uiaolcns;
730cA                 ielthstlot = uiaolcns;
730aA             endsl;
730cA             ieltlcns = uialcns;
730cA             ieltolcns = uiaolcns;
730aA           else;
730aA             clear uiarec;
730aA           endif;
730aA         else;
730aA           clear uirec;
730aA         endif;
730aA       endif;
730aA     else;
730aA       clear lbrec;
730aA     endif;
730aA     ieuci =  uiuci;
730aA     ieuciseq# = 0;
730aA     ieucigtin = %CHAR(uiagtin);
730aA     ieuciser# = uiserial;
730c   // more fields
730cA     ieltuci =  uiuci;
730cA     ieltuciseq = 0;
730cA     ieltgtin = %CHAR(uiagtin);
730cA     ieltserial = uiserial;
730cA     // in order to get date info will need to send to cvtbar
730cA /end-free
730cAC                   call      'CVTBAR'
730cAC                   parm      '*ALL'        $cbcmd            8
730cAC                   parm      ieltuci       $cbbar          100
730cAC                   parm                    $cbcod            3 0
730cAC                   parm                    $cbdec            1 0
730cAC                   parm                    $cbdsc           30
730cAC                   parm                    $cbpos            3 0
730cAC                   parm                    $cbtyp            1 0
730cAC                   parm                    $cbv1            11 3
730cAC                   parm                    $cbv2            50
730cAC                   parm                    $cbrtn            8
730cAC                   parm                    $cberm           60
730cAC                   parm                    $cbven           10 0
730cAC                   parm                    $cvtdata        256
730cAC                   parm                    $cvtdata2       256
730cAc                   eval      $barcode = $cvtdata
730cAc                   eval      $barcode2 = $cvtdata2
730cA /free
730cA   select;
730cA     when $bcProdDSent;
730cA       ieltdate = $bcProdD;
730cA       ieltdatecd = '11';
730cA       ieltdatenm = 'PROD';
730cA     when $bcPackDSent;
730cA       ieltdate = $bcPackD;
730cA       ieltdatecd = '13';
730cA       ieltdatenm = 'PACK';
730cA     when $bcSlByDSent;
730cA       ieltdate = $bcSlByD;
730cA       ieltdatecd = '15';
730cA       ieltdatenm = 'BEST';
730cA     when $bcExpDSent;
730cA       ieltdate = $bcExpD;
730cA       ieltdatecd = '17';
730cA       ieltdatenm = 'EXP';
730cA   endsl;
730cA   if $bcLotSent;
730cA     ieltlot = $bclot;
730cA   endif;
730aA   else;
730aA     chain (iawhse: iaitem: iadate: iatime) label91;
730aA     if %found(label91);
730aA       // now I need the liclog record
730aA       exec sql select * into :llrec from liclog
730aA               where llwhse = :iawhse
730aA                 and lllbl# = :lblbl#
730aA                 and llaction = 'ADJ'
730aA                 and lltrn# = 0;
730aA       if sqlstt = sqlSuccess;
730aA         ieucilot = llolcns;
740dA       //ielthstlot = llolcns;
760aA         // for host freshbyte we load up the host lot from the
760aA         // licinfo record later
760aA         if clienthost = freshbyte;
760aA           ielthstlot = ' ';
760aA         else;
740dA           ielthstlot = lllcns;
760aA         endif;
730cA         ieltlcns = lllcns;
730cA         ieltolcns = llolcns;
730aA       endif;
730aA     endif;
730aA     ieuci =  ' ';
730aA     ieuciseq# = 0;
730aA     ieucigtin = ' ';
730aA     ieuciser# = ' ';
730cA  // more fields
730cA     ieltuci =  ' ';
730cA     ieltuciseq = 0;
730cA     ieltgtin = ' ';
730cA     ieltserial = ' ';
730aA   endif;
730cA   // get the licinfo for original
730cA   exec sql select * into :lnrec from licinfo
730cA           where lnwhse = :iawhse
730cA             and lnlcns = :ieltolcns
730cA             and lnseq = 1;
730cA   if sqlstt = sqlSuccess;
730cA     ieltpo = lnpo;
730cA     ieltposeq = lnposeq;
730cA     ieltbrd = lnbrand;
760aA     // for host freshbyte we load up the host lot from licinfo
760aA     if clienthost = freshbyte;
760aA       ielthstlot = lnlot;
760aA     endif;
730cA   endif;
730aA /end-free
DRYaAc*** need a link to the uci file in order to populate these fields
730aAc                   eval      ienotes   =
730aAc                              %XLATE('|': ' ': iememo)
730cAc                   eval      ieltmemo  =
730cAc                              %XLATE('|': ' ': iememo)
730cDc**                 endif
     *
     C                   endsr

EOPaA*----------------------------------------------------------------
EOPaA*  zzEOPConvert   Earls - Convert qty for breakdown
EOPaA*----------------------------------------------------------------
EOPaA
EOPaA /free
EOPaA   begsr zzEOPConvert;
EOPaA
EOPaA     chain (iawhse: iaitem) piritem;
EOPaA     if %found();
EOPaA       // Look for '-DZ' 2.5 DZ repack item;
EOPaA       pos = %scan('-DZ': ititem);
EOPaA       select;
EOPaA         when pos > 0;
EOPaA           ieitem = %subst(ititem: 1: pos-1);
EOPaA         when itum1 = 'D2';
EOPaA           ieqty1 = (ieqty1 * 2.5) + (ieqty2 / 2);
EOPaA           ieqty2 = 0;
EOPaA         when itflg1 = 'Y';
EOPaA           ieqty1 = (ieqty1 * itumq2) + ieqty2;
EOPaA           ieqty2 = 0;
EOPaA       endsl;
EOPaA     endif;
EOPaA
EOPaA   endsr; // zzEOPConvert
EOPaA /end-free

640aA*----------------------------------------------------------------
640aA*  zzzGetBatId    Get batch id
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetBatId   begsr
      /free

        monitor;
          GetBatId($pWhse: 'EXPADJUST': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
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

640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
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

740cA   if (hostopts = NetSuite
740cA    or hostoptint = NetSuite
740cA    or clienthost = NetSuite)
740cA    and BatID <> *blanks;
740cA     ApiNS.Whse = %editc($pwhse:'X');
740cA     ApiNS.Batch = BatId;
740cA     ApiNS.Type = 'EXPADJUST ';
740cA     IntApiNS(ApiNS.Whse: ApiNS.Batch: ApiNS.Type:
740cA              ApiNS.Ret: ApiNS.Msg);
740cA     if ApiNS.Ret <> '*OK';
740cA     endif;
740cA   endif;

      /end-free
     c                   endsr
