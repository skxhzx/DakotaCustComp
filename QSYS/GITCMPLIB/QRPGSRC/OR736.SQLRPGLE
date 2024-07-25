     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR736     Export FTP customer returns - Post
     *  09 September, 1999
     *  Dave Sommerville
     *
     *  This program should be identical to OR735 except that it uses
     *  the EXPF files that are overridden in OR736CL.
     *
     *----------------------------------------------------------------
     *  Revisions
412 A*  09/16/99  DAS 4.12
     *   - Created
     *
416 A*    10/16/01  MLB  4.16
    A*      - Field added to ORRTN. Re-compile only.
416aA*    Ver 4.16a 11/07/01  RH
     *      - Added fields ORDCOD, ORIINV, OROLB#, ORINV#
     *
510 A*    10/05/06  MLB  5.10
     *      - Enh: Converted program to ILE.
     *      - Added client custom code support.
     *
650aA*    04/22/13  RTR  6.50a
     *      - Fix: Trim ORINV# to remove leading blanks. Base change per Max
     *
     *----------------------------------------------------------------
     *  Revisions
     *
PAK A*  10/05/06  MLB  PAK
     *      - Revised program to write export data to file SAPEXP
     *        instead of standard expfxxxx file.
-----*--- Mods Added Below Use Client PACKERS730 ---------------------
PAKa *    12/03/06  HNK  PAKa
     *      - idoc type and message type set to correct value.
PAKb *    01/11/07  HNK  PAKb
     *      - Change Unit of measure from CV to CS. Ref: Today's email
PAKc *    02/06/07  MLB  PAKc
     *      - Revised program to write out new SAP segments: E1RTNH and
     *        E1RTND. These will replace the original design segments.
     *      - Added files: SAPRCOD, LABEL93, ORDH5 ORDHM3 to pgm.
PAKd *    02/17/07  JCJ  PAKd
     *      - Revised program to retrieve Billing Document number from
     *        file ORRTNM and put in field sap_refdoc in SR SAPHEADER.
PAKe *    08/27/07  MLB  PAKe ** Remove when live with SAP **
     *      - Revised program to retrieve SAP Sales Organization from
     *        ORRTNM. Load vkorg into sap_vkorg in SAPEXP file.
     *        * Temporary Mod * Use copy from SAP library instead.
     *      - Revised program to UCI weight into quantity returned
     *        field. Assume 2 decimal positions for weight.
PAKf *    09/19/07  MLB  PAKf ** Remove when live with SAP **
     *      - Revised program to retrieve SAP Reference Doc from
     *        ORRTN / ORINV#.
PAKg *    09/27/07  MLB  PAKg
     *      - Fix: Revised program to load order number from returns
     *        record into HMORD when processing warehouse 1.
     *        File ORDHM is not used w/ Packer's Alpha system.
     *      - Add ORDH5 to program to retrieve Dakota internal order#.
PAKh *    04/27/09  MLB  PAKh
     *      - Fix: Revised program to receive Host Type code from Host
     *        FTP process. Host Type code will control which Branch
     *        return records are exported. 2000=Packers, 2100=LeGrand
     *        and 2200=VSuarez.
PAKi *    05/20/10  MLB  PAKi
     *      - Fix: Revised program to move retrieve of Returns Misc.
     *        file ahead of the Customer Order Header and Label file
     *        retrieval.  Program was not finding correct order for
     *        Vsuarez orders due to duplicate order numbers in ORDH.
     *        Customer Order ID now being stored in ORRTNM in positions
     *        24-30 so that correct order header can be retrieved.
     *        If order id in ORRTNM file is blank, then customer order
     *        only will be used to retrieve the order header rcd.
PAKjA*    05/20/10  MLB  PAKi
     *      - Fix: Revised program to change how ORINV# is loaded into
     *        sap_refdoc field. sap_refdoc field will always have 3
     *        leading blanks and then the host order number starting
     *        in position 4. Will-call orders were not processing
     *        correctly on GP because 7 digit order numbers didn't
     *        start in the correct place.
     *      - Mod includes chg to PIRCSTM/QCOPYSRC_s#e1rtnh.
PAKkA*    08/10/20  MLB  PAKk
     *      - Enh: Revised program to add new field, SAP_RTNWGT at end
     *        of SAP detail rcd format. Needed since interface will send
     *        return qty in the return qty field and for c/wgt returned
     *        in new SAP_RTNWGT fld.
PAKlA*    10/07/20  MLB  PAKl
     *      - Enh: Revised program to add 2 new field, BFC_RTNCODE and
     *        BFC_DSPCODE. Per Ed email dated 10.06.2020.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*  07/20/11  MLB  CSP  P#01045
     *    - Revised program to append Brkdwn 1 or Brkdwn 2 UoM
     *      to end of item number to aid in posting on Host.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Grave's Menu Maker
     *
GMM A*  08/27/12  RTR  GMM  P#01045
     *    - Return customer order number from ORRTN when route is
     *      status 6.
     *
