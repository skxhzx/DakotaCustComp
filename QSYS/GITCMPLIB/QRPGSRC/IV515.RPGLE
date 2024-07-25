      /copy *libl/qcopysrc,hspecs
501jAH dftactgrp(*NO)
501jAH actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  IV515     Post inventory counts - Update lichist records
     *  06 May 2005
     *  Dave Sommerville
     *
     *  Revisions
     *
500 A*    05/06/05  DAS  5.00
     *      - Created
     *
500aA*    06/27/05  DAS  5.00a
     *      - Revised to to create a new license history record for a
     *        that is at status 'V' or 'Z'.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V5R1M0)
     *
     *    CRTPGM PGM(*) MODULE(*) ACTGRP(*NEW) TGTRLS(V5R1M0)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    This program needs to be compiled with DEFER=*NO so the status
     *    messages can be displayed.
     *
     *    This program uses a revised method to display error messages.
     *    Instead of the program writting each message to the subfile
     *    using the message key the subfile has been revised to display
     *    all messages from the program message queue automatically.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    05/06/05  DAS  5.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Finvslot   if   e           k disk
500 AFinvspos   if   e           k disk
     Flichist2  uf a e           k disk
     Flichist5  uf   e           k disk
     F                                     rename(lrrec:lrrec5)
     Fslot1     if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

100bA /copy qcopysrc,p.bfcdteti

500cA*----------------------------------------------------------------
500cA*  DRI parameters
500cA*----------------------------------------------------------------
500cA
500cA /COPY *libl/qcopysrc,C#DRIPARMS
500cA
500cA*----------------------------------------------------------------
500cA*  Data Formats
500cA*----------------------------------------------------------------
500cA
500cA /COPY *libl/qcopysrc,C#SLOT
500cAD saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D  erwhse                 1      2p 0
     D  erwhdp                 3      7
     D  erstyp                 8     12
     D                 ds
     D  $ec                    1      2p 0
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#PGMINFDS

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

100bMD CurrStamploc    s               z
100bAD CurrStampsys    s               z
100bAD CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
100bAD ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

100bAD bfcoffset       s              3  0 inz(0)

     D currtimestamp   s               z

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
500cAD chk4err         s               n
500cAD error           s               n
     D first           s               n
     D forever         s               n
     D lastbase        s             12
     D lststp          s              1
     D lstwhd          s              5
     D lstwhs          s              3  0
     D temp7a          s              7
500cAD zmsflag         s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *POSTINV - Posting inventory counts first time.
     *              *RESTART - Restarting abnormally ended batch.
     *      $PWHSE  Warehouse
     *      $PBAT   Batch number
     *      $PJOBQ  Running from JOBQ (Y,N)
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message sent to pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
416d C                   parm                    $pwhdp            5
     C                   parm                    $pjobq            1
     C                   parm                    $prtn             8
408 AC                   parm                    $ppexp            1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      $prtn = *blanks

     *  Loop through invslot records in slot order.

     C     keyivs        setll     invslot
     C                   dou       forever <> forever

     C     keyivs        reade     invslot

     C                   if        %eof
     C                   leave
     C                   endif

     *    Loop if slot is not in scope.

     C                   if        $pwhdp <> '*ALL'  and
     C                             ivswhd <> $pwhdp
     C                   iter
     C                   endif

     *    Get slot information

     C                   exsr      getslot
     C                   if        error
     C                   iter
     C                   endif

     *    If base slot changes, inactivate invalid lichist records.

     C                   if        $sacdsp <> lastbase
     C                   eval      lastbase = $sacdsp
     C                   exsr      lhremove
     C                   endif

     *    Otherwise, update lichist.

     C                   exsr      lhupdate

     C                   enddo

     C                   exsr      zzzdriclose
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   eval      lastbase = *hival

     * Key definitions

     *  Define key for INVSLOT file.

     C     keyivs        klist
     C                   kfld                    $pwhse

     *  Define key for INVSPOS file.

     C     keyivo        klist
     C                   kfld                    $slwhse
     C                   kfld                    $slwhdp
     C                   kfld                    $slaisl
     C                   kfld                    $slloc
     C                   kfld                    $slrlvl
     C                   kfld                    $slhand

     *  Define key for LICHIST2 file.

     C     keylh2        klist
     C                   kfld                    $slwhse
     C                   kfld                    $slwhdp
     C                   kfld                    $slaisl
     C                   kfld                    $slloc
     C                   kfld                    $slrlvl
     C                   kfld                    $slhand

     *  Define key for LICHIST5 file.

     C     keylr5        klist
     C                   kfld                    $slwhse
     C                   kfld                    $slwhdp
     C                   kfld                    $sacdsp

     *  Define key for SLOT1 file.

     C     keysl1        klist
     C                   kfld                    lrwhse
     C                   kfld                    lrtwhd
     C                   kfld                    lrtasl
     C                   kfld                    lrtloc
     C                   kfld                    lrtlvl
     C                   kfld                    lrthnd

     C                   endsr

