      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR642     Create PRE-pick slots and PREXREF records.
     *  04 November 2010
     *  Retha Davis
     *
     *  Revisions
     *
620 A*    11/04/10  RBD  6.20
     *      - Created.
     *
620aA*    11/29/10  DAS  6.20a
     *      - Revised to only work with generation 1 pallets
     *      - Revised to read all label records, including 'M'.
     *      - Revised to abort upon error from DRISLOT.
     *      - Added item fields to file label76.
     *      - Using itwhdp instead of lbwhdp when calling DRISLOT.
     *        Re: 'M' label records contain the zone in lbwhdp.
     *
620bA*    12/01/10  DAS  6.20b
     *      - Added $pcmd parameter.
     *      - Revised to always delete and existing prexref records
     *        and corresponding PRE slots.
     *
640aA*    02/17/11  JCJ  6.40a
     *      - Enh: add client code.
     *      - Fix: only generate PRE slots when client is in
     *        authorization list.
     *
650aA*    12/26/13  RBD  6.50a
     *      - Recompiled only, LABEL76 changed.
     *
720aA*    08/24/18  DAS  7.20a
     *      - Revised how pallet generation is checked. DD2 may use
     *        generations greater than 3.
     *      - Added subroutine GetGenInfo and gGen fields to go with it.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - CDI-LLC
     *
CDI A*    09/25/15  MLB  CDI
     *      - Enh: Add CDI to authorized clients to run Pre-pull
     *        processing.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Flabel76   if   e           k disk
620bAFprexref2  uf a e           k disk    rename(pxrec:pxrec2)
620bAFprexref3  uf a e           k disk    rename(pxrec:pxrec3)
620bDF*rexref   o  a e           k disk

     *----------------------------------------------------------------
640aA*  Dakota Client IDs
640aA*
640aA /copy qcopysrc,id#coastal
640aA*----------------------------------------------------------------
640aA*  Customer id
640aA*
640aAD                 ds
640aAD  client                 1     10
640aAD  cliloc                11     20
640aAD @getcl          c                   const('GETCLIENT')
CDI A /copy qcopysrc,id#cdi

620bA*----------------------------------------------------------------
620bA* Function prototypes.
620bA*----------------------------------------------------------------
620bA
620bA /copy qcopysrc,p.drislot

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#SLOT
     D savever#        s                   like($slver#)

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
     *  Variables
     *----------------------------------------------------------------

     D drierr          s              1
     D first           s               n
     D forever         s               n