GMMaA*  06/03/20  RBD  GMMa
     *    - Disable GMM code where it was writing customer number
     *      into the order field in orrtn.  I discussed with Rod and
     *      he doesn't recall why he wrote that code, but both Rod and
     *      Forrest concur it should be disabled.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocer
     *
SGC A*  02/11/15  MLB  SGC
     *    - Added code to reverse 6.50a mod. Leave ORINV# value right
     *      justified.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for ORRTN
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Forrtn     up   e           k disk
PAKcAFlabel93   if   e           k disk    usropn
PAKcAFordh      if   e           k disk    usropn
PAKgAFordh5     if   e           k disk    usropn
PAKgAF                                     rename(ohrec:ohrec5)
PAKcAFordhm3    if   e           k disk    usropn
PAK AFpiritem   if   e           k disk
PAK AFitemext1  if   e           k disk    usropn
PAKcDF*sapmove1  if   e           k disk    usropn
PAKcAFsaprcod   if   e           k disk    usropn
PAK AFsapexp    uf a e           k disk    usropn
PAK AF*uciadjx   uf   e           k disk    usropn
PAKdAForrtnm    if   e           k disk    usropn
     Fexpfrtn   o  a e           k disk
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
PAK A /COPY QCOPYSRC,ID#packers
CSP A /COPY QCOPYSRC,ID#coastal
GMM A /COPY QCOPYSRC,ID#gmm
SGC A /COPY QCOPYSRC,ID#sgc
510 A*
PAKcA*----------------------------------------------------------------
PAKcA*  SAP Header Misc. File data structures
PAKcA*
PAKcA /copy qcopysrc,ordhm1_pak
PAKcA /copy qcopysrc,ordhm2_pak
PAKcA /copy qcopysrc,ordhm3_pak
PAKcA /copy qcopysrc,ordhm4_pak
PAKcA /copy qcopysrc,ordhm5_pak
PAKcA*
PAK A*----------------------------------------------------------------
PAK A*  SAP Export File data structures
PAK A*
PAKcD */copy qcopysrc,s#edidc40
PAKcD */copy qcopysrc,s#e1edk01
PAKcD */copy qcopysrc,s#e1edk02
PAKcD */copy qcopysrc,s#e1edp01
PAKcA /copy qcopysrc,s#e1rtnh
PAKcA /copy qcopysrc,s#e1rtnd
PCKdA *
PCKdA *----------------------------------------------------------------
PCKdA *  SAP Returns Misc field File data structures
PCKdA *
PCKdA /copy qcopysrc,rmmsc1_pak
PCKdA /copy qcopysrc,rmmsc2_pak
PCKdA /copy qcopysrc,rmmsc3_pak
PCKdA /copy qcopysrc,rmmsc4_pak
PCKdA /copy qcopysrc,rmmsc5_pak
PAK A*
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
     *
     *----------------------------------------------------------------
     *  Working variables
     *
