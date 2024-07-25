650aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT726     Export item adjustments - Post
     *  07 November, 1994
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *  This program should be identical to IT725 except that it uses
     *  the EXPF files that are overridden in IT726CL.
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
650aA*    04/10/10  RTR  650a
     *      - Enh: Added call to create license records
650bA*    02/03/15  MLB  6.50b
     *      - Fix: Added 3 missing parms: IABY, IAWHDP and IADISP to
     *        6.50a mod.
700a *    08/25/15  RTR  700a
     *      - Enh: Added check and call to send returns as adjustments.
730a *    03/11/19  LMC  7.30a
     *      - Added writing UCI data to EXPFADJL for UCI tracked item.
740aA*    03/09/20  LMC  7.40a
     *      - Revised GetClient to get parms 3 (client initials)
     *        and 4 (Host Sytem Id).
     *      - Added /copy to get Host System Id's
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Aspen Clients
     *
ASPaA*    03/09/20  LMC  ASPa
     *      - Revised to append '-ww' to item numbers, where ww is
     *        the 2-digit warehouse
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's Provision
     *
PAK A*    07/07/06  MLB  PAK
     *      - Revised program to write export data to file SAPEXP
     *        instead of standard expfxxxx files.
     *      - Files added to program: PIRITEM, ITEMEXT1, SAPMOVE1,
     *        SAPEXP.
PAKaA*    09/19/06  MLB  PAKa
     *      - Revised above mod, PAK to make changes per Packer's/
     *        SAP requests for data being exported.
PAKbA*    09/25/06  MLB  PAKb
     *      - Revised program to add file UCIADJ1 to write out UCI
     *        records with export data.
PAKcA*    09/28/06  MLB  PAKc
     *      - Revised program to update field MAND with 220 instead
     *        of 210.
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
     *  Client Custom Revisions: Greenleaf
     *
GLPaA*    04/24/13  RTR  GLPa
     *      - Added check for breakdown qtys on repacks to write additional
     *        export record for breakdown item.
GLPbA*    02/09/15  MLB  GLPb
     *      - Revised pgm to make 6.50a a client-specific mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Chefs Warehouse - Canopy
     *
DRYaA*    03/13/19  LMC  DRYa
     *      - Added Canopy whse to the call of IT780 to create        ional
     *        adjustment license record if this is not a UCI tracked
     *        item. UCI tracked items have their own process to add
     *        records to the expfadjl file.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for ITEMADJ
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fitemadj   up   e           k disk
416 AFadjmisc   if   e           k disk
PAK AFpiritem   if   e           k disk
PAK AFitemext1  if   e           k disk    usropn
PAK AFsapmove1  if   e           k disk    usropn
GLPaAFkitcomp1  if   e           k disk    usropn
PAK AFsapexp    uf a e           k disk    usropn
PAKbAFuciadj1   uf   e           k disk    usropn
     Fexpfadj   o  a e           k disk
730aAFexpfadjl  o  a e           k disk
730aAfitemmsc   if   e           k disk
730aAflabel91   if   e           k disk
730aA*----------------------------------------------------------------
730aA*  File field data structure.
730aA*----------------------------------------------------------------
730aA
730aAD uirec         e ds                  extname(UCIINFO) inz(*EXTDFT)
730aAD uiarec        e ds                  extname(UCIINFOEXA) inz(*EXTDFT)
730aAD ulrec         e ds                  extname(ucilog) inz(*EXTDFT)
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
PAK A /COPY QCOPYSRC,ID#packers
SVLaA /COPY QCOPYSRC,ID#saval
HALaA /COPY QCOPYSRC,ID#halsey
GLPaA /COPY QCOPYSRC,ID#glp
DRYaA /COPY QCOPYSRC,ID#dairyla
740aA /copy qcopysrc,hostsystem
510 A*
PAK A*----------------------------------------------------------------
PAK A*  SAP Export File data structures
PAK A*
PAK A /copy qcopysrc,s#edidc40
PAK A /copy qcopysrc,s#e1mbxyh
PAK A /copy qcopysrc,s#e1mbxyi
PAK A*
640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

