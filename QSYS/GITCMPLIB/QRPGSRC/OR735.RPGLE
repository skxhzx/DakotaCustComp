     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  OR735     Export customer returns - Post
     *  10 November, 1994
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *  Revisions
     *
213 A*    05/24/96  DAS
    A*      - Added new fields OECWTR, OETYPE, OETRN#, OECITM.
     *
416 A*    10/16/01  MLB  4.16
    A*      - Field added to ORRTN. Re-compile only.
416aA*    Ver 4.16a 11/07/01  RH
     *      - Added fields ORDCOD, ORIINV, OROLB#, ORINV#
640a *    03/22/11   GJA   6.40a
     *      - Enh:  Added client code.
     *----------------------------------------------------------------
     * Client Custom Revisions:  I Supply
ISPa *    03/22/11   GJA   ISPa
     *      - Enh: Move credit memo field to order number
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
ISPaAForrtnm    uf   e           k disk
     Fexprtn    o  a e           k disk
     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
     D today           s              8  0
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getcl          c                   const('GETCLIENT')
ISPaA /COPY QCOPYSRC,ID#ISUPPLY
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
     *
     *  Add customer returns to export file.
     *
     C                   exsr      filoe
     C                   write     oerec                                79
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
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
640aA*
640aA* Get client id.
640aA*
640aAC                   call      @getcl
640aAC                   parm                    client           10
640aAC                   parm                    cliloc           10
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
ISPaA*
ISPaA*  ORRTNM file
ISPaA*
     C     keyrm         klist
     C                   kfld                    orwhse
     C                   kfld                    orord
     C                   kfld                    oritem
     C                   kfld                    orrdte
     C                   kfld                    orrtim
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
ISPaAC                   if        client = isupply
ISPaAC     keyrm         chain     orrtnm                             79
ISPaAC                   if        not *in79
ISPaAC                   movel     rmmsc2        oeord
ISPaA*
ISPaA*  Update customer return misc file with upload date and time.
ISPaA*
ISPaAC                   eval      rmudte = today
ISPaAC                   time                    rmutim
ISPaAC                   update    rmrec
ISPaAC                   else
ISPaAC                   eval      oeord = orord
ISPaAC                   endif
ISPaAC                   else
     C                   eval      oeord = orord
ISPaAC                   endif
     *
     C                   eval      oeitem = oritem
     C                   eval      oeqty1 = orqty1
     C                   eval      oeqty2 = orqty2
     C                   eval      oeqty3 = orqty3
213 AC                   eval      oecwtr = orcwtr
     C                   eval      oerdte = orrdte
     C                   eval      oertim = orrtim
     C                   eval      oerusr = orrusr
213 AC                   eval      oetype = ortype
213 AC                   eval      oetrn# = ortrn#
213 AC                   eval      oecitm = orcitm
     C                   eval      oercod = orrcod
416aAC                   eval      oedcod = ordcod
416aAC                   eval      oeiinv = oriinv
416aAC                   eval      oeolb# = orolb#
416aAC                   eval      oeinv# = orinv#
     C                   eval      oermem = orrmem
     *
     *
     C                   endsr
