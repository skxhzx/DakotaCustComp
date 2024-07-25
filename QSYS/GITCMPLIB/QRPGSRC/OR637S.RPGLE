      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR637S    Create unique piece numbers for a substitute item.
     *  09 May 2013
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    05/09/13  RBD  6.50
     *      - Created.  Cloned from OR637.
     *      - This pgm will be called by RH182 to create the proper
     *        number of ORDP records for a substitute item.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - Cheney
     *
CBIaA*    06/25/07  DAS  CBIa
     *      - Revised to create individual numbers for
     *        catchweight items
     *
CBIbA*    02/23/08  DAS  CBIb
     *      - Changed logic for reading only working with generation
     *        1 to be Cheney specific.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - Harbor
     *
HARbA*    03/20/09  RBD  HARb
     *      - In additional to opclvl, consider it a combo if unit of
     *        measure = EA and qty is greater than 1.
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Client Custom Revisions - City Line
     *
CLDaA*    07/02/10  RBD  CLDa
     *      - If ITTYPE = 'S', only create one unique piece# record.
     *
CLDbA*    11/13/12  RBD  CLDb
     *      - Reverse CLDa, will now use SSBXREF file instead of item
     *        type to identify these special meat items.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpltsum15  if   e           k disk
     Flabel     if   e           k disk
     Foptionz   if   e           k disk
CLDbAFssbxref   if   e           k disk
     Fordp      o    e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

CBIaA /copy qcopysrc,id#cheney
HARaA /copy qcopysrc,id#harbor
CLDaA /copy qcopysrc,id#citylin
     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
     D savever#        s                   like($itver#)
     D save$item       s                   like($item)
     D save$item2      s                   like($item2)

     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
     *
     * Data structure
     *
     D opzdta          ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  optend               117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables.
     *----------------------------------------------------------------

     D error           s               n
     D forever         s               n
     D i               s                   like(lbqpck)
HARaAD int1            s              5  0
HARaAD int2            s              5  0
     D kycode          s                   like(opzcod)
     D lastzone        s                   like(psszon)
     D qty2Create      s                   like(lbqpck)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route id
     *      $PLBL#  Label number
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $plbl#            7 0

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Get label record for the label passed in.

     C     keylb         chain     label
     C                   if        not %found(label)
     C                   goto      bottom
     C                   endif

     *  Get pltsum record for the label passed in.

     C     keyps15       chain     pltsum15

     *    Only create numbers for gen 1 pallets.
CBIbA*      - Only for Cheney.

     C                   if        psgen <> 1
CBIbAC                             and client = cheney
     C                   goto      bottom
     C                   endif

     *    Get zone options

     C                   exsr      getZoneOpts

     *        Initialize piece record fields.

     C                   eval      orpwhs = lbwhse
     C                   eval      orprid = lbrte
     C                   eval      orpord = lbord
     C                   eval      orpsq# = lbseq
     C                   eval      orpitm = lbitem
     C                   eval      orplbl = lblbl#
     C                   eval      orpseq = 0
     C                   eval      orpwgt = 0

     *        Determine how many numbers need to be created.

     C                   exsr      getQty2Create

     *        Create piece records.

     C                   eval      orpcnt = 0
     C                   eval      orpttl = qty2Create
     C                   if        qty2Create = 1
     C                   eval      orpscn = lbqpck
     C                   else
     C                   eval      orpscn = 1
     C                   endif

     C     1             do        qty2Create    i
     C                   eval      orpcnt = orpcnt + 1

     C                   dow       forever = forever
     C                   call      'PIRCADEC#'
     C                   parm                    orpup#
     C                   write(e)  orprec
     C                   if        %error
     C                   iter
     C                   endif
     C                   leave
     C                   enddo

     C                   enddo

     *  Bye, Bye

     C     bottom        tag
     C                   eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *inzsr  -  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define key for LABEL file.

     C     keylb         klist
     C                   kfld                    $plbl#

     *  Define key for PLTSUM15 file.

     C     keyps15       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lbpal#

     *  Define key for OPTIONZ file.

     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    pswhse
     C                   kfld                    $ptmpl
     C                   kfld                    psszon

CLDbA*  Define key for SSBXREF file.
CLDbA
CLDbAC     keyssb        klist
CLDbAC                   kfld                    $pwhse
CLDbAC                   kfld                    $ititem

     *  Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client
     C                   parm                    clientloc
     C                   endsr

     *----------------------------------------------------------------
     *  getItem    Get item information
     *----------------------------------------------------------------

     C     getItem       begsr

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#

     C                   eval      $itwhse   = lbwhse
     C                   eval      $ititem   = lbitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   eval      $itcwgt = 'N'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getQty2Create   Get quantity of numbers to create.
     *----------------------------------------------------------------

     C     getQty2Create begsr

     *    Get item information.

     C                   if        client = cheney
CLDaAC                             or client = cityline
     C                   exsr      getItem
     C                   endif

     C                   select

     *   For bulk picks only create 1 number.

     C                   when      lbtype = 'B'
     C                   eval      qty2Create = 1

CBIaA*   For Cheney catchweights create 1 for each piece.

CBIaAC                   when      client = cheney
CBIaAC                             and $itcwgt = 'Y'
CBIaAC                   eval      qty2Create = lbqpck

     *   For a combo label only create 1 number.

     C                   when      lbqpck >= opclvl
     C                   eval      qty2Create = 1

HARbA*   For Harbor, consider it a combo if u/m EA and qty > 1.

HARbAC                   when      client = harbor
HARbAC                             and lbucod = 'EA'
HARbAC                             and lbqpck > 1
HARbAC                   eval      qty2Create = 1

CLDbM*   For City Line, if item in SSBXREF, only create 1 unique piece#.

CLDaAC                   when      client = cityline
CLDbAC     keyssb        chain     ssbxref
CLDbAC                   if        %found(ssbxref)
CLDaAC                   eval      qty2Create = 1
CLDbAC                   else
CLDbAC                   eval      qty2Create = lbqpck
CLDbAC                   endif

     *   Otherwise create 1 for each piece.

     C                   other
     C                   eval      qty2Create = lbqpck

     C                   endsl

     *        If item is out, still create 1 ORDP record.
     C                   if        qty2Create = 0
     C                   eval      qty2Create = 1
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getZoneOpts   Get zone options
     *----------------------------------------------------------------

     C     getZoneOpts   begsr

     C                   call      'GETZONTMPL'
     C                   parm                    $pwhse
     C                   parm                    pstruk
     C                   parm                    $ptmpl           10

     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain(e)  optionz
     C                   if        not %found
     C                   eval      opclvl = *hival
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata
     C     $item2        parm      $item2        $dridata2

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   endsl

     C     enddricop     endsr