510aA*----------------------------------------------------------------
510aA*  Working variables
510aA*
PAK AD adjtype         s              1
PAK AD expdate         s              8  0
PAK AD exptime         s              6  0
GLPaAD kititem         s               n
GLPaAD xxitem          s             15a
PAKbAD loopcount       s              7  0
700aAD pWhse           s              3p 0
700aAD pWhse3A         s              3
PAKbAD sapcntrl        s              4    inz('*NO ')
PAKbAD sapcount        s              7  0
510aAD today           s              8  0
510aAD updhst          s              1
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
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
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
     *  Add item adjustments to export file.
     *
416 AC                   if        updhst = *on  and
500 AC                             iaitem > *blanks
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAK A*
PAK A*  Populate SAP Control Record and write to export file.
PAKbMC                   if        sapcntrl = '*NO '
PAK AC                   exsr      sapcontrol
PAK AC                   exsr      sapwrite
PAKbMC                   eval      sapcntrl = '*YES'
PAK AC                   endif
PAKbA*
PAK A*      Get SAP Movement code.
PAK AC                   exsr      zzgetsm
PAK A*      Create SAP Goods Movement Hdr Rcd format for export file.
PAK AC                   exsr      sapheader
PAK A*      Write SAP Goods Movement Hdr Rcd format to export file.
PAK AC                   exsr      sapwrite
PAKbA*
PAKbAC     keyuaadj1     setll     uciadj1
PAKaA*
PAK A*      Get BFC Item Master record.
PAK AC                   exsr      zzgetit
PAK A*      Get BFC Item Master Extension record.
PAK AC                   exsr      zzgetiext
PAKbA*
PAKbA*      Is item a catchweighted item?
PAKbAC                   if        itcwgt = 'Y'
PAKbAC                   select
PAKbA*      Need to loop for as many as were adjusted.
PAKbAC                   when      iaqty3 <> 0
PAKbAC                   eval      loopcount = iaqty3
PAKbA*
PAKbAC                   when      iaqty2 <> 0
PAKbAC                   eval      loopcount = iaqty2
PAKbA*
PAKbAC                   when      iaqty1 <> 0
PAKbAC                   eval      loopcount = iaqty1
PAKbA*
PAKbAC                   endsl
PAKbA*
PAKbAC                   else
PAKbA*      Item a non-catchweighted item.
PAKbAC                   eval      loopcount = 1
PAKbAC                   endif
PAKbA*
PAKbA*      We must loop at least once for every line item.
PAKbAC                   select
PAKbAC                   when      loopcount = 0
PAKbAC                   eval      loopcount = 1
PAKbA*
PAKbAC                   when      loopcount < 0
PAKbAC                   eval      loopcount = loopcount * -1
PAKbAC                   endsl
PAKbA*
PAKbA*      Create SAP Detail Rcd format for export file.
PAKbAC                   eval      sapcount = 0
PAKbAC                   dow       sapcount < loopcount
PAKbAC                             and loopcount > 0
PAKbA*
PAKbA*      Is item a catchweighted item?
PAKbAC                   if        itcwgt = 'Y'
PAKbAC     keyuaadj1     reade     uciadj1
PAKbAC                   if        %eof(uciadj1)
PAKbAC                   eval      uainbr = ' '
PAKbAC                   eval      uanwgt = 0
PAKbAC                   else
PAKbAC                   eval      uaedat = expdate
PAKbAC                   eval      uaetim = exptime
PAKbAC                   update    uacrec
PAKbAC                   endif
PAKbAC                   endif
PAKbA*
PAKbAC                   eval      sapcount = sapcount + 1
PAK A*
PAK A*      Create SAP Goods Movement Detail Rcd format for export file.
PAKbAC                   select
PAK AC                   when      iaqty1 <> 0
PAK AC                   eval      adjtype= '1'
PAK AC                   exsr      sapdetail
PAK A*      Write SAP Goods Movement Detail Rcd format to export file.
PAK AC                   exsr      sapwrite
PAK A*
PAK AC                   when      iaqty2 <> 0
PAK AC                   eval      adjtype= '2'
PAK AC                   exsr      sapdetail
PAK A*      Write SAP Goods Movement Detail Rcd format to export file.
PAK AC                   exsr      sapwrite
PAK A*
PAK AC                   when      iaqty3 <> 0
PAK AC                   eval      adjtype= '3'
PAK AC                   exsr      sapdetail
PAK A*      Write SAP Goods Movement Detail Rcd format to export file.
PAK AC                   exsr      sapwrite
PAK AC                   endsl
PAKbA*
PAKbAC                   enddo
PAK A*
PAK AC                   other
PAK A*
     C                   exsr      filie
     C                   write     ierec                                79