100bA*----------------------------------------------------------------
100bA*  getcurrstamp  Get current timestamps
100bA*----------------------------------------------------------------
100bA
100bAC     getcurrstamp  begsr

100bMC                   callp     getmicrotime(currstampuc:currstampsys)
100bAC     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr

     *----------------------------------------------------------------
     *  getslot   Get slot information.
     *----------------------------------------------------------------

     C     getslot       begsr
500cA
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = ivswhs
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = ivswhd
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ivsdsp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  getslotpos  Get slot position
     *----------------------------------------------------------------

     C     getslotpos    begsr

     C     keyivo        setll     invspos
     C     keyivo        reade     invspos

     C                   if        %eof
     C                   eval      ivopos = 1
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  lhcreate   Create new lichist record for adjustment.
     *----------------------------------------------------------------

     C     lhcreate      begsr

     *  Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
     C                   eval      lrstat = 'A '
     C                   eval      lrexcd = 'INVCNT'

     *  Update From info with To info from original record.
     *  Note, To info remains the same for an adjustment.

     C                   eval      lrflic = lrlcns
     C                   eval      lrfcod = lrtcod
     C                   eval      lrfara = lrtara
     C                   eval      lrfwhd = lrtwhd
     C                   eval      lrfdsp = lrtdsp
     C                   eval      lrfbase = lrtbase
     C                   eval      lrfasl = lrtasl
     C                   eval      lrfloc = lrtloc
     C                   eval      lrflvl = lrtlvl
     C                   eval      lrfhnd = lrfhnd
     C                   eval      lrfslp = lrtslp
     C                   eval      lrfitm = lrtitm
     C                   eval      lrfityp = lrtityp
     C                   eval      lrfitms = lrtitms

     *    - Update quantities and change information.

     C                   eval      lraqy1 = $slstk1 - lrlqy1
     C                   eval      lraqy2 = $slstk2 - lrlqy2
     C                   eval      lraqy3 = $slstk3 - lrlqy3

     C                   eval      lrlqy1 = $slstk1
     C                   eval      lrlqy2 = $slstk2
     C                   eval      lrlqy3 = $slstk3

     *    - Update slot positon

     C                   eval      lrtslp = ivopos

     *    - Update Added by info for new record.

     C                   exsr      getcurrstamp
     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = #pgm
     C                   eval      lraddemp    = 0
     C                   eval      lraddusr    = #user
     C                   eval      lraddjob    = #job
     C                   eval      lraddnbr    = #jobnbr

     *    - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '

417lA
417lAC                   eval      lrnode = %trimr(lrnode) + '1'

     *    - Write or update record.

     C                   write     lrrec

     C                   endsr

     *----------------------------------------------------------------
     *  lhcreatezero  Create new zero inactive lichist record.
     *----------------------------------------------------------------

     C     lhcreatezero  begsr

     *  Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
     C                   eval      lrstat = 'I '
     C                   eval      lrexcd = 'INVCNT'

     *  Update From info with To info from original record.
     *  Note, To info remains the same for an adjustment.

     C                   eval      lrflic = lrlcns
     C                   eval      lrfcod = lrtcod
     C                   eval      lrfara = lrtara
     C                   eval      lrfwhd = lrtwhd
     C                   eval      lrfdsp = lrtdsp
     C                   eval      lrfbase = lrtbase
     C                   eval      lrfasl = lrtasl
     C                   eval      lrfloc = lrtloc
     C                   eval      lrflvl = lrtlvl
     C                   eval      lrfhnd = lrfhnd
     C                   eval      lrfslp = lrtslp
     C                   eval      lrfitm = lrtitm
     C                   eval      lrfityp = lrtityp
     C                   eval      lrfitms = lrtitms

     *    - Update quantities and change information.

     C                   eval      lraqy1 = -(lrlqy1)
     C                   eval      lraqy2 = -(lrlqy2)
     C                   eval      lraqy3 = -(lrlqy3)

     C                   eval      lrlqy1 = 0
     C                   eval      lrlqy2 = 0
     C                   eval      lrlqy3 = 0

     *    - Update slot positon

     C                   eval      lrtslp = ivopos

     *    - Update Added by info for new record.

     C                   exsr      getcurrstamp
     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = #pgm
     C                   eval      lraddemp    = 0
     C                   eval      lraddusr    = #user
     C                   eval      lraddjob    = #job
     C                   eval      lraddnbr    = #jobnbr

     *    - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '

417lA
417lAC                   eval      lrnode = %trimr(lrnode) + '1'

     *    - Write or update record.

     C                   write     lrrec

     C                   endsr

     *----------------------------------------------------------------
     *  lhinactivate2  Inactivate lichist record.
     *----------------------------------------------------------------

     C     lhinactivate2 begsr

     C                   exsr      getcurrstamp
     C                   eval      lrstat      = 'I'
     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = #pgm
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = #user
     C                   eval      lrchgjob    = #job
     C                   eval      lrchgnbr    = #jobnbr

     C                   update    lrrec

     C                   endsr

     *----------------------------------------------------------------
     *  lhinactivate5  Inactivate lichist record.
     *----------------------------------------------------------------

     C     lhinactivate5 begsr

     C                   exsr      getcurrstamp
     C                   eval      lrstat      = 'I'
     C                   eval      lrexcd      = 'INVLDSL'
     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = #pgm
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = #user
     C                   eval      lrchgjob    = #job
     C                   eval      lrchgnbr    = #jobnbr

     C                   update    lrrec5

     C                   endsr

     *----------------------------------------------------------------
     *  lhmissing  Create missing lichist record.
     *----------------------------------------------------------------

     C     lhmissing     begsr

500aA*  Do not create record if slot is at 'V' or 'Z' status.
500aA
500aAC                   if        $slstat = 'V' or $slstat='Z'
500aAC                   goto      endlhmissing
500aAC                   endif

100bA*  Create new record with fixed quantity.

     *    - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#

     C                   eval      lrstat = 'A '
     C                   eval      lrexcd = 'INVCNT'

     C                   move      nxtlp#        temp7a
     C                   eval      lrlcns = '*NF' + temp7a
     C                   eval      lrolic = lrlcns

     *    - Update From info with To info from original record.

     C                   eval      lrflic = ' '
     C                   eval      lrfcod = '?'
     C                   eval      lrfara = 'Unknown'
     C                   eval      lrfwhd = ' '
     C                   eval      lrfdsp = ' '
     C                   eval      lrfbase = ' '
     C                   eval      lrfasl = ' '
     C                   eval      lrfloc = 0
     C                   eval      lrflvl = 0
     C                   eval      lrfhnd = ' '
     C                   eval      lrfslp = 0
     C                   eval      lrfitm = ' '
     C                   eval      lrfityp = ' '
     C                   eval      lrfitms = ' '

     *    - Update To info.

     C                   eval      lrtcod = 'S'
     C                   eval      lrtara = 'Slot'
     C                   eval      lrwhse = $slwhse
     C                   eval      lrtwhd = $slwhdp
     C                   eval      lrtdsp = $sldisp
     C                   eval      lrtbase = $sacdsp
     C                   eval      lrtasl = $slaisl
     C                   eval      lrtloc = $slloc
     C                   eval      lrtlvl = $slrlvl
     C                   eval      lrthnd = $slhand
     C                   eval      lrtslp = ivopos
     C                   eval      lrtitm = $slitem
     C                   eval      lrtityp = ' '
     C                   eval      lrtitms = $slitem

     *    - Update quantities and change information.

     C                   eval      lraqy1 = $slstk1
     C                   eval      lraqy2 = $slstk2
     C                   eval      lraqy3 = $slstk3

     C                   eval      lrlqy1 = $slstk1
     C                   eval      lrlqy2 = $slstk2
     C                   eval      lrlqy3 = $slstk3

     *    - Update Added by info for new record.

     C                   exsr      getcurrstamp
     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = #pgm
     C                   eval      lraddemp    = 0
     C                   eval      lraddusr    = #user
     C                   eval      lraddjob    = #job
     C                   eval      lraddnbr    = #jobnbr

     *    - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '

417laC                   eval      lrnode    = '1'

     *    - Write or update record.

     C                   write     lrrec

500aAC     endlhmissing  endsr

     *----------------------------------------------------------------
     *  lhremove   Inactivate invalid lichist records.
     *----------------------------------------------------------------

     C     lhremove      begsr

     *  Loop through lichist records for base slot.

     C     keylr5        setll     lichist5
     C                   dou       forever <> forever

     C     keylr5        reade     lichist5

     C                   if        %eof
     C                   leave
     C                   endif

     *  If not a Slot or Floor record, inactivate.

     C                   if        lrtcod <> 'S' and lrtcod <> 'F'
     C                   exsr      lhinactivate5
     C                   exsr      lhcreatezero
     C                   iter
     C                   endif

     *  Get corresponding To slot.

     C     keysl1        chain     slot1

     *  If valid slot record not found, then inactivate.

     C                   if        not %found
     C                             or slitem <> lrtitm
     C                             or slstat = 'V'
     C                             or slstat = 'Z'
     C                   exsr      lhinactivate5
     C                   exsr      lhcreatezero
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  lhupdate   Update/Create lichist records
     *----------------------------------------------------------------

     C     lhupdate      begsr

     *  Get slot position entered during inventory.

     C                   exsr      getslotpos

     *  Loop through Active history records for slot.

     C     keylh2        setll     lichist2

     C                   eval      first = *on
     C                   dow       forever = forever

     C     keylh2        reade     lichist2

     *    Create hist rec if none exists.

     C                   if        %eof
     C                   if        first
     C                   exsr      lhmissing
     C                   endif
     C                   leave
     C                   endif

     C                   select

     *    If items don't match, Inactivate the hist record.

     C                   when      slitem <> lrtitm
     C                   eval      lrexcd      = 'INVLDSL'
     C                   exsr      lhinactivate2
     C                   exsr      lhcreatezero

     *    Otherwise, create adjustment.

     C                   other

     *      Inactivate current record.

     C                   eval      lrexcd      = 'INVCNT'
     C                   exsr      lhinactivate2

     *      Create new record.

     C                   exsr      lhcreate
     C                   leave

     C                   endsl

     C                   enddo

     C                   endsr

500cA*----------------------------------------------------------------
500cA*----------------------------------------------------------------
500cA*                     DRI SUBROUTINES
500cA*----------------------------------------------------------------
500cA*----------------------------------------------------------------

500cA*----------------------------------------------------------------
500cA*  clr$slot  Clear $slot data structure fields
500cA*----------------------------------------------------------------
500cA
500cAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr
500cA
500cA*----------------------------------------------------------------
500cA*  zzzdriclose   Close any open files or programs.
500cA*----------------------------------------------------------------
500cA
500cAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   endsr
500cA
500cA*----------------------------------------------------------------
500cA*  zzzdricop  Call DRICOP
500cA*----------------------------------------------------------------
500cA
500cAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
     C**                 if        zmsflag
     C**                 exsr      zm0105s
     C**                 else
     C**                 exsr      zm0105
     C**                 endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C**                 if        zmsflag
     C**                 exsr      zm0001s
     C**                 else
     C**                 exsr      zm0001
     C***                exsr      zzerrind
     C**                 endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