720aAD gGen            s              1  0
720aAD gGenTruck       s               n
720aAD gGenMerge       s               n
720aAD gGenOverflow    s               n
720aAD gGenTruckExt    s               n
720aAD gPltId          s                   like(lbpal#)
     D lastplid        s                   like(lbpal#)
     D sv_aisl         s                   like($slaisl)
     D sv_loc          s                   like($slloc)
     D sv_rlvl         s                   like($slrlvl)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
620bA*      $PCMD   *CREATE  - Create prexref records and PRE slots.
620bA*              *DELETE  - Delete prexref records and PRE slots.
     *      $PWHSE  Warehouse
     *      $PRTID  Route id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
620bAC                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *inlr = *on
620bA
620bA*  Get out if proper command not sent in.
620bA
     C                   select
640aAC                   when      client <> coastalsunbelt
CDI AC                             and client <> cdi
620bAC                   return
     C                   other
620bAC                   if        $pcmd <> '*CREATE'
620bAC                             and $pcmd <> '*DELETE'
620bAC                   return
620bAC                   endif
     C                   endsl
620bA
620bA*  First, delete any existing prexref records and PRE slots.
620bA*  If an error occured in this program,
620bA*    this will clean up everything that was previously created
620bA*    before trying again.
620bA
620bAC                   exsr      dltPREPick
620bA
620bAC                   if        $pcmd = '*DELETE'
620bAC                   exsr      rmvNrmInfo
620bAC                   endif

     *  Whip thru label recs for the route and create PRE-pick slots

620bAC                   if        $pcmd = '*CREATE'
     C                   exsr      crtPREPick
620bAC                   endif

     *  Bye, Bye

     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *inzsr  -  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr
640aA*
640aA* Get client id.
640aA*
640aAC                   call      @getcl
640aAC                   parm                    client
640aAC                   parm                    cliloc
640aA*

     *  Define route id key for LABEL76 file

     C     keyRtid       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     C                   endsr

     *----------------------------------------------------------------
     *  crtPREPick      Create PRE-pick slots
     *----------------------------------------------------------------

     C     crtPREPick    begsr

     *  Loop through all labels for route in tran# order

     C                   eval      first = *on
     C                   eval      lastplid = *loval
     C     keyRtid       setll     label76

     *    If eof or not a PRE-pick route, you're done

     C                   dow       forever = forever
     C     keyRtid       reade     label76
     C                   if        %eof
     C                             or %subst(ohmisc:17:1) <> 'Y'
     C                   leave
     C                   endif
620aA
620aA*      Only work with generation 1 pallets
620aA
720aAC                   eval      gPltId = lbpal#
720aAC                   exsr      GetGenInfo
720aDC**                 if        lbpal# > 20000
720aMC                   if        not gGenTruck
620aAC                   iter
620aAC                   endif
620aD **
620aD **   Only read O and B label records
620aD **
620aDC**                 if        lbtype <> 'O'
620aDC**                           and lbtype <> 'B'
620aDC**                 iter
620aDC**                 endif

     *    Create PRE-pick slots

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
620aDC**                 eval      $slwhdp  = lbwhdp
620aMC                   eval      $slwhdp  = itwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = lbitem
     C                   eval      $slaislu = *on
     C                   eval      $sllocu  = *on
     C                   eval      $slrlvlu = *on

     *    For the first label, call DRISLOT with aisle set to PRE
     *    and loc and lvl set to 0.  For subsequent labels, leave
     *    the loc and lvl that was returned from the first call.
     *    Notice below, when pallet changes, set level to 0.

     C                   if        first
     C                   eval      sv_aisl = 'PRE'
     C                   eval      sv_loc  = 0
     C                   eval      sv_rlvl = 0
     C                   eval      first = *off
     C                   endif

     *    When pallet changes, set level to 0.

     C                   if        lastplid <> lbpal#
     C                   eval      sv_rlvl = 0
     C                   eval      lastplid = lbpal#
     C                   endif

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%CRTPRE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      $slaisl = sv_aisl
     C                   eval      $slloc  = sv_loc
     C                   eval      $slrlvl = sv_rlvl
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   endif

     *      Create PREXREF record

     C                   exsr      crtPREXREF
620aA
620aA*      Abort on DRISLOT error.
620aA
620aAC                   if        drierr = *on
620aAC                   leave
620aAC                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  crtPREXREF   Create PREXREF record
     *----------------------------------------------------------------

     C     crtPREXREF    begsr
     C                   clear                   pxrec3
     C                   eval      pxwhse = $pwhse
     C                   eval      pxhrte = rhrte
     C                   eval      pxhord = ohcord
     C                   eval      pxprte = $prtid
     C                   eval      pxpord = ohord
     C                   eval      pxpseq = lbseq
     C                   eval      pxitem = lbitem
620aDC**                 eval      pxsdep = lbwhdp
620aMC                   eval      pxsdep = itwhdp
     C                   eval      pxdisp = $sldisp
     C                   eval      pxlbl# = lblbl#
     C                   eval      pxplid = lbpal#
     C                   eval      pxpal# = pspal#
     C                   eval      pxunld = psunld
     C                   eval      pxtrn# = lbtrn#
     C                   eval      pxcpyf = 'N'
     C                   eval      pxnrte = *blanks
     C                   eval      pxnord = 0
     C                   eval      pxnseq = 0
     C                   eval      pxrtnc = *blanks
     C                   if        drierr = *on
     C                   eval      pxsdep = *blanks
     C                   eval      pxdisp = *blanks
     C                   eval      pxrtnc = $drireturn
     C                   endif
     C                   write     pxrec3
     C                   endsr

620bA*----------------------------------------------------------------
620bA*  dltPREPick      Delete prexref records and PRE slots
620bA*----------------------------------------------------------------
620bA
620bAC     dltPREPick    begsr

      /free

         setll ($pWhse: $pRtid) prexref3;

         dow forever = forever;

           reade ($pWhse: $pRtid) prexref3;

           if %eof(prexref3);
             leave;
           endif;

           // Delete corresponding PRE slot.

           exsr clr$slot;
           $slwhseu = *on;
           $slwhse  = pxwhse;
           $slwhdpu = *on;
           $slwhdp  = pxsdep;
           $sldispu = *on;
           $sldisp  = pxdisp;

           $dricommand = '*SLOT';
           $drisubcmd  = '%DELETE';
           $drisys2upd = 'D';
           exsr zzzdricop;

           // Delete prexref record.

           delete pxrec3;

         enddo;

      /end-free

     C                   endsr

620bA*----------------------------------------------------------------
620bA*  rmvNrmInfo      Remove Normal info from prexref records
620bA*----------------------------------------------------------------
620bA
620bAC     rmvNrmInfo    begsr

      /free

         setll ($pWhse: $pRtid) prexref2;

         dow forever = forever;

           reade ($pWhse: $pRtid) prexref2;

           if %eof(prexref2);
             leave;
           endif;

           clear pxnrte;
           clear pxnord;
           clear pxnseq;

           update pxrec2;

         enddo;

      /end-free

     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   if        $drireturn <> '*OK'
     C                   eval      drierr = *on
     C                   endif

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      sv_loc = $slloc
     C                   eval      sv_rlvl = $slrlvl
     C                   endsl

     C     enddricop     endsr

720aA*----------------------------------------------------------------
720aA*  GetGenInfo    Get pallet generation info
720aA*----------------------------------------------------------------
720aAC     GetGenInfo    begsr
      /free

        gGen = 1;
        gGenTruck = *off;
        gGenMerge = *off;
        gGenOverflow = *off;
        gGenTruckExt = *off;

        select;

          when gPltId < 20000;
            gGen = 1;
            gGenTruck = *on;

          when gPltId < 30000;
            gGen = 2;
            gGenMerge = *on;

          when gPltId < 40000;
            gGen = 3;
            gGenMerge = *on;

          when gPltId < 50000;
            gGen = 4;

          when gPltId < 60000;
            gGen = 5;
            gGenTruck = *on;
            gGenOverflow = *on;

          when gPltId < 70000;
            gGen = 6;
            gGenTruck = *on;
            gGenTruckExt = *on;

        endsl;
      /end-free
     C                   endsr