730aA /free
730aA   // is this Item UCI tracked?
730aA   chain (iawhse:iaitem) itemmsc;
730aA   if not %found(itemmsc);
730aA     clear imrec;
730aA   endif;
730aA   if imltrk = 'U';
730aA     exsr filiel;
730aA     write ielrec;
730aA   endif;
730aA /end-free
GLPaA*
GLPaA*  For Greenleaf, check for breakdown qtys
GLPaAC                   if        client = greenleaf
GLPaAC                             and iaqty2 <> 0
GLPaA*
GLPaA*  Find if kit item exists at breakdown level 1
GLPaAC                   exsr      zzchkkit
GLPaA*
GLPaAC                   if        kititem
GLPaAC                   eval      ieitem = kcitem
GLPaAC                   eval      ieqty1 = iaqty2
GLPaAC                   eval      ieqty2 = 0
GLPaAC                   write     ierec                                79
GLPaAC                   endif
GLPaA*
GLPaAC                   endif
650aA*
650aA*  Create license records for adjustment
GLPbAC                   if        client = Greenleaf
ASPaMc                             or hostSys = Aspen
ASPaDc*                            or client = Dairyland
ASPaDc*                            and clientloc = DM01
DRYaAc                             and imltrk <> 'U'
650aAC                   call      'IT780'
650aAC                   parm                    iawhse
650aAC                   parm                    iaitem
650aAC                   parm                    iadate
650aAC                   parm                    iatime
650bAC                   parm                    iaby
650bAC                   parm                    iawhdp
650bAC                   parm                    iadisp
650aAC                   parm                    iaqty1
650aAC                   parm                    iaqty2
650aAC                   parm                    iaqty3
GLPbAC                   endif
     *
PAK AC                   endsl
PAK A*
416 AC                   endif
     *
     *  Update item adjustment file with upload date and time.
     *
     C                   eval      iaudte = today
     C                   time                    iautim
     C                   update    iarec
