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
760bA*    08/04/22  LMC  7.60b
     *      - Netsuite clents will only send one qty field at a time. ted
     *        If a user adjusts normal, breakdown1 & breakdown 2 at
     *        the same time we allow this in Dakota, but we need to
     *        send those to Netsuite as individual adjustments.
     *        if the adjustment has a weight entered, we will send
     *        the weight with the largest breakdown.
760cA*    09/30/22  LMC  7.60c
     *      - Fresh Byte clients need to do the adjustments one uom atted
     *        a time just like Netsuite.
760dA*    12/05/22  DAS  7.60d
     *      - Replaced using FILIE routine with FillRec and WriteRec
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
760dAFliclog2   if   e           k disk    rename(llrec: llrec2)
730aA*----------------------------------------------------------------
730aA*  File field data structure.
730aA*----------------------------------------------------------------
730aA
730aAD uirec         e ds                  extname(UCIINFO) inz(*EXTDFT)
730aAD uiarec        e ds                  extname(UCIINFOEXA) inz(*EXTDFT)
730aAD ulrec         e ds                  extname(ucilog) inz(*EXTDFT)
730cAD llrec         e ds                  extname(liclog) inz(*EXTDFT)
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
760bAD qtySent         s              2

760dAd splitQtyTypes   s               n
760dAd uciTracked      s               n
760dAd kytrn#          s                   like(lbtrn#)
760dAd kylbl#          s                   like(lblbl#)

     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
760dDD*freshbyte       c                   const('FRESHBYTE')
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
760dD**   Initialize fields and write record.
760dD **
760dDC**                 exsr      filie

760dA    // Initialize general export fields
760dA
760dA    exsr FillRec;
760dA
760dA    // Write EXPSADJ rec when not using Aspen
760dA
760dA    if clienthost <> Aspen;
760dA      exsr WriteExport;
760dA    endif;
760dA
760dA    // Write EXPSADJLT and EXPSADJF (Aspen) recs
760dA
760dA    exsr WriteLicenses;

