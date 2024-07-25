      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  QDPACKCONV   Convert warehouse number for Packers
     *  18 June 2006
     *  Dave Sommerville
     *
     *  Revisions
500 A*    06/18/06  DAS  5.10
     *      - Created.
     *
500 B*    06/20/06  RMC  5.10
     *      - Added additional files to clear.
     *
     *----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  Customer id
500 A*----------------------------------------------------------------
500 A
500 A /copy qcopysrc,id#packers

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D oldwhse         s              3  0
     D newwhse         s              3  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500 A
500 A* If not *CHANGE, then get out.
500 A
PCK AC                   if        $pcmd <> '*CHANGE'
PCK AC                   goto      bottom
PCK AC                   endif
500 A
500 A* Get client id.
500 A
500 AC                   call      'GETCLIENT'
500 AC                   parm                    client           10
500 A
500 A* Get out if not Packers.
500 A
PCK AC                   if        client <> packers
PCK AC                   goto      bottom
PCK AC                   endif
500 A
500 A* Define old and new warehouses
500 A
PCK AC                   eval      oldwhse = 1
PCK AC                   eval      newwhse = 200

     * Establish the connection to local machine.

     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC

     * Update file LABEL


     C/EXEC SQL
     C+  UPDATE LABEL
     C+  SET LBWHSE = :newwhse
     C+  WHERE LBWHSE = :oldwhse
     C/END-EXEC

     * Update file PIRTRAN


     C/EXEC SQL
     C+  UPDATE PIRTRAN
     C+  SET PTWHSE = :newwhse
     C+  WHERE PTWHSE = :oldwhse
     C/END-EXEC

510 B* Update file BATCTL

510 BC/EXEC SQL
510 BC+  UPDATE BATCTL
510 BC+  SET BTWHSE = :newwhse
510 BC+  WHERE BTWHSE = :oldwhse
510 BC/END-EXEC


510 B* Update file CREW

510 BC/EXEC SQL
510 BC+  UPDATE CREW
510 BC+  SET CRWHSE = :newwhse
510 BC+  WHERE CRWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file DEPTDEF

510 BC/EXEC SQL
510 BC+  UPDATE DEPTDEF
510 BC+  SET DDWHSE = :newwhse
510 BC+  WHERE DDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file DLYHITR

510 BC/EXEC SQL
510 BC+  UPDATE DLYHITR
510 BC+  SET HRWHSE = :newwhse
510 BC+  WHERE HRWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file DLYHITS

510 BC/EXEC SQL
510 BC+  UPDATE DLYHITS
510 BC+  SET HTWHSE = :newwhse
510 BC+  WHERE HTWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file DLYQTY

510 BC/EXEC SQL
510 BC+  UPDATE DLYQTY
510 BC+  SET DQWHSE = :newwhse
510 BC+  WHERE DQWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file DLYZROR

510 BC/EXEC SQL
510 BC+  UPDATE DLYZROR
510 BC+  SET HZWHSE = :newwhse
510 BC+  WHERE HZWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITEMADJ

510 BC/EXEC SQL
510 BC+  UPDATE ITEMADJ
510 BC+  SET IAWHSE = :newwhse
510 BC+  WHERE IAWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITEMAVG

510 BC/EXEC SQL
510 BC+  UPDATE ITEMAVG
510 BC+  SET IGWHSE = :newwhse
510 BC+  WHERE IGWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITEMDEF

510 BC/EXEC SQL
510 BC+  UPDATE ITEMDEF
510 BC+  SET IDWHSE = :newwhse
510 BC+  WHERE IDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITEMDSC

510 BC/EXEC SQL
510 BC+  UPDATE ITEMDSC
510 BC+  SET IXWHSE = :newwhse
510 BC+  WHERE IXWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITEMFLD

510 BC/EXEC SQL
510 BC+  UPDATE ITEMFLD
510 BC+  SET IFWHSE = :newwhse
510 BC+  WHERE IFWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITEMLNK

510 BC/EXEC SQL
510 BC+  UPDATE ITEMLNK
510 BC+  SET ILWHSE = :newwhse
510 BC+  WHERE ILWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITEMMSC

510 BC/EXEC SQL
510 BC+  UPDATE ITEMMSC
510 BC+  SET IMWHSE = :newwhse
510 BC+  WHERE IMWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITEMORD

510 BC/EXEC SQL
510 BC+  UPDATE ITEMORD
510 BC+  SET IIWHSE = :newwhse
510 BC+  WHERE IIWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITEMQTY

510 BC/EXEC SQL
510 BC+  UPDATE ITEMQTY
510 BC+  SET IQWHSE = :newwhse
510 BC+  WHERE IQWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITEMSLS

510 BC/EXEC SQL
510 BC+  UPDATE ITEMSLS
510 BC+  SET IHWHSE = :newwhse
510 BC+  WHERE IHWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITMDIMN

510 BC/EXEC SQL
510 BC+  UPDATE ITMDIMN
510 BC+  SET IDWHSE = :newwhse
510 BC+  WHERE IDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ITMEXCP

510 BC/EXEC SQL
510 BC+  UPDATE ITMEXCP
510 BC+  SET EXWHSE = :newwhse
510 BC+  WHERE EXWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file LAYOUTD

510 BC/EXEC SQL
510 BC+  UPDATE LAYOUTD
510 BC+  SET LDWHSE = :newwhse
510 BC+  WHERE LDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file LAYOUTH

510 BC/EXEC SQL
510 BC+  UPDATE LAYOUTH
510 BC+  SET LHWHSE = :newwhse
510 BC+  WHERE LHWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file LICENSE

510 BC/EXEC SQL
510 BC+  UPDATE LICENSE
510 BC+  SET LIWHSE = :newwhse
510 BC+  WHERE LIWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file LICHIST

510 BC/EXEC SQL
510 BC+  UPDATE LICHIST
510 BC+  SET LRWHSE = :newwhse
510 BC+  WHERE LRWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file LICINFO

510 BC/EXEC SQL
510 BC+  UPDATE LICINFO
510 BC+  SET LNWHSE = :newwhse
510 BC+  WHERE LNWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file OPTIOND

510 BC/EXEC SQL
510 BC+  UPDATE OPTIOND
510 BC+  SET OPDWHS = :newwhse
510 BC+  WHERE OPDWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file OPTIONE

510 BC/EXEC SQL
510 BC+  UPDATE OPTIONE
510 BC+  SET OPEWHS = :newwhse
510 BC+  WHERE OPEWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file OPTIONS

510 BC/EXEC SQL
510 BC+  UPDATE OPTIONS
510 BC+  SET OPWHSE = :newwhse
510 BC+  WHERE OPWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file OPTIONZ

510 BC/EXEC SQL
510 BC+  UPDATE OPTIONZ
510 BC+  SET OPZWHS = :newwhse
510 BC+  WHERE OPZWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file PIRDEV

510 BC/EXEC SQL
510 BC+  UPDATE PIRDEV
510 BC+  SET PDWHSE = :newwhse
510 BC+  WHERE PDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file PIRET#

510 BC/EXEC SQL
510 BC+  UPDATE PIRET#
510 BC+  SET NXEWHS = :newwhse
510 BC+  WHERE NXEWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file PIREW#

510 BC/EXEC SQL
510 BC+  UPDATE PIREW#
510 BC+  SET EWNWHS = :newwhse
510 BC+  WHERE EWNWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file PIRITEM

510 BC/EXEC SQL
510 BC+  UPDATE PIRITEM
510 BC+  SET ITWHSE = :newwhse
510 BC+  WHERE ITWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file PIRITMS

510 BC/EXEC SQL
510 BC+  UPDATE PIRITMS
510 BC+  SET ISWHSE = :newwhse
510 BC+  WHERE ISWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file PIRORD#