PAKcAD dftitem         s             18  0
PAKcAD dftdoc#         s             10  0
PAKcAD dftqty          s             17  0
PAK AD expdate         s              8  0
PAK AD exptime         s              6  0
PAKcAD hold_orord      s                     like(orord)
PAKcAD                                       inz(-99999)
PAKiAD kyordid         s                     like(ohord)
PAK AD loopcount       s              7  0
GMM AD newcust         s             11  0
PAK AD sapcntrl        s              4    inz('*NO ')
PAKcAD sapcustnbr      s             10  0
PAKcAD saprtnqty       s             13  3
PAKcAD saprefdoc       s             10
PAK AD sapcount        s              7  0
PAK AD sapposnbr       s              7  0
PAK AD sappsgnum       s              5  0
     D today           s              8  0
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
PAKhM*      $PHOSTTYPE  - Host Type 2000=Packers, 2100=LeGrand and
PAKhA*                    2200=VSuarez.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
PAKhAC     *entry        plist
PAKhAC                   parm                    $phosttype        4
     *
     *  Add customer returns to export file.
     *
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAKkAC                             or client = pack730
PAK A*
PAKcDC*                  if        sapcntrl = '*NO '
PAKcD*  Populate SAP Control Record and write to export file.
PAKcDC*                  exsr      sapcontrol
PAKcDC*                  exsr      sapwrite
PAKcDC*                  eval      sapcntrl = '*YES'
PAKcDC*                  endif
PAK A*
PAKcD*      Get SAP Movement code.
PAKcDC*                  exsr      zzgetsm
PAKiA*
PAKiA*      Get SAP Billing Document number
PAKiAC                   exsr      zzgetorrtnm
PAKiA*      Only send returns for specific Host Type.
PAKiAC                   if        pakrm1_vkorg <> $phosttype
PAKiAC                   goto      bottom
PAKiAC                   endif
PAKcA*
PAKcA*      Get Dakota Order Header Misc.
PAKcAC                   exsr      zzgetohm
PAKcA*
PAKcA*      Get Dakota Order Header.
PAKcAC                   exsr      zzgetoh
PAKcA*
PAKcA*      Get SAP Returns code.
PAKcAC                   exsr      zzgetsp
PAK A*
PAK A*      Create SAP Header Rcd format for export file.
PAKcAC                   if        orord <> hold_orord
PAK AC                   exsr      sapheader
PAK A*      Write SAP Header Rcd format for export file.
PAK AC                   exsr      sapwrite
PAKcAC                   eval      hold_orord = orord
PAKcAC                   endif
PAK A*
PAK A*      Create SAP Header Additional Data Rcd format for export file.
PAKcDC*                  exsr      saphdradd
PAK A*      Write SAP Header Rcd format for export file.
PAKcDC*                  exsr      sapwrite
PAK A*
PAK A*      Get BFC Item master file.
PAK AC                   exsr      zzgetit
PAK A*      Get BFC Item Master Extension record.
PAK AC                   exsr      zzgetiext
PAKcA*
PAKcA*      Get BFC Original Label record.
PAKcAC                   exsr      zzgetlbl
PAK A*
PAK A*      Item is NOT a catchweighted item.
PAKeDC*                  select
PAKeDC*                  when      itcwgt <> 'Y'
PAK A*
PAK AC                   exsr      sapdetail
PAK A*      Write SAP Detail Rcd format for export file.
PAK AC                   exsr      sapwrite
PAK A*
PAK A*      Is item a catchweighted item? Write out UCI records.
PAKeDC*                  when      itcwgt = 'Y'
PAKeD*
PAK A*      Need to loop for as many as were received.
PAKeDC*                  if        orqty2 <> 0
PAKeDC*                  eval      loopcount = orqty2
PAKeDC*                  else
PAKeDC*                  eval      loopcount = orqty1
PAKeDC*                  endif
PAK A*
PAK A*      We must loop at least once for every line item.
PAKeDC*                  if        loopcount < 0
PAKeDC*                  eval      loopcount = loopcount * -1
PAKeDC*                  endif
PAK A*
PAK A*      Create SAP Detail UCI Rcd format for export file.
PAKeDC*                  eval      sapcount = 0
PAK AC**   keyuci        setll     uciadjx
PAKeDC*                  dow       sapcount < loopcount
PAKeDC*                            and loopcount > 0
PAK A*
PAK AC**   keyuci7       reade     uciadjx
PAK AC**                 if        %eof(uciadjx)
PAK AC**                 eval      ucinbr = ' '
PAK AC**                 eval      uciwgt = 0
PAK AC*                  else
PAK AC**                 eval      ucired = expdate
PAK AC**                 eval      uciret = exptime
PAK AC**                 update    ucirec
PAK AC**                 endif
PAK A*
PAKeDC*                  exsr      sapdtluci
PAK A*      Write SAP Detail UCI Rcd format for export file.
PAKeDC*                  exsr      sapwrite
PAK A*
PAKeDC*                  eval      sapcount = sapcount + 1
PAK A*
PAKeDC*                  enddo
PAK A*
PAKeDC*                  endsl
PAK A*
PAK AC                   other
PAK A*
CSP AC                   select
CSP AC                   when      client = coastalsunbelt
CSP A*      Get BFC Item master file.
CSP AC                   exsr      zzgetit
CSP A*      Check for multiple return qty's in same return rcd.
CSP AC                   exsr      filoe_csp
GMM A*
GMM A*      For Menu Makers
GMM AC                   when      client = menumaker
GMM AC                   exsr      filoe_gmm
CSP A*
CSP AC                   other
CSP A*
     C                   exsr      filoe
     C                   write     oerec                                79