760dD /free
760dD    //  For Earl's, convert qtys
760dD    //if client = EarlsOrganic;
760dD    //  exsr zzEOPconvert;
760dD    //endif;
760dD /end-free
730dA /free
760dD   // GetOptions(%editc(0:'X'):
760dD   //            '*FTP': '001': '001': ExportType);
730dA /end-free
ASPaDc*                  if        client = Dairyland
ASPaDc*                            and %subst(clientloc:1:2) = 'DM'
730dAc*                            or ExportType = 'R'
760dDc**                 if        clienthost = Aspen
760dDC**                 write     iefrec                               79
760dDc**                 write     ieltrec
760dDc**                 else
760dDC**                 write     ierec                                79
760dDc**                 write     ieltrec
760bA /free
760dD  // Select;
760dD  //   when (hostopts = NetSuite
760dD  //      or hostoptint = NetSuite
760dD  //      or clienthost = NetSuite
760dD  //     or clienthost = freshbyte);
760dD       // do I need to send more qty records
760dD  //     Select;
760dD  //       when qtySent = 'N';
760dD  //         if iaqty2 <> 0;
760dD             // load qty field blank cw field and write records
760dD  //           ieqty2 = iaqty2;
760dD  //          ieqty1 = 0;
760dD  //           ieqty3 = 0;
760dD  //           iecwta = 0;
760dD  //           ieltqty2 = iaqty2;
760dD  //           ieltqty1 = 0;
760dD  //           ieltqty3 = 0;
760dD  //           ieltwgt = 0;
760dD  //           write ierec;
760dD  //           write ieltrec;
760dD  //         endif;
760dD  //         if iaqty3 <> 0;
760dD             // load qty field blank cw field and write records
760dD  //           ieqty3 = iaqty3;
760dD  //           ieqty1 = 0;
760dD  //           ieqty2 = 0;
760dD  //           iecwta = 0;
760dD  //           ieltqty3 = iaqty3;
760dD  //           ieltqty1 = 0;
760dD  //           ieltqty2 = 0;
760dD  //           ieltwgt = 0;
760dD  //           write ierec;
760dD  //           write ieltrec;
760dD  //         endif;
760dD  //       when qtySent = 'B1';
760dD  //         if iaqty3 <> 0;
760dD             // load qty field blank cw field and write records
760dD  //           ieqty3 = iaqty3;
760dD  //           ieqty1 = 0;
760dD  //           ieqty2 = 0;
760dD  //           iecwta = 0;
760dD  //           ieltqty3 = iaqty3;
760dD  //           ieltqty1 = 0;
760dD  //           ieltqty2 = 0;
760dD  //           ieltwgt = 0;
760dD  //           write ierec;
760dD  //           write ieltrec;
760dD  //         endif;
760dD  //     endsl;
760dD  // endsl;
760dDc**                 endif
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
760bA /free
760bA   qtySent = ' ';
760bA   Select;
760bA     when (hostopts = NetSuite
760bA        or hostoptint = NetSuite
760bA        or clienthost = NetSuite
760cA        or clienthost = freshbyte);
760bA       // determine which qty the weight will be sent with
760bA       if iaqty1 <> 0;
760bA         ieqty1 = iaqty1;
760bA         ieqty2 = 0;
760bA         ieqty3 = 0;
760bA         qtySent = 'N';
760bA         if iacwta <> 0;
760bA           iecwta = iacwta;
760bA         endif;
760bA       else;
760bA         if iaqty2 <> 0;
760bA           ieqty2 = iaqty2;
760bA           ieqty1 = 0;
760bA           ieqty3 = 0;
760bA           qtySent = 'B1';
760bA           if iacwta <> 0;
760bA             iecwta = iacwta;
760bA           endif;
760bA         else;
760bA           if iaqty3 <> 0;
760bA             ieqty3 = iaqty3;
760bA             ieqty1 = 0;
760bA             ieqty2 = 0;
760bA             qtySent = 'B2';
760bA             if iacwta <> 0;
760bA               iecwta = iacwta;
760bA             endif;
760bA           endif;
760bA         endif;
760bA       endif;
760bA     other;
760bA       iecwta = iacwta;
760bA       ieqty1 = iaqty1;
760bA       ieqty2 = iaqty2;
760bA       ieqty3 = iaqty3;
760bA   endsl;
760bA /end-free
760bDC*                  eval      iecwta = iacwta
760bDC*                  eval      ieqty1 = iaqty1
760bDC*                  eval      ieqty2 = iaqty2
760bDC*                  eval      ieqty3 = iaqty3
730cA * loading up the new file
730cAC                   eval      ieltwhs = iawhse
730cAC                   eval      ieltitem = iaitem
730cAC                   eval      ieltadate = iadate
730cAC                   eval      ieltatime = iatime
730cAC                   eval      ieltby = iaby
730cAC                   eval      ieltwhdp = iawhdp
730cAC                   eval      ieltdisp = iadisp
760bA /free
760bA   Select;
760bA     when (hostopts = NetSuite
760bA        or hostoptint = NetSuite
760bA        or clienthost = NetSuite
760cA        or clienthost = freshbyte);
760bA       // determine which qty the weight will be sent with
760bA       if iaqty1 <> 0;
760bA         ieltqty1 = iaqty1;
760bA         ieltqty2 = 0;
760bA         ieltqty3 = 0;
760bA         if iacwta <> 0;
760bA           ieltwgt = iacwta;
760bA         endif;
760bA       else;
760bA         if iaqty2 <> 0;
760bA           ieltqty2 = iaqty2;
760bA           ieltqty1 = 0;
760bA           ieltqty3 = 0;
760bA           if iacwta <> 0;
760bA             ieltwgt = iacwta;
760bA           endif;
760bA         else;
760bA           if iaqty3 <> 0;
760bA             ieltqty3 = iaqty3;
760bA             ieltqty1 = 0;
760bA             ieltqty2 = 0;
760bA             if iacwta <> 0;
760bA               ieltwgt = iacwta;
760bA             endif;
760bA           endif;
760bA         endif;
760bA       endif;
760bA     other;
760bA       ieltqty1 = iaqty1;
760bA       ieltqty2 = iaqty2;
760bA       ieltqty3 = iaqty3;
760bA       ieltwgt  = iacwta;
760bA   endsl;
760bA /end-free
760bDC*                  eval      ieltqty1 = iaqty1
760bDC*                  eval      ieltqty2 = iaqty2
760bDC*                  eval      ieltqty3 = iaqty3
760bDC*                  eval      ieltwgt  = iacwta
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