700aA /free
700aA   // Check to see if returns need to be sent.
700aA   // Get options record for returns.
700aA   exec sql select opdata into :oprdata from options
700aA             where opwhse = :iawhse
700aA               and opcode = '*RETURNS';
700aA   if sqlstt <> sqlSuccess;
700aA     clear oprdata;
700aA   endif;
700aA   pwhse3a = %char(iawhse);
700aA /end-free
700aAC                   if        opread = 'Y'
700aAC                   call      'OR737'
700aAC                   parm                    pWhse3a
700aAC                   endif
     *
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
740aAC                   parm                    hostSys          10
510 A*
PAK A*   Define full key for PIRITEM file.
PAK A*
PAK AC     keyit         klist
PAK AC                   kfld                    iawhse
PAK AC                   kfld                    iaitem
GLPaA*
GLPaA*   Define partial key for KITCOMP1 file.
GLPaA*
GLPaAC     keykit        klist
GLPaAC                   kfld                    iawhse
GLPaAC                   kfld                    iaitem
PAKbA*
PAKbA*   Define partial key for UCIADJ1 file.
PAKbA*
PAKbAC     *like         define    uaedat        kyuaedat
PAKbAC     *like         define    uaetim        kyuaetim
PAKbAC     keyuaadj1     klist
PAKbAC                   kfld                    iawhse
PAKbAC                   kfld                    iaitem
PAKbAC                   kfld                    iadate
PAKbAC                   kfld                    iatime
PAKbAC                   kfld                    iacode
PAKbAC                   kfld                    kyuaedat
PAKbAC                   kfld                    kyuaetim
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
PAK A*
PAK A* Open EXPSAP Export File for Packer's.
PAK AC                   eval      expdate = today
PAK AC                   time                    exptime
PAK A*
PAK AC                   if        client = packers
PAK AC                   if        not %open(sapexp)
PAK AC                   open      sapexp
PAK AC                   endif
PAK A*
PAK AC                   if        not %open(sapmove1)
PAK AC                   open      sapmove1
PAK AC                   endif
PAK A*
PAK AC                   if        not %open(itemext1)
PAK AC                   open      itemext1
PAK AC                   endif
PAKbA*
PAKbA* Open UCIADJ1 UCI Adjustment file for Packer's.
PAKbAC                   if        not %open(uciadj1)
PAKbAC                   open      uciadj1
PAKbAC                   endif
PAK A*
PAK AC                   endif
GLPaA*
GLPaA* Open KITCOMP1 file for Greenleaf.
GLPaAC                   if        client = greenleaf
GLPaAC                             and not %open(kitcomp1)
GLPaAC                   open      kitcomp1
GLPaAC                   endif
     *
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
     C                   eval      iecode = iacode
     C                   eval      iememo = iamemo
     *
     C                   endsr