CSP AC                   endsl
CSP A*
PAK A*
PAK AC                   endsl
     *
     *  Update customer return file with upload date and time.
     *
     C                   eval      orudte = today
     C                   time                    orutim
     C                   update    orrec
     *
     C     bottom        tag
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
510 A*
510 A* Get client id.
510 A*
510 AC                   call      'GETCLIENT'
510 AC                   parm                    client           10
510 AC                   parm                    clientloc        10
PAKcA*
PAKcA*   Define partial key for LABEL93 file.
PAKcA*
PAKcAC     lb93key       klist
PAKcAC                   kfld                    orwhse
PAKcAC                   kfld                    hmord
PAKcAC                   kfld                    oritem
PAKcA*
PAKcA*   Define full key for ORDH file.
PAKcA*
PAKcAC     ohkey         klist
PAKcAC                   kfld                    orwhse
PAKcAC                   kfld                    hmord
PAKgA*
PAKgA*   Define full key for ORDH5 file.
PAKgA*
PAKgAC     oh5key        klist
PAKgAC                   kfld                    orwhse
PAKgAC                   kfld                    orord
PAKiA*
PAKiAC     oh5akey       klist
PAKiAC                   kfld                    orwhse
PAKiAC                   kfld                    orord
PAKiAC                   kfld                    kyordid
PAKcA*
PAKcA*   Define full key for ORDHM3 file.
PAKcA*
PAKcAC     *like         define    hmdelv        kydelv
PAKcAC     ohm3key       klist
PAKcAC                   kfld                    orwhse
PAKcAC                   kfld                    kydelv
510 A*
PAK A*   Define full key for PIRITEM file.
PAK A*
PAK AC     keyit         klist
PAK AC                   kfld                    orwhse
PAK AC                   kfld                    oritem
PAK A*
PAK A*   Define partial key for UCIADJx file.
PAK A*
PAK AC**   *like         define    uaedat        kyuaedat
PAK AC**   *like         define    uaetim        kyuaetim
PAK AC**   keyuaadjx     klist
PAK AC**                 kfld                    iawhse
PAK AC**                 kfld                    iaitem
PAK AC**                 kfld                    iadate
PAK AC**                 kfld                    iatime
PAK AC**                 kfld                    iacode
PAK AC**                 kfld                    kyuaedat
PAK AC**                 kfld                    kyuaetim
PAKdA*
PAKdA*   Define key for ORRTNM file.
PAKdA*
PAKdAC     orrkey        klist
PAKdAC                   kfld                    orwhse
PAKdAC                   kfld                    orord
PAKdAC                   kfld                    oritem
PAKdAC                   kfld                    orrdte
PAKdAC                   kfld                    orrtim
PAKdAC                   kfld                    orpbat
PAKdAC                   kfld                    orrcod
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
PAKcAC                             or client = pack730
PAK AC                   if        not %open(sapexp)
PAK AC                   open      sapexp
PAK AC                   endif
PAK A*
PAKcDC*                  if        not %open(sapmove1)
PAKcDC*                  open      sapmove1
PAKcDC*                  endif
PAKcA*
PAKcAC                   if        not %open(label93)
PAKcAC                   open      label93
PAKcAC                   endif
PAKcA*
PAKcAC                   if        not %open(ordh)
PAKcAC                   open      ordh
PAKcAC                   endif
PAKcA*
PAKgAC                   if        not %open(ordh5)
PAKgAC                   open      ordh5
PAKgAC                   endif
PAKgA*
PAKcAC                   if        not %open(ordhm3)
PAKcAC                   open      ordhm3
PAKcAC                   endif
PAKcA*
PAKcAC                   if        not %open(saprcod)
PAKcAC                   open      saprcod
PAKcAC                   endif
PAKdA*
PAKdAC                   if        not %open(orrtnm)
PAKdAC                   open      orrtnm
PAKdAC                   endif
PAK A*
PAK AC                   if        not %open(itemext1)
PAK AC                   open      itemext1
PAK AC                   endif
PAK A*
PAK AC                   endif
     *
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
     C                   eval      oeord = orord
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
416aAC                   eval      oedcod = ordcod
416aAC                   eval      oeiinv = oriinv
416aAC                   move      orolb#        oeolb#
416aAC**                 eval      oeinv# = orinv#
SGC A*
SGC AC                   if        client = sgc
SGC AC                   eval      oeinv# = orinv#
SGC AC                   else
SGC A*
650aMC                   eval      oeinv# = %trim(orinv#)
SGC AC                   endif
SGC A*
     C                   eval      oermem = orrmem
     *
     C                   endsr
