      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  IT223   Reactivate a license into a slot
     *  09 July  2020
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740 A*    07/09/20  LMC  7.40
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
     D @getcl          c                   const('GETCLIENT')


     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#slot
      /COPY *libl/qcopysrc,C#item
      /COPY *libl/qcopysrc,C#license
     D saveVer#        s                   like($slver#)


     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.cvtqty

     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *


     D act             s              3
     D a58             s             58
     D append1         s              1
     D append5         s              5
     D bot             s              1
     D cancel          s              1
     D chk4err         s               n
     D ckexpd          s                   like(today)
     D ckentd          s                   like(today)
     D ck4err          s              1
     D clear           s              5  0
     D comand          s              5  0
     D cqerm           s             60
     D cqqty1          s              7  0
     D cqqty2          s              7  0
     D cqqty3          s              7  0
     D cqrtn           s              8
     D cqum1           s              2
     D cqum2           s              2
     D cqum3           s              2
     D cqustr          s             17
     D drierr          s              1
     D drizm           s              1
     D dsplyd          s              2  0
     D dspwin          s              4
     D e               s              2  0
     D first           s               n
     D fmentd          s              8  0
     D fmexpd          s              8  0
     D forceb          s              1
     D forevr          s              1
     D fvslot          s              1
     D goback          s              2  0
     D hasvs           s              1
     D help            s              5  0
     D hldvsl          s             12
     D lastrrn         s                   like(recno)
     D msgk            s              4  0
     D msgtyp          s              8
     D nomore          s              1
     D noslt           s              1
     D nxtscr          s              3
     D offlag          s              1
     D optcnt          s              3  0
     D optln1          s             75
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D partial         s               n
     D recno           s              4  0
     D recpos          s                   like(recno)
     D redspl          s              1
     D refrsh          s              1
     D rtvslt          s              4
     D scannedSlot     s               n
     D sclear          s              1
     D sortorder1      s             10    inz(' ')
     D stop            s              1
     D sqlgroup        s                   like(sqlorder)
     D t1              s              7  0
     D t2              s              7  0
     D t3              s              7  0
     D t#task          s              6
     D tempa2          s              2
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D today           s              8  0
     D top             s              1
     D topick          s              5  0
     D trndte          s              8  0
     D trntim          s              6  0
     D tstdte          s                   like(today)
     D view            s              1  0
     D woavl1          s              5  0
     D worqty          s              5  0
     D woslt           s             12
     D w1aqty10        s             10    inz(' ')
     D w1ldspFull      s             15
     D w1ldspFullNone  s             15    inz('-------')
     D licLen          s              3  0
     D zmsflag         s               n
     D LT107_Repack    s               n
     d lcnsScan        s               n
     D SubfilePage     s              1  0
     D  $tinlic#       s             15

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     D md              s               z

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D llrec         e ds                  extname(liclog) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  SQL fetch fields
     *----------------------------------------------------------------



     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $iWhse   Warehouse
     *      $iDept   Department
     *      $ilcns   License
     *      $idisp   Display
     *
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $iWhse            3 0
     C                   parm                    $iDept            5
     C                   parm                    $ilcns           15
     C                   parm                    $idisp           12
      **
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     c                   exsr      zzinz2
      /free
        // now get last liclog record
        exec sql select * into :llrec
                 from liclog
                  where llolcns = :$ilcns
                 Order by lladdts desc
                 fetch first row only;
        if sqlstt = sqlSuccess;
          if llexpd = 0;
            $liToExpD = 0;
          else;
            $liToExpD = llexpd;
          endif;

          if llentd = 0;
            $liToEntD = 0;
          else;
            $liToEntD = llentd;
          endif;
        endif;
      /end-free
     C                   exsr      addsltitm
     c                   eval      $idisp = $sldisp
     *
     *   Do some clean up before leaving.
     *
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   endsr
     *
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  ZZGETITEM     Get Item Information
     *----------------------------------------------------------------

     C     zzgetitem     begsr

     *  Get item.

     C                   exsr      clr$item
     C*                  eval      $itwhse  = $iwhse
     C*                  eval      $ititem  = $iItem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   eval      error = *on
     C                   endif

     C     endgetitem    endsr




     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
     *
     *   Get employee options.
     *
     C                   call      'GETUSER'
     C                   parm      #user         e$code           10
     C                   parm                    e$whse            3 0
     C                   parm                    e$emp#            5 0
     C                   parm                    e$fnam           15
     C                   parm                    e$init            1
     C                   parm                    e$lnam           20
     C                   parm                    e$whdp            5
     C                   parm                    e$styp            1
     C                   parm                    e$shft            6
     C                   parm                    e$crew            6
     C                   parm                    e$nhrs            3 1
     C                   parm                    e$rtn             8
     C                   parm                    e$bpu             1
     C                   parm                    e$lng             2
     C                   if        e$rtn <> '*OK'
     C                   eval      e$lng = 'EN'
     C                   endif
     *
     *
     *   Get item description.
     *
     C*                  exsr      zzgetitem
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
     C                   endsr


     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     c                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      drierr = *on

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      drierr = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr


     *----------------------------------------------------------------
     *
     *  ADDSLTITM  Add item to the slot
     *
     C     addsltitm     begsr
     *

     C                   eval      $tinlic# = $ilcns

     *  Put qty in slot.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $iwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $iDEPT
     C                   eval      $sldispu = *on
     c                   eval      $sldisp = $idisp
     C                   eval      $slstatu = *on
     C                   eval      $slstat = 'A '

     C                   eval      $slentdu = *on
     C                   eval      $slentd  = $liToEntD
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd  = $liToExpD

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = llsitem
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'LAC'
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = $tinlic#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'T'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'Temp'
     C                   if        $tinlic# <>  ' '
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = $tinlic#
     C                   endif

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%QTY2PUT0'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