760dA*----------------------------------------------------------------
760dA*
760dA*  FillRec  Fill export fields.
760dA*
760dAC     FillRec       begsr

730aA   // is this Item UCI tracked?
730aA   chain (iawhse:iaitem) itemmsc;
730aA   if %found(itemmsc) and imltrk = 'U';
760aA     uciTracked = *on;
760aA   else;
760aA     uciTracked = *off;
730aA   endif;

760dA   // See if we should create 1 rec per qty type
760dA
760dA   if hostopts = NetSuite
760dA      or hostoptint = NetSuite
760dA      or clienthost = NetSuite
760dA      or clienthost = freshbyte;
760dA        splitQtyTypes = *on;
760dA   else;
760dA        splitQtyTypes = *off;
760dA   endif;

      //  Initialize records

       clear ierec;
730aA  clear iefrec;
730cA  clear ieltrec;

       //  Move fields from item adjustment file to export file.

       iewhse = iawhse;
       ieitem = iaitem;
       iedate = iadate;
       ietime = iatime;
       ieby = iaby;
213 A  iewhdp = iawhdp;
213 A  iedisp = iadisp;

730cA  ieltwhs = iawhse;
730cA  ieltitem = iaitem;
730cA  ieltadate = iadate;
730cA  ieltatime = iatime;
730cA  ieltby = iaby;
730cA  ieltwhdp = iawhdp;
730cA  ieltdisp = iadisp;

HKW A  select;
HKW A  when client = hearnkirkwood;
HKW A    if (iacode = 'MO'
HKW A          or iacode = 'MP')
HKW A          and %subst(addesc:29:2) > ' ';
HKW A      iecode = %subst(addesc:29:2);
730cA      ieltadjcd = %subst(addesc:29:2);
HKW A    else;
HKW A      iecode = iacode;
730cC      ieltadjcd = iacode;
HKW A    endif;
HKW A  other;
         iecode = iacode;
730aC    ieltadjcd = iacode;
       endsl;
HKW A
       iememo = iamemo;
730cA  ieltmemo = %XLATE('|': ' ': iememo);

640aA  exsr zzzGetStamps;
640aA  iebatid = batId;
640aA  iestatus = 'R';
640aA  ieststs = stamp;
640aA  iestsuc = stampuc;
640aA  ieaddts = stamp;
640aA  ieadduc = stampuc;

730cA  ieltbatid = batId;
730cA  ieltstatus = 'R';
730cA  ieltststs = stamp;
730cA  ieltstsuc = stampuc;
730cA  ieltaddts = stamp;
730ca  ieltadduc = stampuc;

     C                   endsr

760dA*----------------------------------------------------------------
760dA*  GetLICINFO  Get LICINFO record
760dA*----------------------------------------------------------------
760dAC     GetLICINFO    begsr

730cA   // get the licinfo for original
730cA   exec sql select * into :lnrec from licinfo
730cA           where lnwhse = :iawhse
730cA             and lnlcns = :ieltolcns
730cA             and lnseq = 1;
730cA   if sqlstt <> sqlSuccess;
          clear lnrec;
        endif;

     C                   endsr

760dA*----------------------------------------------------------------
760dA*  GetUCIInfo   Get UCI info
760dA*----------------------------------------------------------------
760dAC     GetUCIInfo    begsr

        if uluci <> '';
730aA     exec sql select * into :uirec from uciinfo
730aA               where uiwhse = :ulwhse
730aA                 and uiuci = :uluci
730cA                 and uiseltrn# = 0;
          if sqlstt <> sqlSuccess;
            clear uirec;
          endif;
        endif;

        // Get UCIINFOEXA for info rec

        if uilcns <> '';