510 BC/EXEC SQL
510 BC+  UPDATE PIRORD#
510 BC+  SET NXOWHS = :newwhse
510 BC+  WHERE NXOWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file PIRPRNT

510 BC/EXEC SQL
510 BC+  UPDATE PIRPRNT
510 BC+  SET WPWHSE = :newwhse
510 BC+  WHERE WPWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file PIRRTE#

510 BC/EXEC SQL
510 BC+  UPDATE PIRRTE#
510 BC+  SET NXRWHS = :newwhse
510 BC+  WHERE NXRWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file PIRSLCT

510 BC/EXEC SQL
510 BC+  UPDATE PIRSLCT
510 BC+  SET STWHSE = :newwhse
510 BC+  WHERE STWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file PIRUSER

510 BC/EXEC SQL
510 BC+  UPDATE PIRUSER
510 BC+  SET USWHSE = :newwhse
510 BC+  WHERE USWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file PODTL

510 BC/EXEC SQL
510 BC+  UPDATE PODTL
510 BC+  SET PDWHSE = :newwhse
510 BC+  WHERE PDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file POEXCP

510 BC/EXEC SQL
510 BC+  UPDATE POEXCP
510 BC+  SET PEWHSE = :newwhse
510 BC+  WHERE PEWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file POHACCP

510 BC/EXEC SQL
510 BC+  UPDATE POHACCP
510 BC+  SET HAWHSE = :newwhse
510 BC+  WHERE HAWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file POHDR

510 BC/EXEC SQL
510 BC+  UPDATE POHDR
510 BC+  SET PHWHSE = :newwhse
510 BC+  WHERE PHWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file POHDTL

510 BC/EXEC SQL
510 BC+  UPDATE POHDTL
510 BC+  SET PHDWHS = :newwhse
510 BC+  WHERE PHDWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file POHEXCP

510 BC/EXEC SQL
510 BC+  UPDATE POHEXCP
510 BC+  SET PHEWHS = :newwhse
510 BC+  WHERE PHEWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file POHHDR

510 BC/EXEC SQL
510 BC+  UPDATE POHHDR
510 BC+  SET PHHWHS = :newwhse
510 BC+  WHERE PHHWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file POMFR

510 BC/EXEC SQL
510 BC+  UPDATE POMFR
510 BC+  SET PMWHSE = :newwhse
510 BC+  WHERE PMWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file PORCV

510 BC/EXEC SQL
510 BC+  UPDATE PORCV
510 BC+  SET PORWHS = :newwhse
510 BC+  WHERE PORWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file POSPO

510 BC/EXEC SQL
510 BC+  UPDATE POSPO
510 BC+  SET PUWHSE = :newwhse
510 BC+  WHERE PUWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file RACKS

510 BC/EXEC SQL
510 BC+  UPDATE RACKS
510 BC+  SET RKWHSE = :newwhse
510 BC+  WHERE RKWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file RPTOVR

510 BC/EXEC SQL
510 BC+  UPDATE RPTOVR
510 BC+  SET ROWHSE = :newwhse
510 BC+  WHERE ROWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file RPTOVRE

510 BC/EXEC SQL
510 BC+  UPDATE RPTOVRE
510 BC+  SET EOWHSE = :newwhse
510 BC+  WHERE EOWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file RUNNER

510 BC/EXEC SQL
510 BC+  UPDATE RUNNER
510 BC+  SET RUWHSE = :newwhse
510 BC+  WHERE RUWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file SHIFT

510 BC/EXEC SQL
510 BC+  UPDATE SHIFT
510 BC+  SET SHWHSE = :newwhse
510 BC+  WHERE SHWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file SLOT

510 BC/EXEC SQL
510 BC+  UPDATE SLOT
510 BC+  SET SLWHSE = :newwhse
510 BC+  WHERE SLWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file SLOTDEF

