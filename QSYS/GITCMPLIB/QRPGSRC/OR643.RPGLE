      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR643     Create AMP-pick slots and AMPXREF records.
     *  21 July 2015
     *  Nancy Koelz
     *
     *  Revisions
     *
     *    07/21/15  NLK  7.00
     *      - Created
     *
700aA*    09/22/15  NLK  7.00a
     *      - added extra check digit and zone fields
     *
700bA*    11/05/15  NLK  7.00b
     *      - chg ampxref2 to key on DelvRt field plus clear qty flds
     *
700cA*    11/10/15  NLK  7.00c
     *      - revised logic now clear delv rt label #
     *
700dA*    02/04/16  DAS  7.00d
     *      - Revised to create random check digit
     *      - Added field axastgcod to file AMPREF
     *      - Revised to populate axastgcod
     *
700eA*    03/10/16  DAS  7.00e
     *      - Revised to use same loc/lvl for all records.
     *
720fA*    08/24/18  DAS  7.20f
     *      - Revised how pallet generation is checked. DD2 may use
     *        generations greater than 3.
     *      - Added subroutine GetGenInfo and gGen fields to go with it.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - xxxxxx
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes - AMP is Advanced Merge Pick (similar to PrePick/PrePull
     *    Difference between AMP and PrePick
     *    - AMP doesnt know the deliver rt
     *               PrePick must be delv rt that will be sent later
     *    - AMP picked items are picked individually
     *               PrePick Plt is moved as a whole onto delv rt truck
     *    - AMP slots are user defined in new STAGEAMP file
     *               PrePick slots are in aisle PRE
     *
     *    ORDHM misc field HMMSC4:13 is the AMP flag=MUST be Y to proceed
     *      -and- Stage Area will be 14-16, if no value then use the
     *      default record value.
     *
     *    Type A, send DRISLOT the aisle (from STAGEAMP)
     *    Type D, send DRISLOT the aisle & location (from STAGEAMP)
     *
     *    OR605 calls this program and checks for the 'Y'.  OR605 doesn't
     *       carry this value so we must perform this CALL to see value.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Flabel32c  if   e           k disk
700dMFordhm     if   e           k disk
     Fstageamp  if   e           k disk
     Fstageamp1 if   e           k disk    rename(sarec:sarec1)
     Fampxref2  uf a e           k disk    rename(axrec:axrec2)
     Fampxref3  uf a e           k disk    rename(axrec:axrec3)

     *----------------------------------------------------------------
     *  Dakota Client IDs
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     D                 ds
     D  client                 1     10
     D  cliloc                11     20
     D @getcl          c                   const('GETCLIENT')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.drislot

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
     D lastplid        s                   like(lbpal#)
     D ampArea         s              3  0
     D chkDgt          s              3  0
700eAD sv_loc          s                   like($slloc)
700eAD sv_rlvl         s                   like($slrlvl)
720fAD gGen            s              1  0
720fAD gGenTruck       s               n
720fAD gGenMerge       s               n
720fAD gGenOverflow    s               n
720fAD gGenTruckExt    s               n
720fAD gPltId          s                   like(lbpal#)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CREATE  - Create ampxref records and AMP slots.
     *              *DELETE  - Delete ampxref records and AMP slots.
     *      $PWHSE  Warehouse
     *      $prtid  AMP route id
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
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *inlr = *on

     *  Get out if proper command not sent in.

     C                   if        $pcmd <> '*CREATE'
     C                             and $pcmd <> '*DELETE'
     C                   return
     C                   endif

     *  First, delete any existing ampxref records and AMP slots.
     *  If an error occured in this program,
     *    this will clean up everything that was previously created
     *    before trying again.

     C                   exsr      dltAMPPick

     C                   if        $pcmd = '*DELETE'
     C                   exsr      rmvNrmInfo
     C                   endif

     *  Whip thru label recs for the route and create AMP-pick slots

     C                   if        $pcmd = '*CREATE'
     C                   exsr      crtAMPPick
     C                   endif

     *  Bye, Bye

     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *inzsr  -  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client
     C                   parm                    cliloc
     *

     *  Define route id key for LABEL32c file

     C     keyRtid       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

700dA*  Define key for ORDHM file.
700dA
700dAC     keyohm        klist
700dAC                   kfld                    lbwhse
700dAC                   kfld                    lbord

     C                   endsr

     *----------------------------------------------------------------
     *  crtAMPPick      Create AMP-pick slots
     *----------------------------------------------------------------

     C     crtAMPPick    begsr

     *  Loop through all labels for route in tran# order

     C                   eval      first = *on
     C                   eval      lastplid = *loval
     C     keyRtid       setll     label32c

     C                   dow       forever = forever
     C     keyRtid       reade     label32c
     C                   if        %eof
     C                   leave
     C                   endif
720fAC                   eval      gPltId = lbpal#
720fAC                   exsr      GetGenInfo

     *      Only work with generation 1 pallets

720fDC**                 if        lbpal# > 20000
720fMC                   if        not gGenTruck
     C                   iter
     C                   endif

700dA*      Get out if not AMP route
700dA*      Note, all orders for route should have AMP flag
700dA
700dAC     keyohm        chain     ordhm
700dAC                   if        not %found(ordhm)
700dAC                             or %subst(hmmsc4:13:1) <> 'Y'
700dAC                   leavesr
700dAC                   endif

700dA*      Get Staging Area information
700dA
700dAC                   exsr      GetStageArea

     *      Create AMP slots

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = itwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = lbitem
     C                   eval      $slaislu = *on
     C                   eval      $sllocu  = *on
     C                   eval      $slrlvlu = *on
700eA
700eA*    For the first label, call DRISLOT with lvl set to 0.
700eA*    For subsequent labels, leave loc and lvl that was
700eA*    returned from the first call.
700eA
700eAC                   if        first
700eAC                   if        satype = 'D'
700eAC                   eval      sv_loc = saloc
700eAC                   else
700eAC                   eval      sv_loc = 0
700eAC                   endif
700eAC                   eval      sv_rlvl = 0
700eAC                   eval      first = *off
700eAC                   endif
700eA
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%CRTAMP'
     C                   eval      $drisys2upd = 'D'
     C                   eval      $slaisl = saaisl
700eDC**                 if        satype = 'D'
700eDC**                 eval      $slloc  = saloc
700eDC**                 else
700eDC**                 eval      $slloc  = 0
700eDC**                 endif
700eMC                   eval      $slloc = sv_loc
700eDC**                 eval      $slrlvl = 0
700eMC                   eval      $slrlvl = sv_rlvl
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   endif
700eA
700eA*    If handstack is 'ZZ', then set level to zero so
700eA*    next time around DRISLOT will get next level to use.
700eA
700eAC                   if        $slhand = 'ZZ'
700eAC                   eval      sv_rlvl = 0
700eAC                   endif

     *      Create AMPXREF record

     C                   exsr      crtAMPXREF

     *      Abort on DRISLOT error.

     C                   if        drierr = *on
     C                   leave
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  crtAMPXREF   Create AMPXREF record
     *----------------------------------------------------------------

     C     crtAMPXREF    begsr
     C                   clear                   axrec3
     C                   eval      axwhse = $pwhse
     C                   eval      axcust = ohcust
     C                   eval      axcord = ohcord
     C                   eval      axitem = lbitem
     C                   eval      axartid = $prtid
     C                   eval      axaord = lbord
     C                   eval      axaseq = lbseq
     C                   eval      axatrn# = lbtrn#
     C                   eval      axalbl# = lblbl#
     C                   eval      axawhdp = itwhdp
     C                   eval      axaaisl = $slaisl
     C                   eval      axaloc = $slloc
     C                   eval      axarlvl = $slrlvl
     C                   eval      axahand = $slhand
     C                   eval      axadisp = $sldisp
700dAC                   eval      axastgcod = sacode
700dDC**                 eval      chkDgt = chkDgt + 1
700dDC**                 eval      axachkdgt = chkDgt

700dAC                   call      'RANDOM2'
700dAC                   parm                    $rseed            9 9
700dAC                   parm      101           $rmin             6 0
700dAC                   parm      999           $rmax             6 0
700dAC                   parm                    $rnum             6 0
700dA
700dAC                   eval      axachkdgt = $rnum

     C                   eval      axaboxid = 0
     C                   eval      axaboxqty1 = 0
     C                   eval      axaboxqty2 = 0
     C                   eval      axaboxqty3 = 0
     C                   eval      axdrtid = *blanks
     C                   eval      axdord = 0
     C                   eval      axdseq = 0
     C                   eval      axdtrn# = 0
     C                   eval      axdlbl# = 0
     C                   eval      axdqty1 = 0
     C                   eval      axdqty2 = 0
     C                   eval      axdqty3 = 0

     C                   write     axrec3

     C                   endsr

      *----------------------------------------------------------------
     *  dltAMPPick      Delete ampxref records and AMP slots
     *----------------------------------------------------------------

     C     dltAMPPick    begsr

      /free

         setll ($pWhse: $pRtid) ampxref3;

         dow forever = forever;

           reade ($pWhse: $pRtid) ampxref3;

           if %eof(ampxref3);
             leave;
           endif;

           // Delete corresponding AMP slot.

           exsr clr$slot;
           $slwhseu = *on;
           $slwhse  = axwhse;
           $slwhdpu = *on;
           $slwhdp  = axawhdp;
           $sldispu = *on;
           $sldisp  = axadisp;

           $dricommand = '*SLOT';
           $drisubcmd  = '%DELETE';
           $drisys2upd = 'D';
           exsr zzzdricop;

           // Delete ampxref record.

           delete axrec3;

         enddo;

      /end-free

     C                   endsr

700dA*----------------------------------------------------------------
700dA*  GetStageArea    Get staging area code
700dA*----------------------------------------------------------------
700dA
700dAC     GetStageArea  begsr

      /free

         // First, get area code from Host and verify

         monitor;
           ampArea = %dec(%subst(hmmsc4:14:3):3:0);
           chain (lbwhse: ampArea) stageamp;
           if %found(stageamp);
             leavesr;
           endif;
         on-error;
         endmon;

         // If area code not sent or wasn't found, get default

         setll (lbwhse) stageamp1;
         reade (lbwhse) stageamp1;
         if not %eof(stageamp1);
           leavesr;
         endif;

         // If a default is not defined, use first code.

         setll (lbwhse) stageamp;
         reade (lbwhse) stageamp;
         if %eof(stageamp);
           clear sarec;
         endif;

      /end-free

     C                   endsr

     *----------------------------------------------------------------
     *  rmvNrmInfo      Remove Normal info from ampxref records
     *----------------------------------------------------------------
700bA*  added clearing qty fields plus corrected KEYS in lf ampxref2
700cA*  added clearing delv rt lbl# axdlbl#

     C     rmvNrmInfo    begsr

      /free

         setll ($pWhse: $prtid) ampxref2;

         dow forever = forever;

           reade ($pWhse: $prtid) ampxref2;

           if %eof(ampxref2);
             leave;
           endif;

           clear axdrtid;
           clear axdord;
           clear axdseq;
           clear axdqty1;
           clear axdqty2;
           clear axdqty3;
           clear axdlbl#;

           update axrec2;

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
700eAC                   eval      sv_loc = $slloc
700eAC                   eval      sv_rlvl = $slrlvl
     C                   endsl

     C     enddricop     endsr

720fA*----------------------------------------------------------------
720fA*  GetGenInfo    Get pallet generation info
720fA*----------------------------------------------------------------
720fAC     GetGenInfo    begsr
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