730aA     exec sql select * into :uiarec from uciinfoexa
730aA               where uiaaddts = :uiaddts
730aA                 and uiaucilcns = :uiucilcns
730aA                 and uialcns = :uilcns;
          if sqlstt <> sqlSuccess;
            clear uiarec;
          endif;
        endif;

        // Extract date and lot from uci barcode value

730cAC                   call      'CVTBAR'
730cAC                   parm      '*ALL'        $cbcmd            8
730cAC                   parm      uiuci         $cbbar          100
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

730cA   $barcode = $cvtdata;
730cA   $barcode2 = $cvtdata2;

     C                   endsr

760dA*----------------------------------------------------------------
760dA*  WriteExport  Write EXPSADJ rec from ITEMADJ
760dA*----------------------------------------------------------------
760dAC     WriteExport   begsr

EOPaA     //  For Earl's, convert qtys
EOPaA     if client = EarlsOrganic;
EOPaA       exsr zzEOPconvert;
EOPaA     endif;

          // Write single EXPSADJLT rec when not splitting qty types

          if not splitQtyTypes;
            ieqty1 = iaqty1;
            ieqty2 = iaqty2;
            ieqty3 = iaqty3;
            iecwta = iacwta;
            write ierec;
          endif;

          // Write multiple EXPSADJLT recs when splitting qty types
          // Entire wgt will be applied to first qty type written

          if splitQtyTypes and iaqty1 <> 0;
            ieqty1 = iaqty1;
            ieqty2 = 0;
            ieqty3 = 0;
            iecwta  = iacwta;
            write ierec;
          endif;

          if splitQtyTypes and iaqty2 <> 0;
            ieqty1 = 0;
            ieqty2 = iaqty2;
            ieqty3 = 0;
            if iaqty1 = 0;
              iecwta = iacwta;
            endif;
            write ierec;
          endif;

          if splitQtyTypes and iaqty3 <> 0;
            ieqty1 = 0;
            ieqty2 = 0;
            ieqty3 = iaqty3;
            if iaqty1 = 0 and iaqty2 = 0;
              iecwta = iacwta;
            endif;
            write ierec;
          endif;

     C                   endsr

760dA*----------------------------------------------------------------
760dA*  WriteLicenses  Write license recs from LICLOG
760dA*----------------------------------------------------------------
760dAC     WriteLicenses begsr

        // Loop through LABEL records for adj date/time

        setll (iawhse: iaitem: iadate: iatime) label91;

        dow forever = forever;

          reade (iawhse: iaitem: iadate: iatime) label91;
          if %eof(label91);
            leave;
          endif;

          // Check Label type

          select;

            when lbtype = 'A';
              // Normal adjustment, Ok to move on
              // Note, when a case and an each are adjusted at
              // the same time, there will be 2 label records but
              // for a non-UCI item, only 1 LICLOG record. Therefore,
              // one of the calls to WriteNonUCI will not find
              // a LICLOG rec, which is ok.

            when lbtype = 'T' and lbgrp1 = '2';
              // Change Item transfer adjustment, Ok to move on

            other;
              iter;

          endsl;

          // Call appropriate routine for item

          if uciTracked;
            exsr WriteUCI;
          else;
            exsr WriteNonUCI;
          endif;

        enddo;

     C                   endsr