730aA*----------------------------------------------------------------
730aA*
730aA*  FILIEL   Fill export fields - lot(uci tracking)
730aA*
730aAC     filiel        begsr
730aA*
730aA*  Initialize record
730aA*
730aAC                   clear                   ielrec
730aA*
730aA*  Move fields from item adjustment file to export file.
730aA*
730aAC                   eval      ielwhse = iawhse
730aAC                   eval      ielitem = iaitem
730aAC                   eval      ieldate = iadate
730aAC                   eval      ieltime = iatime
730aAC                   eval      ielby = iaby
730aAC                   eval      ielwhdp = iawhdp
730aAC                   eval      ieldisp = iadisp
730aAc                   eval      ielqty1 =  %editc(iaqty1:'L')
730aAc                   eval      ielqty2 =  %editc(iaqty2:'L')
730aAc                   eval      ielqty3 =  %editc(iaqty3:'L')
730aAc** need to get the label file for the link to ucilog
730aA /free
730aA   chain (iawhse: iaitem: iadate: iatime) label91;
730aA   if %found(label91);
730aA     // now I need the ucilog record
730aA     exec sql select * into :ulrec from ucilog
730aA               where ulwhse = :iawhse
730aA                 and ullbl# = :lblbl#;
730aA     if sqlstt = sqlSuccess;
730aA       exec sql select * into :uirec from uciinfo
730aA                 where uiwhse = :ulwhse
730aA                   and uiuci = :uluci;
730aA       if sqlstt = sqlSuccess;
730aA         exec sql select * into :uiarec from uciinfoexa
730aA                   where uiaaddts = :uiaddts
730aA                     and uiaucilcns = :uiucilcns
730aA                     and uialcns = :uilcns;
730aA         if sqlstt = sqlSuccess;
730aA           // finally now I can write the IELLCNS field
730aA           // I'm using the same logic we use in PO726 to
730aA           // hierachy of the data for the IELLCNS field
730aA           select;
730aA             when uiserial <> ' ';
730aA               iellcns = uiserial;
730aA             when uialot <> ' ';
730aA               iellcns = uialot;
730aA             when %subst(uiuci:1:3) = '99I';
730aA               iellcns = uiuci;
730aA             other;
730aA               iellcns = ullcns;
730aA               ielolcns = uiaolcns;
730aA           endsl;
730aA         else;
730aA           clear uiarec;
730aA         endif;
730aA       else;
730aA         clear uirec;
730aA       endif;
730aA     endif;
730aA   else;
730aA     clear lbrec;
730aA   endif;
730aA /end-free
730aa
730aA*
730aAC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPCONTROL    Populate SAP Control Record and add to export file.
PAK A*
PAK AC     sapcontrol    begsr
PAK A*
PAK AC                   reset                   s#edi_dc40
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAKcDC*                  eval      sap_mand    = '210'
PAKcMC                   eval      sap_mand    = '220'
PAK AC                   endsl
PAK A*
PAK AC                   eval      sap_docnum  = %editc(expdate:'X') +
PAK AC                                           %editc(exptime:'X')
PAK A*
PAK AC                   eval      sap_idoctyp = 'WMMBID01'
PAK A*
PAK AC                   eval      sap_direct  = '2'
PAK A*
PAKaDC*                  eval      sap_rcvport = 'A000000008'
PAKaMC                   eval      sap_rcvport = 'LSMW      '
PAKaDC*                  eval      sap_rcvprn  = 'PPBFC210'
PAKaMC                   eval      sap_rcvprn  = 'DEVCLNT300'
PAK A*
PAKaDC*                  eval      sap_sndport = 'A000000008'
PAKaMC                   eval      sap_sndport = 'LSMW      '
PAKaAC                   eval      sap_sndprn  = 'DEVCLNT300'
PAK A*
PAK AC                   eval      sap_crtdate = %editc(expdate:'X')
PAK A*
PAK AC                   eval      sap_mestype = 'WMMBXY'
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata      = s#edi_dc40
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPDETAIL    Populate SAP Goods Movement Detail Record.
PAK A*
PAK AC     sapdetail     begsr
PAK A*
PAK AC                   reset                   s#e1mbxyi
PAK A*
PAK AC                   eval      sap_matnri = iaitem
PAKaDC*                  eval      sap_werksi = '??'
PAKaMC                   eval      sap_werksi = ikplnt
PAKaA*
PAKaDC*                  eval      sap_lgorti = '??'
PAKaAC                   select
PAKaAC                   when      iawhse = 200
PAKaAC                             and ikcat <> 'PEC'
PAKaAC                   eval      sap_lgorti = '2000'
PAKaA*
PAKaAC                   when      iawhse = 200
PAKaAC                             and ikcat =  'PEC'
PAKaAC                   eval      sap_lgorti = '3100'
PAKaA*
PAKaAC                   when      iawhse = 300
PAKaAC                   eval      sap_lgorti = '3000'
PAKaA*
PAKaAC                   endsl
PAKaA*
PAKaAC                   if        itcwgt = 'Y'
PAKaA*  Note: When UCI support is added, change line below to = ucinbr.
PAKaMC                   eval      sap_chargi = ' '
PAKaAC                   endif
PAKaA*
PAK AC                   eval      sap_bwarti = smmove
PAK AC                   eval      sap_sobkzi = smindc
PAK A*
PAK AC                   select
PAK A*      Item adjustment for eaches.
PAK AC                   when      adjtype = '2'
PAK AC                   evalr     sap_erfmgi = %trimr(%editc(iaqty2:'4'))
PAK AC                   eval      sap_erfmei = 'EA'
PAK A*
PAK A*      Item adjustment for eaches.
PAK AC                   when      adjtype = '3'
PAK AC                   evalr     sap_erfmgi = %trimr(%editc(iaqty3:'4'))
PAK AC                   eval      sap_erfmei = 'EA'
PAK A*
PAK AC                   other
PAK A*
PAK A*      Item adjustment for cases.
PAK AC                   evalr     sap_erfmgi = %trimr(%editc(iaqty1:'4'))
PAK AC                   eval      sap_erfmei = 'CV'
PAK A*
PAK AC                   endsl
PAK A*
PAK A*      Item is catchweight item, replace Unit of Entry.
PAK AC                   if        itcwgt = 'Y'
PAK AC                   eval      sap_erfmei = 'LB'
PAK AC                   endif
PAKaA*
PAKaAC                   eval      sap_kostli = %trimr(%editc(smcost:'4'))
PAK A*
PAKaMC                   eval      sap_umlgoi = '  '
PAK A*
PAK AC                   if        iawhse = 200
PAK A*
PAK AC                   if        ikgrp  = '100'
PAKaDC*                  eval      sap_lgnumi = '310'
PAK AC                   else
PAKaDC*                  eval      sap_lgnumi = ikgrp
PAK AC                   endif
PAK A*
PAK AC                   else
PAKaDC*                  eval      sap_lgnumi = %trimr(%editc(iawhse:'4'))
PAK AC                   endif
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata      = s#e1mbxyi
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPHEADER    Populate SAP Goods Movement Header Record.
PAK A*
PAK AC     sapheader     begsr
PAK A*
PAK AC                   reset                   s#e1mbxyh
PAK A*
PAK AC                   eval      sap_budat = %editc(exptime:'X')
PAKaDC*                  eval      sap_usnam = iaby
PAKaMC                   eval      sap_usnam = 'BATCHSAPBFC'
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata    = s#e1mbxyh
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPWRITE   Write record to SAP Export file.
PAK A*
PAK AC     sapwrite      begsr
PAK A*
PAK AC                   write     sapxrec
PAK AC                   if        %error
PAK AC                   endif
PAK A*
PAK AC                   endsr
GLPaA*
GLPaA*----------------------------------------------------------------
GLPaA*
GLPaA*  ZZCHKKIT   Check for Kit item at breakdown 1
GLPaA*
GLPaAC     zzchkkit      begsr
GLPaA*
GLPaAC                   eval      kititem = *off
GLPaAC     keykit        setll     kitcomp1
GLPaAC                   read      kitcomp1
GLPaA*
GLPaAC                   dow       not %eof()
GLPaAC                             and kccitm = iaitem
GLPaAC                   if        kcqty2 = 1
GLPaAC                   eval      kititem = *on
GLPaAC                   leave
GLPaAC                   endif
GLPaAC                   read      kitcomp1
GLPaAC                   enddo
GLPaA*
GLPaAC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  ZZGETIT    Get Item Master file.
PAK A*
PAK AC     zzgetit       begsr
PAK A*
PAK AC     keyit         chain     piritem
PAK AC                   if        not %found(piritem)
PAK AC                   eval      itum1  = '  '
PAK AC                   eval      itumq2 = 0
PAK AC                   eval      itum2  = '  '
PAK AC                   eval      itflg1 = 'N'
PAK AC                   eval      itumq3 = 0
PAK AC                   eval      itflg2 = 'N'
PAK AC                   eval      itcwgt = 'N'
PAK AC                   eval      itswgt = 0
PAK AC                   endif
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  ZZGETIEXT   Get Item Master Extension file
PAK A*
PAK AC     zzgetiext     begsr
PAK A*
PAK AC     keyit         chain     itemext1
PAK AC                   if        not %found(itemext1)
PAK AC                   eval      ikgrp  = ' '
PAKaAC                   eval      ikplnt = ' '
PAKaAC                   eval      ikcat  = ' '
PAK AC                   eval      ikvar  = 0
PAK AC                   endif
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  ZZGETSM   Get SAP Item Movement code
PAK A*
PAK AC     zzgetsm       begsr
PAK A*
PAK AC     iacode        chain     sapmove1
PAK AC                   if        not %found(sapmove1)
PAK AC                   eval      smsapc = ' '
PAK AC                   eval      smmove = ' '
PAK AC                   eval      smindc = ' '
PAKaAC                   eval      smcost = 0
PAKaAC                   eval      smprft = 0
PAK AC                   endif
PAK A*
PAK AC                   endsr