510 BC/EXEC SQL
510 BC+  UPDATE SLOTDEF
510 BC+  SET SDWHSE = :newwhse
510 BC+  WHERE SDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file SLOTDGT

510 BC/EXEC SQL
510 BC+  UPDATE SLOTDGT
510 BC+  SET SCDWHS = :newwhse
510 BC+  WHERE SCDWHS = :oldwhse
510 BC/END-EXEC

510 B* Update file SLOTOUT

510 BC/EXEC SQL
510 BC+  UPDATE SLOTOUT
510 BC+  SET SOWHSE = :newwhse
510 BC+  WHERE SOWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file SLOTPOS

510 BC/EXEC SQL
510 BC+  UPDATE SLOTPOS
510 BC+  SET SPWHSE = :newwhse
510 BC+  WHERE SPWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file STAGD

510 BC/EXEC SQL
510 BC+  UPDATE STAGD
510 BC+  SET SDWHSE = :newwhse
510 BC+  WHERE SDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file STAGH

510 BC/EXEC SQL
510 BC+  UPDATE STAGH
510 BC+  SET SHWHSE = :newwhse
510 BC+  WHERE SHWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file TASKDET

510 BC/EXEC SQL
510 BC+  UPDATE TASKDET
510 BC+  SET TDWHSE = :newwhse
510 BC+  WHERE TDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file TIEHIGH

510 BC/EXEC SQL
510 BC+  UPDATE TIEHIGH
510 BC+  SET THWHSE = :newwhse
510 BC+  WHERE THWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file TRANPH

510 BC/EXEC SQL
510 BC+  UPDATE TRANPH
510 BC+  SET TPWHSE = :newwhse
510 BC+  WHERE TPWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file TRKASIGN

510 BC/EXEC SQL
510 BC+  UPDATE TRKASIGN
510 BC+  SET TAWHSE = :newwhse
510 BC+  WHERE TAWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file TRKCOMP

510 BC/EXEC SQL
510 BC+  UPDATE TRKCOMP
510 BC+  SET TPWHSE = :newwhse
510 BC+  WHERE TPWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file TRUCKD

510 BC/EXEC SQL
510 BC+  UPDATE TRUCKD
510 BC+  SET TDWHSE = :newwhse
510 BC+  WHERE TDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file TRUCKH

510 BC/EXEC SQL
510 BC+  UPDATE TRUCKH
510 BC+  SET THWHSE = :newwhse
510 BC+  WHERE THWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file UPC

510 BC/EXEC SQL
510 BC+  UPDATE UPC
510 BC+  SET UPWHSE = :newwhse
510 BC+  WHERE UPWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file VSLOT

510 BC/EXEC SQL
510 BC+  UPDATE VSLOT
510 BC+  SET VSWHSE = :newwhse
510 BC+  WHERE VSWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file WAREHS

510 BC/EXEC SQL
510 BC+  UPDATE WAREHS
510 BC+  SET WHCODE = :newwhse
510 BC+  WHERE WHCODE = :oldwhse
510 BC/END-EXEC

510 B* Update file WHDEPT

510 BC/EXEC SQL
510 BC+  UPDATE WHDEPT
510 BC+  SET WDWHSE = :newwhse
510 BC+  WHERE WDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ZONED

510 BC/EXEC SQL
510 BC+  UPDATE ZONED
510 BC+  SET ZDWHSE = :newwhse
510 BC+  WHERE ZDWHSE = :oldwhse
510 BC/END-EXEC

510 B* Update file ZONEH

510 BC/EXEC SQL
510 BC+  UPDATE ZONEH
510 BC+  SET ZHWHSE = :newwhse
510 BC+  WHERE ZHWHSE = :oldwhse
510 BC/END-EXEC

     * Disconnect the current connection.

     C/EXEC SQL
     C+   DISCONNECT CURRENT
     C/END-EXEC
     C
PCK AC     bottom        tag
PCK AC                   eval      *inlr = *on