760dA*----------------------------------------------------------------
760dA*  WriteNonUCI     Write export recs using LICLOG file
760dA*----------------------------------------------------------------
760dAC     WriteNonUCI   begsr

        // For a normal adj the LICLOG rec only has a lbl#
        // For a chg item adj the LICLOG rec only has a trn#

        select;
          when lbtype = 'T';
            kytrn# = lbtrn#;
            kylbl# = 0;
          when lbtype = 'A';
            kytrn# = 0;
            kylbl# = lblbl#;
          other;
            leavesr;
        endsl;

        // Loop through LICLOG recs for Label

        setll (lbwhse: kytrn#: kylbl#) liclog2;

        dow forever = forever;

          reade (lbwhse: kytrn#: kylbl#) liclog2;
          if %eof(liclog2);
            leave;
          endif;

          // Make sure action matches adjustment label type

          if (lbtype = 'T' and llaction <> 'TFR')
             or (lbtype = 'A' and llaction <> 'ADJ');
               iter;
          endif;

          // Only work with Slot records

          if llcode <> 'S';
            iter;
          endif;

          // For first rec of chg item, work with negative qty

          if lbtype = 'T' and lbgrp2 = 'A';
            if llaqty1 > 0 or llaqty2 > 0 or llaqty3 > 0;
              iter;
            endif;
          endif;

          // For second rec of chg item, work with positive qty

          if lbtype = 'T' and lbgrp2 = 'B';
            if llaqty1 < 0 or llaqty2 < 0 or llaqty3 < 0;
              iter;
            endif;
          endif;

          // Fill in export fields

          ielthstlot = llolcns;
          ieltlcns = lllcns;
          ieltolcns = llolcns;

          exsr GetLICINFO;

730cA     ieltpo = lnpo;
730cA     ieltposeq = lnposeq;
730cA     ieltbrd = lnbrand;

760aA     // for host freshbyte we load up the host lot from licinfo

760aA     if clienthost = freshbyte;
760aA       ielthstlot = lnlot;
760aA     endif;

          // Fill in fields for Aspen EXPSADJF file

          if clienthost = Aspen;
            ieuci = '';
            ieuciseq# = 0;
            ieucigtin = '';
            ieucilot = ielthstlot;
            ieuciser# = '';
            ienotes = ieltmemo;
          endif;

          // Write single EXPSADJLT/F rec when not splitting qty types

          if not splitQtyTypes;
            ieltqty1 = llaqty1;
            ieltqty2 = llaqty2;
            ieltqty3 = llaqty3;
            ieltwgt  = iacwta;
            write ieltrec;
            if clienthost = Aspen;
              ieqty1 = ieltqty1;
              ieqty2 = ieltqty2;
              ieqty3 = ieltqty3;
              iecwta = ieltwgt;
              write iefrec;
            endif;
          endif;

          // Write multiple EXPSADJLT/F recs when splitting qty types
          // Entire wgt will be applied to first qty type written

          if splitQtyTypes and llaqty1 <> 0;
            ieltqty1 = iaqty1;
            ieltqty2 = 0;
            ieltqty3 = 0;
            ieltwgt  = iacwta;
            write ieltrec;
            if clienthost = Aspen;
              ieqty1 = ieltqty1;
              ieqty2 = ieltqty2;
              ieqty3 = ieltqty3;
              iecwta = ieltwgt;
              write iefrec;
            endif;
          endif;

          if splitQtyTypes and llaqty2 <> 0;
            ieltqty1 = 0;
            ieltqty2 = llaqty2;
            ieltqty3 = 0;
            if llaqty1 = 0;
              ieltwgt = iacwta;
            endif;
            write ieltrec;
            if clienthost = Aspen;
              ieqty1 = ieltqty1;
              ieqty2 = ieltqty2;
              ieqty3 = ieltqty3;
              iecwta = ieltwgt;
              write iefrec;
            endif;
          endif;

          if splitQtyTypes and llaqty3 <> 0;
            ieltqty1 = 0;
            ieltqty2 = 0;
            ieltqty3 = llaqty3;
            if llaqty1 = 0 and llaqty2 = 0;
              ieltwgt = iacwta;
            endif;
            write ieltrec;
            if clienthost = Aspen;
              ieqty1 = ieltqty1;
              ieqty2 = ieltqty2;
              ieqty3 = ieltqty3;
              iecwta = ieltwgt;
              write iefrec;
            endif;
          endif;

        enddo;

     C                   endsr

760dA*----------------------------------------------------------------
760dA*  WriteUCI      Write export recs using UCILOG file
760dA*----------------------------------------------------------------
760dAC     WriteUCI      begsr

        // Get UCI Log rec
        // It is assumed there is only 1 UCI per adj Label rec

730aA   exec sql select * into :ulrec from ucilog
730aA             where ulwhse = :iawhse
730aA               and ullbl# = :lblbl#;

        if sqlstt <> sqlSuccess;
          clear ulrec;
        endif;

        // Get UCI info for log rec

        exsr GetUCIINFO;

        // Now we can fill in the export fields

        if uialcns <> '';
730cA     ieltlcns = uialcns;
730cA     ieltolcns = uiaolcns;
        else;
730cA     ieltlcns = ullcns;
730cA     ieltolcns = ulolcns;
        endif;

730cA   ieltuci =  uiuci;
730cA   ieltuciseq = 0;
730cA   ieltgtin = %CHAR(uiagtin);
730cA   ieltserial = uiserial;

        exsr GetLICINFO;
        ieltpo = lnpo;
        ieltposeq = lnposeq;
        ieltbrd = lnbrand;

        // The $bc fields were extracted from the UCI barcode value

730cA   if $bcLotSent;
730cA     ieltlot = $bclot;
730cA   endif;

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

        // Setting the Host Lot follows logic from PO726

730aA   select;

760aA     when clienthost = freshbyte;
760aA       ielthstlot = lnlot;

730aA     when uiserial <> ' ';
730cA       ielthstlot= uiserial;

730aA     when uialot <> ' ';
730cA       ielthstlot= uialot;

730aA     when %subst(uiuci:1:3) = '99I';
730cA       ielthstlot= uiuci;

730aA     other;
730cA       ielthstlot = uiaolcns;

730aA   endsl;

          // Fill in fields for Aspen EXPSADJF file

          if clienthost = Aspen;
            ieuci = ieltuci;
            ieuciseq# = ieltuciseq;
            ieucigtin = ieltgtin;
            ieucilot = ielthstlot;
            ieuciser# = ieltserial;
            ienotes = ieltmemo;
          endif;

          // Write single EXPSADJLT/F rec when not splitting qty types

          if not splitQtyTypes;
            ieltqty1 = llaqty1;
            ieltqty2 = llaqty2;
            ieltqty3 = llaqty3;
            ieltwgt  = iacwta;
            write ieltrec;
            if clienthost = Aspen;
              ieqty1 = ieltqty1;
              ieqty2 = ieltqty2;
              ieqty3 = ieltqty3;
              iecwta = ieltwgt;
              write iefrec;
            endif;
          endif;

          // Write multiple EXPSADJLT/F recs when splitting qty types
          // Entire wgt will be applied to first qty type written

          if splitQtyTypes and llaqty1 <> 0;
            ieltqty1 = iaqty1;
            ieltqty2 = 0;
            ieltqty3 = 0;
            ieltwgt  = iacwta;
            write ieltrec;
            if clienthost = Aspen;
              ieqty1 = ieltqty1;
              ieqty2 = ieltqty2;
              ieqty3 = ieltqty3;
              iecwta = ieltwgt;
              write iefrec;
            endif;
          endif;

          if splitQtyTypes and llaqty2 <> 0;
            ieltqty1 = 0;
            ieltqty2 = llaqty2;
            ieltqty3 = 0;
            if llaqty1 = 0;
              ieltwgt = iacwta;
            endif;
            write ieltrec;
            if clienthost = Aspen;
              ieqty1 = ieltqty1;
              ieqty2 = ieltqty2;
              ieqty3 = ieltqty3;
              iecwta = ieltwgt;
              write iefrec;
            endif;
          endif;

          if splitQtyTypes and llaqty3 <> 0;
            ieltqty1 = 0;
            ieltqty2 = 0;
            ieltqty3 = llaqty3;
            if llaqty1 = 0 and llaqty2 = 0;
              ieltwgt = iacwta;
            endif;
            write ieltrec;
            if clienthost = Aspen;
              ieqty1 = ieltqty1;
              ieqty2 = ieltqty2;
              ieqty3 = ieltqty3;
              iecwta = ieltwgt;
              write iefrec;
            endif;
          endif;

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
740cA    or clienthost = NetSuite
760cA    or clienthost = freshbyte)
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