CSP A*
CSP A*----------------------------------------------------------------
CSP A*
CSP A*  FILOE_CSP    Fill export fields.
CSP A*
CSP AC     filoe_csp     begsr
CSP A*
CSP AC                   if        orqty1 > 0
CSP A*
CSP A*  Initialize record
CSP AC                   clear                   oerec
CSP A*
CSP A*  Move fields from item adjustment file to export file.
CSP A*
CSP AC                   eval      oewhse = orwhse
CSP AC                   eval      oeord  = orord
CSP AC                   eval      oeitem = oritem
CSP AC                   eval      oeqty1 = orqty1
CSP AC                   eval      oeqty2 = 0
CSP AC                   eval      oeqty3 = 0
CSP A *
CSP AC                   eval      oecwtr = orcwtr
CSP AC                   eval      oerdte = orrdte
CSP AC                   eval      oertim = orrtim
CSP AC                   eval      oerusr = orrusr
CSP AC                   eval      oetype = ortype
CSP AC                   eval      oetrn# = ortrn#
CSP AC                   eval      oecitm = orcitm
CSP AC                   eval      oercod = orrcod
CSP AC                   eval      oedcod = ordcod
CSP AC                   eval      oeiinv = oriinv
CSP AC                   move      orolb#        oeolb#
CSP AC**                 eval      oeinv# = orinv#
650aMC                   eval      oeinv# = %trim(orinv#)
CSP AC                   eval      oermem = orrmem
CSP A*
CSP AC                   write     oerec
CSP A*
CSP AC                   endif
CSP A*
CSP AC                   if        orqty2 > 0
CSP A*
CSP A*  Initialize record
CSP AC                   clear                   oerec
CSP A*
CSP A*  Move fields from item adjustment file to export file.
CSP A*
CSP AC                   eval      oewhse = orwhse
CSP AC                   eval      oeord  = orord
CSP AC                   eval      oeitem = oritem
CSP AC                   eval      oeqty1 = orqty2
CSP AC                   eval      oeqty2 = 0
CSP AC                   eval      oeqty3 = 0
CSP A *
CSP A *      Add brkdwn 1 UoM to item#.
CSP AC                   if        itum2  > ' '
CSP AC                   eval      oeitem = %trim(oritem)
CSP AC                                      + itum2
CSP AC                   else
CSP AC                   eval      oeitem = oritem
CSP AC                   endif
CSP A *
CSP AC                   eval      oecwtr = orcwtr
CSP AC                   eval      oerdte = orrdte
CSP AC                   eval      oertim = orrtim
CSP AC                   eval      oerusr = orrusr
CSP AC                   eval      oetype = ortype
CSP AC                   eval      oetrn# = ortrn#
CSP AC                   eval      oecitm = orcitm
CSP AC                   eval      oercod = orrcod
CSP AC                   eval      oedcod = ordcod
CSP AC                   eval      oeiinv = oriinv
CSP AC                   move      orolb#        oeolb#
CSP AC**                 eval      oeinv# = orinv#
650aMC                   eval      oeinv# = %trim(orinv#)
CSP AC                   eval      oermem = orrmem
CSP A*
CSP AC                   write     oerec
CSP A*
CSP AC                   endif
CSP A*
CSP AC                   if        orqty3 > 0
CSP A*
CSP A*  Initialize record
CSP AC                   clear                   oerec
CSP A*
CSP A*  Move fields from item adjustment file to export file.
CSP A*
CSP AC                   eval      oewhse = orwhse
CSP AC                   eval      oeord  = orord
CSP AC                   eval      oeitem = oritem
CSP AC                   eval      oeqty1 = orqty3
CSP AC                   eval      oeqty2 = 0
CSP AC                   eval      oeqty3 = 0
CSP A *
CSP AC                   if        itum3  > ' '
CSP AC                   eval      oeitem = %trim(oritem)
CSP AC                                      + itum3
CSP AC                   else
CSP AC                   eval      oeitem = oritem
CSP AC                   endif
CSP A *
CSP AC                   eval      oecwtr = orcwtr
CSP AC                   eval      oerdte = orrdte
CSP AC                   eval      oertim = orrtim
CSP AC                   eval      oerusr = orrusr
CSP AC                   eval      oetype = ortype
CSP AC                   eval      oetrn# = ortrn#
CSP AC                   eval      oecitm = orcitm
CSP AC                   eval      oercod = orrcod
CSP AC                   eval      oedcod = ordcod
CSP AC                   eval      oeiinv = oriinv
CSP AC                   move      orolb#        oeolb#
CSP AC**                 eval      oeinv# = orinv#
650aMC                   eval      oeinv# = %trim(orinv#)
CSP AC                   eval      oermem = orrmem
CSP A*
CSP AC                   write     oerec
CSP A*
CSP AC                   endif
CSP A*
CSP AC                   endsr
GMM A*----------------------------------------------------------------
GMM A*
GMM A*  FILOE_GMM    Fill export fields - Menu Maker
GMM A*
GMM AC     filoe_gmm     begsr
GMM A*
GMM A*  Initialize record
GMM A*
GMM AC                   clear                   oerec
GMM A*
GMM A /free
GMM A   Exec Sql Select max(OHCUST) into :newcust
GMM A              from ORRTN, ORDH, RTEHED
GMM A             where ORORD = OHCORD
GMM A               and OHRTE = RHRTID
GMM A               and ORORD = :orord
GMM A               and RHSTAT = '6';
GMM A
GMM A  //GMMaD   if SQLCOD = 0;
GMM A  //GMMaD     ORORD = newcust;
GMM A  //GMMaD   endif;
GMM A
GMM A /end-free
GMM A*
GMM A*  Move fields from item adjustment file to export file.
GMM A*
GMM AC                   eval      oewhse = orwhse
GMM AC                   eval      oeord = orord
GMM AC                   eval      oeitem = oritem
GMM AC                   eval      oeqty1 = orqty1
GMM AC                   eval      oeqty2 = orqty2
GMM AC                   eval      oeqty3 = orqty3
GMM AC                   eval      oecwtr = orcwtr
GMM AC                   eval      oerdte = orrdte
GMM AC                   eval      oertim = orrtim
GMM AC                   eval      oerusr = orrusr
GMM AC                   eval      oetype = ortype
GMM AC                   eval      oetrn# = ortrn#
GMM AC                   eval      oecitm = orcitm
GMM AC                   eval      oercod = orrcod
GMM AC                   eval      oedcod = ordcod
GMM AC                   eval      oeiinv = oriinv
GMM AC                   move      orolb#        oeolb#
GMM AC**                 eval      oeinv# = orinv#
650aMC                   eval      oeinv# = %trim(orinv#)
GMM AC                   eval      oermem = orrmem
GMM A*
GMM AC                   write     oerec                                79
GMM A*
GMM AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPCONTROL    Populate SAP Control Record and add to export file.
PAK A*
PAK AC     sapcontrol    begsr
PAK A*
PAKcDC*                  reset                   s#edi_dc40
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAKcDC*                  eval      sap_mand    = '220'
PAK AC                   endsl
PAK A*
PAKcDC*                  eval      sap_docnum  = %editc(expdate:'X') +
PAKcDC*                                          %editc(exptime:'X')
PAK A*
PAKcDC*                  eval      sap_direct  = '2'
PAK A*
PAKcDC*                  eval      sap_idoctyp = 'DELVRY01'
PAK A*
PAKcDC*                  eval      sap_mestype = 'ZDESADV'
PAK A*
PAKcDC*                  eval      sap_sndport = 'SAPBFCPP  '
PAKcDC*                  eval      sap_sndprn  = 'DEVCLNT220'
PAK A*
PAKcDC*                  eval      sap_rcvport = 'SAPDEV    '
PAKcDC*                  eval      sap_rcvprn  = 'DEVCLNT220'
PAK A*
PAKcDC*                  eval      sap_crtdate = %editc(expdate:'X')
PAK A*
PAK A*      Load record format into export file field.
PAKcDC*                  eval      spdata      = s#edi_dc40
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPDETAIL    Populate SAP Detail Record.
PAK A*
PAK AC     sapdetail     begsr
PAK A*
PAKeDC*                  reset                   s#e1edp01
PAKeMC                   reset                   s#e1rtnd
PAK A*
PAKeDC*                  eval      sap_P01mand   = sap_mand
PAKeDC*                  eval      sappsgnum     = sappsgnum + 1
PAKeDC*                  eval      sap_P01psgnum = %editc(sappsgnum:'3')
PAK A*
PAKeDC*                  evalr     sap_posex = '0'
PAKeDC*                  evalr     sap_P01kzabs = ' '
PAK A*
PAK AC                   evalr     sap_itemnbr = '0'
PAK AC                                           + %editc(lbseq:'X')
PAK AC                   evalr     sap_matnr   = %editc(dftitem:'X')
PAK AC                                           + %trimr(oritem)
PAK A*
PAK A*      Customer received eaches.
PAK AC                   if        orqty2 <> 0
PAKeDC*                  evalr     sap_menge = %trimr(%editc(orqty2:'3'))
PAKcAC                   evalr     sap_rtnqty= %editc(dftqty:'X')
PAKcAC                                         + %trimr(%editc(orqty2:'X'))
PAKeDC*                  eval      sap_menee = 'EA'
PAKcAC                   eval      sap_uom   = 'EA'
PAK AC                   else
PAK A*      Customer received cases.
PAKeDC*                  evalr     sap_menge = %trimr(%editc(orqty1:'3'))
PAKcAC                   evalr     sap_rtnqty= %editc(dftqty:'X')
PAKcAC                                         + %trimr(%editc(orqty1:'X'))
PAKeDC*                  eval      sap_menee = 'CV'
PAKcAC                   eval      sap_uom   = 'CV'
PAK AC                   endif
PAK A*
PAKcAC                   z-add     ohcust        sapcustnbr
PAKcAC                   evalr     sap_partnbr = %trimr(%editc(sapcustnbr:'X'))
PAKcAC                   evalr     sap_charg   = ' '
PAKcAC                   eval      sap_rtncode = spsapc
PAKeDC*                  evalr     sap_ntgew = ' '
PAKeDC*                  evalr     sap_gewei = ' '
PAK A*
PAKeDC*                  evalr     sap_abgru = ' '
PAK A*
PAKeDC*                  evalr     sap_bgrew = ' '
PAK A*
PAKeDC*                  eval      sap_werks = ikplnt
PAK A*
PAKeDC*                  eval      sap_route = ' '
PAK A*
PAKeDC*                  select
PAKeDC*                  when      orwhse = 200
PAKeDC*                            and ikcat <> 'PEC'
PAKedC*                  eval      sap_lgort = '2000'
PAK A*
PAKeDC*                  when      orwhse = 200
PAKeDC*                            and ikcat =  'PEC'
PAKeDC*                  eval      sap_lgort = '3100'
PAK A*
PAKeDC*                  when      orwhse = 300
PAKeDC*                  eval      sap_lgort = '3000'
PAK A*
PAKeDC*                  endsl
PAK A*
PAKeDC*                  eval      sap_matnr = ' ' + oritem
PAK A*
PAKkAC                   if        itcwgt = 'Y'
PAKkAC                   evalr     sap_rtnwgt= %editc(orcwtr:'X')
PAKkAC                   else
PAKkAC                   evalr     sap_rtnwgt= %editc(dftqty:'X')
PAKkAC
PAKkAC                   endif
PAKlA*
PAKlAC                   eval      bfc_rtncode = orrcod
PAKlAC                   eval      bfc_dspcode = ordcod
PAK A*
PAK A*      Load record format into export file field.
PAKeDC*                  eval      spdata      = s#e1edp01
PAKcAC                   eval      spdata      = s#e1rtnd
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPDTLUCI    Populate SAP Detail UCI Record.
PAK A*
PAK AC     sapdtluci     begsr
PAK A*
PAKeDC*                  reset                   s#e1edp01
PAK A*
PAKeDC*                  eval      sap_P01mand   = sap_mand
PAKeDC*                  eval      sappsgnum     = sappsgnum + 1
PAKeDC*                  eval      sap_P01psgnum = %editc(sappsgnum:'3')
PAK A*
PAKeDC*                  evalr     sap_posex    = '0'
PAKeDC*                  evalr     sap_P01kzabs = ' '
PAK A*
PAK A*      Customer received eaches.
PAKeDC*                  if        orqty2 <> 0
PAKeDC*                  evalr     sap_menge = %trimr(%editc(orqty2:'3'))
PAKeDC*                  eval      sap_menee = 'EA'
PAKeDC*                  else
PAK A*      Customer received cases.
PAKeDC*                  evalr     sap_menge = %trimr(%editc(orqty1:'3'))
PAKeDC*                  eval      sap_menee = 'CV'
PAKeDC*                  endif
PAK A*
PAKeDC*                  evalr     sap_ntgew = ' '
PAKeDC*                  evalr     sap_gewei = ' '
PAKeD*
PAKeDC*                  evalr     sap_abgru = ' '
PAKeD*
PAKeDC*                  evalr     sap_bgrew = ' '
PAK A*
PAKeDC*                  eval      sap_werks = ikplnt
PAK A*
PAKeDC*                  eval      sap_route = ' '
PAK A*
PAKeDC*                  select
PAKeDC*                  when      orwhse = 200
PAKeDC*                            and ikcat <> 'PEC'
PAKeDC*                  eval      sap_lgort = '2000'
PAK A*
PAKeDC*                  when      orwhse = 200
PAKeDC*                            and ikcat =  'PEC'
PAKeDC*                  eval      sap_lgort = '3100'
PAK A*
PAKeDC*                  when      orwhse = 300
PAKeDC*                  eval      sap_lgort = '3000'
PAK A*
PAKeDC*                  endsl
PAK A*
PAKeDC*                  eval      sap_matnr = ' ' + oritem
PAK A*
PAK A*      Load record format into export file field.
PAKeDC*                  eval      spdata      = s#e1edp01
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPHEADER    Populate SAP Header Record.
PAK A*
PAK AC     sapheader     begsr
PAK A*
PAKeDC*                  reset                   s#e1edk01
PAK AC                   reset                   s#e1rtnh
PAK A*
PAKeDC*                  eval      sap_K01mand   = sap_mand
PAKeMC                   move      pakrm1_vkorg  sap_vkorg
PAKeDC*                  eval      sappsgnum     = sappsgnum + 1
PAKeDC*                  eval      sap_K01psgnum = %editc(sappsgnum:'3')
PAKeD*
PAKeDC*                  evalr     sap_kzabs = ' '
PAKeDC*                  eval      sap_zterm = ' '
PAKeDC*                  eval      sap_bsart = 'ZRTN'
PAKeDC*                  eval      sap_belnr = ' '
PAKeDC*                  eval      sap_vsart = ' '
PAKeDC*                  eval      sap_augru = ' '
PAKfDC*                  evalr     sap_refdoc  = %editc(dftdoc#:'X')
PAKfDC*                                          + %trimr(pakrm1_bdoc)
PAKjDC*                  evalr     sap_refdoc  = %editc(dftdoc#:'X')
PAKjDC*                                          + %trimr(orinv#)
PAKjMC                   eval      sap_refdoc  = '   '
PAKjMC                                           + %trim(orinv#)
PAK A*
PAK A*      Load record format into export file field.
PAKeDC*                  eval      spdata    = s#e1edk01
PAK AC                   eval      spdata    = s#e1rtnh
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPHDRADD    Populate SAP Header Additional Data Record.
PAK A*
PAK AC     saphdradd     begsr
PAK A*
PAKcDC*                  reset                   s#e1edk02
PAK A*
PAKcDC*                  eval      sap_K02mand   = sap_mand
PAKcDC*                  eval      sappsgnum     = sappsgnum + 1
PAKcDC*                  eval      sap_K02psgnum = %editc(sappsgnum:'3')
PAK A*
PAKcDC*                  eval      sap_K02belnr = ' '
PAK A*
PAK A*      Load record format into export file field.
PAKcDC*                  eval      spdata    = s#e1edk02
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
PAK AC                   eval      ikplnt = ' '
PAK AC                   eval      ikcat  = ' '
PAK AC                   eval      ikvar  = 0
PAK AC                   endif
PAK A*
PAK AC                   endsr
PAKcA*
PAKcA*----------------------------------------------------------------
PAKcA*
PAKcA*  ZZGETLBL    Get Original Label record.
PAKcA*
PAKcAC     zzgetlbl      begsr
PAKcA*
PAKcAC     lb93key       setll     label93
PAKcAC     lb93key       reade     label93
PAKcAC                   if        %eof(label93)
PAKcAC                   eval      lbseq  = 0
PAKcAC                   eval      lbutyp = 'N'
PAKcAC                   endif
PAKcA*
PAKcAC                   endsr
PAKcA*
PAKcA*----------------------------------------------------------------
PAKcA*
PAKcA*  ZZGETOH    Get Dakota Customer Order Header
PAKcA*
PAKcAC     zzgetoh       begsr
PAKcA*
PAKgAC                   if        orwhse = 1
PAKgA*
PAKgA*      Retrieve Order Header using Cust. Order# from Returns
PAKgA*      file since Alpha doesn't use ORDHM file.
PAKiA*
PAKgA*      Order ID loaded into ORRTNM file starting 05/20/10.
PAKiAC                   if        pakrm1_ordid > ' '
PAKiAC                   move      pakrm1_ordid  kyordid
PAKiAC     oh5akey       chain     ordh5
PAKiAC                   else
PAKgAC     oh5key        chain     ordh5
PAKiAC                   endif
PAKiA*
PAKgAC                   if        not %found(ordh5)
PAKgAC                   eval      ohord = 0
PAKgAC                   endif
PAKgAC                   eval      hmord = ohord
PAKgA*
PAKgAC                   else
PAKgA*
PAKcAC     ohkey         chain     ordh
PAKcAC                   if        not %found(ordh)
PAKcAC                   eval      ohord = 0
PAKcAC                   endif
PAKgA*
PAKgAC                   endif
PAKcA*
PAKcAC                   endsr
PAKcA*
PAKcA*----------------------------------------------------------------
PAKcA*
PAKcA*  ZZGETOHM   Get Dakota Customer Order Header Misc.
PAKcA*
PAKcAC     zzgetohm      begsr
PAKcA*
PAKcAC                   move      orinv#        kydelv
PAKcAC     ohm3key       chain     ordhm3
PAKcAC                   if        not %found(ordhm3)
PAKcAC                   eval      hmord  = 0
PAKcAC                   eval      hmmsc1 = ' '
PAKcAC                   eval      hmmsc2 = ' '
PAKcAC                   eval      hmmsc3 = ' '
PAKcAC                   eval      hmmsc4 = ' '
PAKcAC                   eval      hmmsc5 = ' '
PAKcAC                   endif
PAKcA*
PAKcA*
PAKaAC                   select
PAKaAC                   when      client = packers
PAKaAC                   eval      pakhm1_base = hmmsc1
PAKcAC                   if        not %found(ordhm3)
PAKcAC                   eval      pakhm1_slsorg = '0000'
PAKcAC                   endif
PAKaAC                   eval      pakhm2_base = hmmsc2
PAKaAC                   eval      pakhm3_base = hmmsc3
PAKaAC                   eval      pakhm4_base = hmmsc4
PAKaAC                   eval      pakhm5_base = hmmsc5
PAKaAC                   endsl
PAKcA*
PAKcAC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  ZZGETSP   Get SAP Item Return code
PAK A*
PAK AC     zzgetsp       begsr
PAK A*
PAK AC     orrcod        chain     saprcod
PAK AC                   if        not %found(saprcod)
PAK AC                   eval      spsapc = '   '
PAK AC                   endif
PAK A*
PAK AC                   endsr
PAKdA*
PAKdA*----------------------------------------------------------------
PAKdA*
PAKdA*  ZZGETORRTNM  Get Billing document number
PAKdA*
PAKdAC     zzgetorrtnm   begsr
PAKdA*
PAKdAc                   reset                   rmmsc1_pak
PAKdAc     orrkey        chain     orrtnm
PAKdAc                   if        %found(orrtnm)
PAKdAc                   move      rmmsc1        rmmsc1_pak
PAKiAc                   else
PAKiAc                   eval      pakrm1_ordid = ' '
PAKdAc                   endif
PAKdA*
PAKdAC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  ZZGETSM   Get SAP Item Movement code
PAK A*
PAK AC     zzgetsm       begsr
PAK A*
PAKcDC*    orrcod        chain     sapmove1
PAKcDC*                  if        not %found(sapmove1)
PAKcDC*                  eval      smsapc = ' '
PAKcDC*                  eval      smmove = ' '
PAKcDC*                  eval      smindc = ' '
PAKcDC*                  eval      smcost = 0
PAKcDC*                  eval      smprft = 0
PAKcDC*                  endif
PAK A*
PAK AC                   endsr
