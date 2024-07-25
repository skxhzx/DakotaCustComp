      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  DRILICHIST  Dakota realtime interface - License history
     *  06 April 2004
     *  Dave Sommerville
     *
417 A*    04/06/04  DAS  4.17
     *      - Created
     *
500 A*    08/31/04  DAS  5.00
     *      - Added subcommands *MISSINGLP, *WRONGLOC, *RTNALL
     *      - Revised UPDRPL* to have the original lic# sent in the flic
     *        field and the new lic# send in the lcns field. Re: a
     *        pushback partial replenishment needs to change the lic#.
     *      - Added file LICHIST5.
     *      - Added new routine MOVBACKF.
     *      - Revise PULL routine to first do a MOVBACKF.
     *      - Remove DESCEND from LICHIST3 file.
     *      - Split UPDRPL* routines into floor/slot routines.
     *
500aA*    01/02/05  DAS  5.00a
     *      - Initialized LRFLIC in UPDPUT routine.
     *
500bA*    01/08/05  DAS  5.00b
     *      - Some routines not getting current stamp.
     *      - Revised ADDLIC routine to use ZZCHKLCNS.
     *      - Added dsp fields to UPDRPL* routines.
     *
500cA*    01/10/05  DAS  5.00c
     *      - Added *UNDORPL and *UNDOTFR.
     *
500dA*    01/12/05  DAS  5.00d
     *      - Removed CLSRPLP/T and CLSTFRP/T routines.
     *      - Revised CLSRPL/TFR to call CLSPUT routines.
     *      - Removed UPDTFRP/T routines.
     *      - Revised UPDTFR to call UPDRPL routines.
     *
500eA*    01/13/05  DAS  5.00e
     *      - Added fields LRFBASE, LRTBASE, LRFITMS, LRTITMS,
     *        LRFITYP, LRTITYP.
     *      - Renamed LRACFL to LRSTAT.
     *      - Did above changes to $LR fields.
     *      - Added loging to get tracking options if necessary.
     *
500fA*    01/20/05  DAS  5.00f
     *      - Added fields LRCTL#, LRCTLSEQ#.
     *        These fields are used to group license plates that have
     *        the same item and same slot.
     *
500gA*    01/24/05  DAS  5.00g
     *      - Changed key of LICHIST5. Re: 9/5/04 change to LICHIST3
     *        made keys identical.
     *      - Changed current references of LICHIST5 to LICHIST3 (RTNALL).
     *      - Added commands *CHK4EXIST and *MERGE.
     *
500hA*    03/06/05  DAS  5.00h
     *      - Revised undorpl to only update record if license is on the
     *        floor or in transit.
     *
500iA*    03/06/05  DAS  5.00i
     *      - Added command *ADJUST.
     *
500jA*    03/30/05  DAS  5.00j
     *      - Revised routine undorpl to return To information.
     *
500kA*    04/15/05  DAS  5.00k
     *      - Fix: Some LRF fields not being initialized from LRT fields.
     *
500lA*    04/19/05  DAS  5.00l
     *      - Revised routine PUSH to reverse push if a floor pallet was
     *        not updated.
     *      - Revised routine PULL to reverse pull if a slot pallet was
     *        not updated.
     *
500mA*    04/24/05  DAS  5.00m
     *      - Revised some routine to default To item fields to
     *        From item fields when info not sent in.
     *
500nA*    04/29/05  DAS  5.00n
     *      - Revised *UPDRPLT/*UPDTFRT to use UPDRPLP routine. Re: If
     *        entire qty is put into transit we want to leave a zero qty
     *        record behind in case the item is returned to the same slot.
     *      - Inactivated *MERGE command and routine.
     *      - Created routine LOOK4MATCH.
     *      - Revised CLSPUTP/T routines to handle a merge situation.
     *
500oA*    04/30/05  DAS  5.00o
     *      - Split C#LICHIST into two data structures because of 512 limit
     *      - Added second data parameter to program.
     *      - Added fields $lrnorm1/2/3 to C#LICHIST.
     *      - Revised CLSPUTP routine to use new fields.
     *
500pA*    05/02/05  DAS  5.00p
     *      - Added commands *RMVZERO, *RMVZRTN.
     *      - Added routine SCRUNCH.
     *
500qA*    05/06/05  DAS  5.00q
     *      - Initialized lrexcd before writting new records.
     *
500rA*    05/13/05  DAS  5.00r
     *      - Revised pushpat routine to not move floor pallets.
     *
500sA*    06/30/05  DAS  5.00s
     *      - Added fixbrkdn routine.
     *
500tA*    07/01/05  DAS  5.00t
     *      - Revised addlic routine to check for merge situation.
     *
500uA*    07/06/05  DAS  5.00u
     *      - Fixed bug in fixbrkdn routine.
     *      - Revised getitem to use "lr" fields instead of "$lr" fields.
     *
500vA*    09/28/05  DAS  5.00v
     *      - Revised look4match routine to only look for matches when
     *        the "To" code is an 'S' (slot).
     *      - Revised updrplpfloor to update node correctly.
     *      - Revised updrplpother to update node correctly.
     *
600 A*    04/25/08  DAS  6.00  P#00045
     *      - License Tracking
     *
600aA*    07/07/08  DAS  6.00a
     *      - Added *UPDTRNLBL command.
     *
600bA*    07/12/08  DAS  6.00b
     *      - Added calls to bfcphrase.
     *
600cA*    10/25/08  DAS  6.00c
     *      - Added calls to wrtliclog.
600dA*    08/03/09  JCJ  6.00d
     *      - Removed call to wrtliclog.  (Not used per DAS)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V5R1M0)
     *
     *    CRTPGM PGM(*) MODULE(*) ACTGRP(*CALLER)
     *
     *----------------------------------------------------------------

500eA*----------------------------------------------------------------
500eA* Tracking options
500eA*
500eA* Values for trackpos fields:
500eA*
500eA*    trackpos     Track slot pallet position (Y/N)
500eA*
500eA*    trackposmrg  Putaway merge option
500eA*                 1 = Only ask for pallet position.
500eA*                 2 = Direct user step by step.
500eA*
500eA*    trackposrtn  Return pallet option
500eA*                 1 = Assume user returns pallets in LOFI order.
500eA*                 2 = Direct user step by step.
500eA*
500eA* Split Putaway Quantity Options (trackpsplit)
500eA*
500eA*   This option comes into play when a user is putting a partial
500eA*   quantity into a slot. This could either be during Putaway,
500eA*   Replenishment or Transfer.
500eA*
500eA*   1  =  LP goes with first quantity put into a slot.
500eA*   2  =  LP goes with last quantity put into a slot.
500eA*   3  =  Ask user.
500eA*
500eA* Split Transfer Quantity Options (tracktsplit)
500eA*
500eA*   This option comes into play when a user is doing a partial
500eA*   quantity transfer and will identify how to deal with the
500eA*   license plate for the quantity that stays in the From slot
500eA*   vs. the quantity that is being transfered.
500eA*
500eA*   1  =  LP stays with remaining quantity in From slot.
500eA*   2  =  LP goes with partial quantity being transfered.
500eA*   3  =  Ask user.
500eA*
500eA*----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  - Because the Sys2Upd parameter is not being sent into this
     *    program, another method needed to be created to determine
     *    if the call to this program was initiated by Dakota or by
     *    the Host system. Therefore, the first character of the
     *    subcommand is used to make this determination. If the
     *    character is a '%', then we assume that Dakota initiated
     *    the call. Otherwise, we assume that the Host system
     *    initiated the call.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub-Command Notes
     *
     *      *OPEN        Open program and return.
     *
     *      *CLOSE       Close program with *INLR = *ON
     *
     *      *ADDLIC      Add new lot/license plate tracking record.
500iA*      *ADJUST      Adjust license quantity.
417dA*      *ASKIN       Ask for lic when putting item into slot?
417dA*      *ASKOUT      Ask for lic when taking item out of slot?
500gA*      *CHK4EXIST   Check if item exists in base slot.
     *      *CLSPUTD     Close Directed putaway tracking record.
     *      *CLSPUTM     Close Manual putaway tracking record.
417iA*      *CLSPUTP     Close putaway - Partial qty.
417iA*      *CLSPUTT     Close putaway - Entire qty.
     *      *CLSRPLP     Close Replenishment - Partial qty.
     *      *CLSRPLT     Close Replenishment - Entire qty.
     *      *CLSTFRP     Close Slot transfer - Partial qty.
     *      *CLSTFRT     Close Slot transfer - Entire qty.
417dA*      *CRTNF       Create new *NF license tracking record.
417dA*      *CRTSU       Create new *SU license tracking record.
     *      *GETLIC#     Retrieve license plate for specific slot.
     *      *GETLOT#     Retrieve lot number for specific slot.
417bA*      *GETSLOT     Retrieve slot for specific license.
500gA*      *MERGE       Merge multiple records for specific item/slot.
500  *      *MISSINGLP   LP is missing (could not be verified)
417bA*      *MOVBACK     Move back items located in pushback slot
417bA*                   to make room for pallet in front.
417cA*      *MOVEFWD     Move items forward located in pushback slot
417cA*                   since pallet removed from slot.
     *      *NEWLIC#     Verify license plate doesn't exist.
     *      *NEWLOT#     Verify lot number doesn't exist.
417hA*      *PULL        Pull license out of slot.
417hA*      *PUSH        Push license into slot.
417iA*      *PUSHPAP     Push putaway into slot - Partial qty.
417iA*      *PUSHPAT     Push putaway into slot - Entire qty.
500pA*      *RMVZERO     Remove (Inactivate) record for a specific slot
500pA*                   if all quantities are zero.
500pA*      *RMVZRTN     Remove (Inactivate) record for a specific slot
500pA*                   if all quantities are zero, then do a RTNALL.
500 A*      *RTNALL      Return all floor pallets back to slot.
     *      *UNDOPUT     Putaway transaction canceled.
500cA*      *UNDORPL     Replenishment transaction canceled.
500cA*      *UNDOTFR     Transfer transaction canceled.
417fA*      *UPDLOC      Update pallet location in slot.
417iA*      *UPDLOC0     Update pallet position to 0.
     *      *UPDPUT      Update original lot/license plate tracking
     *                   record, Create new lot/license plate tracking
     *                   record to show in transit.
     *      *UPDRPLP     Update replenishment - Partial qty.
     *      *UPDRPLT     Update replenishment - Entire qty.
     *      *UPDTFRP     Update slot transfer - Partial qty.
     *      *UPDTFRT     Update slot transfer - Entire qty.
600aA*      *UPDTRNLBL   Update tran#/lbl# for license
      *
      *      *VERIFYADD        Do "*ADD" verification without update.
      *      *VERIFYCHG        Do "*CHANGE" verification without update.
      *      *VERIFYDEL        Do "*DELETE" verification without update.
      *
     *      *WRONGLOC    LP found at wrong location.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flichist   uf a e           k disk    usropn
     F                                     infds(file1ds)

     Flichist1  uf a e           k disk    usropn
     F                                     rename(lrrec:lrrec1)
     F                                     infds(file2ds)

     Flichist2  uf   e           k disk    usropn
     F                                     rename(lrrec:lrrec2)
     F                                     infds(file3ds)

     Flichist3  uf a e           k disk    usropn
     F                                     rename(lrrec:lrrec3)
     F                                     infds(file4ds)

500 AFlichist5  if   e           k disk    usropn
500 AF                                     rename(lrrec:lrrec5)
500 AF                                     infds(file5ds)

500gAFlichist7  uf a e           k disk    usropn
500gAF                                     rename(lrrec:lrrec7)
500gAF                                     infds(file6ds)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

100bA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#LICHIST
500sA /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($lrver#)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s                   like(lrwhse)

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D vfywhse         s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D HostCall        s               n
     D debugnode       s               n   inz(*on)
500lAD locupdated      s               n

500nAD #matchfound     s               n
500nAD #matchlrlcns    s                   like(lrlcns)
500nAD #matchlrtcod    s                   like(lrtcod)
500nAD #matchlrtara    s                   like(lrtara)
500nAD #matchlrtwhd    s                   like(lrtwhd)
500nAD #matchlrtdsp    s                   like(lrtdsp)
500nAD #matchlrtasl    s                   like(lrtasl)
500nAD #matchlrtloc    s                   like(lrtloc)
500nAD #matchlrtlvl    s                   like(lrtlvl)
500nAD #matchlrthnd    s                   like(lrthnd)
500nAD #matchlrtbase   s                   like(lrtbase)
500nAD #matchlrtslp    s                   like(lrtslp)
500nAD #matchlrtitm    s                   like(lrtitm)
500nAD #matchlrtityp   s                   like(lrtityp)
500nAD #matchlrtitms   s                   like(lrtitms)
500nAD #matchlrlqy1    s                   like(lrlqy1)
500nAD #matchlrlqy2    s                   like(lrlqy2)
500nAD #matchlrlqy3    s                   like(lrlqy3)

500gAD count           s              3  0
500pAD currcod         s                   like(lrtcod)
500pAD currslp         s                   like(lrtslp)
500sAD driitem         s               n
     D nxtltrn#        s                   like(lrtrn#)
     D kytrn#          s                   like(lrtrn#)
     D kywhse          s                   like(lrwhse)
     D len             s              3  0
500eAD lic4rmnqty      s                   like(lrlcns)
500eAD lic4tfrqty      s                   like(lrlcns)
500gAD mergelqy1       s                   like(lrlqy1)
500gAD mergelqy2       s                   like(lrlqy2)
500gAD mergelqy3       s                   like(lrlqy3)
     D remain1         s                   like(lrlqy1)
     D remain2         s                   like(lrlqy2)
     D remain3         s                   like(lrlqy3)
500pAD scrunched       s               n
     D temp1a          s              1
     D temp1n          s              1  0
     D temp7a          s              7
500eAD trackpos        s              1
500eAD trackposmrg     s              1
500eAD trackposrtn     s              1
500eMD trackpsplit     s              1
500eAD tracktsplit     s              1
500eAD pllStampSys     s               z
500eAD pllStampUc      s               z

500eA*----------------------------------------------------------------
500eA*  Called program parameters
500eA*----------------------------------------------------------------
500eA
500eAD $lparm          ds
500eAD  $lcmd                  1      8
500eAD  $lprg                  9     18
500eAD  $luky                 19     68
500eAD  $lrtn                 69     76
500eAD  $lerm                 77    136
500eAD  $lmsg                 77     80
500eAD  $ltype                81     88
500eA*
500eA*   Redefine key
500eA*
500eAD  $lwhse2               19     21  0
500eAD  $ltrackitem           22     22
500eAD  $ltrackpos            23     23
500eAD  $lposmrg              24     24
500eAD  $lposrtn              25     25
500eAD  $lpsplit              26     26
500eAD  $ltsplit              27     27

     *----------------------------------------------------------------
     *  File information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds
      /copy qcopysrc,c#file2ds
      /copy qcopysrc,c#file3ds
      /copy qcopysrc,c#file4ds
500 A /copy qcopysrc,c#file5ds
500gA /copy qcopysrc,c#file6ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D*copy qcopysrc,c#pgminfds

     D pssrflag        s               n

     D                sds
     D  #pgm                   1     10
600aAD  #prog                  1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
     D  #routine2        *ROUTINE
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
600aAD  #jobn                264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0
600aAD  #curruser            358    367


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

600aA*----------------------------------------------------------------
600aA*  Phrase Variables
600aA*----------------------------------------------------------------
600aA
600aA /COPY *libl/qcopysrc,c#phrasvar
600aAD  currFile       s             10
600aAD  currRoutine    s             20
     D  stackCount     s              3  0
     D  aRoutine       s             20    dim(30)
600aA
600aA*----------------------------------------------------------------
600aA*  Phrases
600aA*----------------------------------------------------------------
600aA
600aA /COPY *libl/qcopysrc,c#phrases

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return code
      *      $pdata     Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
     C                   parm                    $pmessage
     C                   parm                    $pdata
500oAC                   parm                    $pdata2

     C                   eval      $lichist = $pdata
500oAC                   if        %parms >= 6
500oAC                   eval      $lichist2 = $pdata2
500oAC                   endif
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
600bAC                   eval      stackCount = 0

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See which system is calling the program.

     C                   if        %subst($psubcmd:1:1) = '%'
     C                   eval      DakotaCall = *on
     C                   eval      HostCall   = *off
     C                   eval      %subst($psubcmd:1:1) = '*'
     C                   else
     C                   eval      HostCall   = *on
     C                   eval      DakotaCall = *off
     C                   endif

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $psubcmd = '*OPEN'
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   exsr      aaaclose
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Do what user has requested.

     C                   select

     C                   when      $psubcmd = '*ADDLIC'
     C                   exsr      vfyaddlic
     C                   if        not error
     C                   exsr      addlic
     C                   endif

500iAC                   when      $psubcmd = '*ADJUST'
500iAC                   exsr      vfyadjust
500iAC                   if        not error
500iAC                   exsr      adjust
500iAC                   endif

     C                   when      $psubcmd = '*ASKIN'
     C                   exsr      vfyaskin
     C                   if        not error
     C                   exsr      askin
     C                   endif

     C                   when      $psubcmd = '*ASKOUT'
     C                   exsr      vfyaskout
     C                   if        not error
     C                   exsr      askout
     C                   endif

500gAC                   when      $psubcmd = '*CHK4EXIST'
500gAC                   exsr      vfychk4exist
500gAC                   if        not error
500gAC                   exsr      chk4exist
500gAC                   endif

     C                   when      $psubcmd = '*CLSPUTD'
     C                   exsr      vfyclsputd
     C                   if        not error
     C                   exsr      clsputd
     C                   endif

     C                   when      $psubcmd = '*CLSPUTM'
     C                   exsr      vfyclsputm
     C                   if        not error
     C                   exsr      clsputm
     C                   endif

     C                   when      $psubcmd = '*CLSPUTP'
500dAC                             or $psubcmd = '*CLSRPLP'
500dAC                             or $psubcmd = '*CLSTFRP'
     C                   exsr      vfyclsputp
     C                   if        not error
     C                   exsr      clsputp
     C                   endif

     C                   when      $psubcmd = '*CLSPUTT'
500dAC                             or $psubcmd = '*CLSRPLT'
500dAC                             or $psubcmd = '*CLSTFRT'
     C                   exsr      vfyclsputt
     C                   if        not error
     C                   exsr      clsputt
     C                   endif

     C                   when      $psubcmd = '*CRTNF'
     C                   exsr      vfycrtnf
     C                   if        not error
     C                   exsr      crtnf
     C                   endif

     C                   when      $psubcmd = '*CRTSU'
     C                   exsr      vfycrtsu
     C                   if        not error
     C                   exsr      crtsu
     C                   endif

     C                   when      $psubcmd = '*GETLIC#'
     C                   exsr      vfygetlic#
     C                   if        not error
     C                   exsr      getlic#
     C                   endif

     C                   when      $psubcmd = '*GETLOT#'
     C                   exsr      vfygetlot#
     C                   if        not error
     C                   exsr      getlot#
     C                   endif

     C                   when      $psubcmd = '*GETSLOT'
     C                   exsr      vfygetslot
     C                   if        not error
     C                   exsr      getslot
     C                   endif

500gAC                   when      $psubcmd = '*MERGE'
500nDC**                 exsr      vfymerge
500nDC**                 if        not error
500nDC**                 exsr      merge
500nDC**                 endif

     C                   when      $psubcmd = '*MOVBACK'
     C                   exsr      vfymovback
     C                   if        not error
     C                   exsr      movback
     C                   endif

     C                   when      $psubcmd = '*MOVEFWD'
     C                   exsr      vfymovefwd
     C                   if        not error
     C                   exsr      movefwd
     C                   endif

     C                   when      $psubcmd = '*NEWLIC#'
     C                   exsr      vfynewlic#
     C                   if        not error
     C                   exsr      newlic#
     C                   endif

     C                   when      $psubcmd = '*NEWLOT#'
     C                   exsr      vfynewlot#
     C                   if        not error
     C                   exsr      newlot#
     C                   endif

500 AC                   when      $psubcmd = '*MISSINGLP'
500 AC                   exsr      vfymissinglp
500 AC                   if        not error
500 AC                   exsr      missinglp
500 AC                   endif

     C                   when      $psubcmd = '*PULL'
     C                   exsr      vfypull
     C                   if        not error
     C                   exsr      pull
     C                   endif

     C                   when      $psubcmd = '*PUSH'
     C                   exsr      vfypush
     C                   if        not error
     C                   exsr      push
     C                   endif

     C                   when      $psubcmd = '*PUSHPAP'
     C                   exsr      vfypushpap
     C                   if        not error
     C                   exsr      pushpap
     C                   endif

     C                   when      $psubcmd = '*PUSHPAT'
     C                   exsr      vfypushpat
     C                   if        not error
     C                   exsr      pushpat
     C                   endif

500pAC                   when      $psubcmd = '*RMVZERO'
500pAC                   exsr      vfyrmvzero
500pAC                   if        not error
500pAC                   exsr      rmvzero
500pAC                   endif

500pAC                   when      $psubcmd = '*RMVZRTN'
500pAC                   exsr      vfyrmvzrtn
500pAC                   if        not error
500pAC                   exsr      rmvzrtn
500pAC                   endif

500 AC                   when      $psubcmd = '*RTNALL'
500 AC                   exsr      vfyrtnall
500 AC                   if        not error
500 AC                   exsr      rtnall
500 AC                   endif

     C                   when      $psubcmd = '*UNDOPUT'
     C                   exsr      vfyundoput
     C                   if        not error
     C                   exsr      undoput
     C                   endif

500cAC                   when      $psubcmd = '*UNDORPL'
500dAC                             or $psubcmd = '*UNDOTFR'
500cAC                   exsr      vfyundorpl
500cAC                   if        not error
500cAC                   exsr      undorpl
500cAC                   endif

     C                   when      $psubcmd = '*UPDLOC'
     C                   exsr      vfyupdloc
     C                   if        not error
     C                   exsr      updloc
     C                   endif

     C                   when      $psubcmd = '*UPDLOC0'
     C                   exsr      vfyupdloc0
     C                   if        not error
     C                   exsr      updloc0
     C                   endif

     C                   when      $psubcmd = '*UPDPUT'
     C                   exsr      vfyupdput
     C                   if        not error
     C                   exsr      updput
     C                   endif

     C                   when      $psubcmd = '*UPDRPLP'
500dAC                             or $psubcmd = '*UPDTFRP'
     C                   exsr      vfyupdrplp
     C                   if        not error
     C                   exsr      updrplp
     C                   endif

     C                   when      $psubcmd = '*UPDRPLT'
500dAC                             or $psubcmd = '*UPDTFRT'
     C                   exsr      vfyupdrplt
     C                   if        not error
600x C                   exsr      updrplt
500nDC**                 exsr      updrplt
500nMC********           exsr      updrplp
     C                   endif

600aAC                   when      $psubcmd = '*UPDTRNLBL'
600aAC                   exsr      vfyupdtrnlbl
600aAC                   if        not error
600aAC                   exsr      updtrnlbl
600aAC                   endif

500 AC                   when      $psubcmd = '*WRONGLOC'
500 AC                   exsr      vfywrongloc
500 AC                   if        not error
500 AC                   exsr      wrongloc
500 AC                   endif

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                      + '(' + %trim($psubcmd) + ') '
     C                                      + 'sent to ' + %trim(#pgm)

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   eval      $pdata = $lichist
500oAC                   if        %parms >= 6
500oAC                   eval      $pdata2 = $lichist2
500oAC                   endif
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *     LICHIST  License History key

     C     lrkey         klist
     C                   kfld                    $lrwhse
     C                   kfld                    $lrlcns

     *     LICHIST1  License History 1 key

     C     lr1ky         klist
     C                   kfld                    $lrwhse
     C                   kfld                    $lrflic

     *     LICHIST2  License History 2 key

     C     lr2key        klist
     C                   kfld                    $lrwhse
     C                   kfld                    $lrtwhd
     C                   kfld                    $lrtasl
     C                   kfld                    $lrtloc
     C                   kfld                    $lrtlvl
     C                   kfld                    $lrthnd

     *     LICHIST2  License History 2 key

     C     lr2aky        klist
     C                   kfld                    $lrwhse
     C                   kfld                    $lrtwhd
     C                   kfld                    $lrtasl
     C                   kfld                    $lrtloc
     C                   kfld                    $lrtlvl
     C                   kfld                    $lrthnd
     C                   kfld                    $lrlcns
417bA
417bA*     LICHIST3  License History 3 key
417bA
417bAC     lr3key        klist
417bAC                   kfld                    $lrwhse
417bAC                   kfld                    $lrtwhd
417bAC                   kfld                    $lrtasl
417bAC                   kfld                    $lrtloc
417bAC                   kfld                    $lrtlvl
417cA
417cA*     LICHIST3  License History 3 key
417cA
417cAC     lr3akey       klist
417cAC                   kfld                    $lrwhse
417cAC                   kfld                    $lrtwhd
417cAC                   kfld                    $lrtasl
417cAC                   kfld                    $lrtloc
417cAC                   kfld                    $lrtlvl
417cAC                   kfld                    $lrtslp
417pA
417pA*     LICHIST3  License History 3 key
417pA
417pAC     lr3keyp       klist
417pAC                   kfld                    $lrwhse
417pAC                   kfld                    $lrtwhd
417pAC                   kfld                    $lrtasl
417pAC                   kfld                    $lrtloc
417pAC                   kfld                    $lrtlvl
417pAC                   kfld                    currslp
500gA
500gA*     LICHIST5  License History 5 key
500gA
500gAC     lr5key        klist
500gAC                   kfld                    $lrwhse
500gAC                   kfld                    $lrtwhd
500gAC                   kfld                    $lrtbase
500gAC                   kfld                    $lrtitm
500gA
500gA*     LICHIST7  License History 7 key
500gA
500gAC     lr7key        klist
500gAC                   kfld                    $lrwhse
500gAC                   kfld                    $lrtwhd
500gAC                   kfld                    $lrtasl
500gAC                   kfld                    $lrtloc
500gAC                   kfld                    $lrtlvl
500gAC                   kfld                    $lrthnd
500gAC                   kfld                    $lrtitm
500nDC**                 kfld                    $lrtslp
500 A
500 A*     LICHIST  License History key for updrpl
500 A
500 AC     lrkeyrpl      klist
500 AC                   kfld                    $lrwhse
500 AC                   kfld                    $lrflic

     C                   endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr
600bAC                   eval      currRoutine = '*PSSR'

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

600bAC                   exsr      phPgmV1V2V3s

     *  Send message back to calling program.

     C                   eval      $preturn = 'U:' + #status
     C                   eval      $pmessage = 'U:'
     C                                       + %trim(#pgm)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr

     *----------------------------------------------------------------
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

     C     aaainit       begsr
     C                   endsr

     *----------------------------------------------------------------
     *  aaaclose   Close called programs
     *----------------------------------------------------------------

     C     aaaclose      begsr
600bAC                   eval      currRoutine = 'aaaclose'
600bAC                   exsr      phpgmV1V2V3s

     C                   if        vfywhse
     C                   call(e)   'VFYWHSE'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      0             $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   if        %error
     C                   endif
     C                   endif

500sAC                   if        driitem
500sAC                   call(e)   'DRIITEM'
500sAC                   parm      '*CLOSE'      $drisubcmd
500sAC                   parm      $pprogram     $driprogram
500sAC                   parm      ' '           $drireturn
500sAC                   parm      ' '           $drimessage
500sAC                   parm      ' '           $dridata
500sAC                   if        %error
500sAC                   endif
500sAC                   endif

600bAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  addlic
     *----------------------------------------------------------------

     C     addlic        begsr
600bAC                   eval      currRoutine = 'addlic'
600bAC                   exsr      phpgmV1V2V3s
     C                   eval      error = *off
100bMC                   exsr      getcurrstamp

     *  Make sure file is open.

     C                   exsr      fileopenlh
     C                   if        error
     C                   goto      endadd
     C                   endif
500tA
500tA*  See if a matching Active record exists.
500tA
500tAC                   exsr      look4match

     *  Clear record.

     C                   clear                   lrrec

     *  Move main information into fields.

417laC                   exsr      getltrn
     C                   eval      lrltrn = nxtltrn#

417laC                   eval      lrnode    = '1'

416aAC                   if        $lrwhseu
     C                   eval      lrwhse = $lrwhse
416aAC                   endif

500eDC**                 if        $lracflu
500eDC**                 eval      lracfl = $lracfl
500eDC**                 else
500eDC**                 eval      lracfl = 'A'
500eDC**                 endif
500eMC                   if        $lrstatu
500eMC                   eval      lrstat = $lrstat
500eMC                   else
500eMC                   eval      lrstat = 'A'
500eMC                   endif

416aAC                   if        $lrtrn#u
     C                   eval      lrtrn# = $lrtrn#
416aAC                   endif

416aAC                   if        $lrlbl#u
     C                   eval      lrlbl# = $lrlbl#
416aAC                   endif

416aAC                   if        $lrlcnsu
500bAC                   exsr      zzchklcns
     C                   eval      lrlcns = $lrlcns
416aAC                   endif

416aAC                   if        $lrflicu
     C                   eval      lrflic = $lrflic
416aAC                   endif

416aAC                   if        $lrolicu
     C                   eval      lrolic = $lrolic
     C                   else
     C                   eval      lrolic = $lrlcns
416aAC                   endif

416aAC                   if        $lrlqy1u
     C                   eval      lrlqy1 = $lrlqy1
416aAC                   endif

416aAC                   if        $lrlqy2u
     C                   eval      lrlqy2 = $lrlqy2
416aAC                   endif

416aAC                   if        $lrlqy3u
     C                   eval      lrlqy3 = $lrlqy3
416aAC                   endif

500sAC                   exsr      fixbrkdn

416aAC                   if        $lraqy1u
     C                   eval      lraqy1 = $lraqy1
416aAC                   endif

416aAC                   if        $lraqy2u
     C                   eval      lraqy2 = $lraqy2
416aAC                   endif

416aAC                   if        $lraqy3u
     C                   eval      lraqy3 = $lraqy3
416aAC                   endif

416aAC                   if        $lrfcodu
     C                   eval      lrfcod = $lrfcod
416aAC                   endif

416aAC                   if        $lrfarau
     C                   eval      lrfara = $lrfara
416aAC                   endif

416aAC                   if        $lrfwhdu
     C                   eval      lrfwhd = $lrfwhd
416aAC                   endif

416aAC                   if        $lrfdspu
     C                   eval      lrfdsp = $lrfdsp
416aAC                   endif

416aAC                   if        $lrfaslu
     C                   eval      lrfasl = $lrfasl
416aAC                   endif

416aAC                   if        $lrflocu
     C                   eval      lrfloc = $lrfloc
416aAC                   endif

416aAC                   if        $lrflvlu
     C                   eval      lrflvl = $lrflvl
416aAC                   endif

416aAC                   if        $lrfhndu
     C                   eval      lrfhnd = $lrfhnd
416aAC                   endif

500eAC                   if        $lrfbaseu
500eAC                   eval      lrfbase = $lrfbase
500eAC                   endif

416aAC                   if        $lrfslpu
     C                   eval      lrfslp = $lrfslp
416aAC                   endif

416aAC                   if        $lrfitmu
     C                   eval      lrfitm = $lrfitm
416aAC                   endif

500eAC                   if        $lrfitypu
500eAC                   eval      lrfityp = $lrfityp
500eAC                   endif

500eAC                   if        $lrfitmsu
500eAC                   eval      lrfitms = $lrfitms
500eAC                   endif

416aAC                   if        $lrtcodu
     C                   eval      lrtcod = $lrtcod
416aAC                   endif

416aAC                   if        $lrtarau
     C                   eval      lrtara = $lrtara
416aAC                   endif

416aAC                   if        $lrtwhdu
     C                   eval      lrtwhd = $lrtwhd
416aAC                   endif

416aAC                   if        $lrtdspu
     C                   eval      lrtdsp = $lrtdsp
416aAC                   endif

416aAC                   if        $lrtaslu
     C                   eval      lrtasl = $lrtasl
416aAC                   endif

416aAC                   if        $lrtlocu
     C                   eval      lrtloc = $lrtloc
416aAC                   endif

416aAC                   if        $lrtlvlu
     C                   eval      lrtlvl = $lrtlvl
416aAC                   endif

416aAC                   if        $lrthndu
     C                   eval      lrthnd = $lrthnd
416aAC                   endif

500eAC                   if        $lrtbaseu
500eAC                   eval      lrtbase = $lrtbase
500eAC                   endif

416aAC                   if        $lrtslpu
     C                   eval      lrtslp = $lrtslp
416aAC                   endif

416aAC                   if        $lrtitmu
     C                   eval      lrtitm = $lrtitm
416aAC                   endif

500eAC                   if        $lrtitypu
500eAC                   eval      lrtityp = $lrtityp
500eAC                   endif

500eAC                   if        $lrtitmsu
500eAC                   eval      lrtitms = $lrtitms
500eAC                   endif

416aAC                   if        $lrtordu
     C                   eval      lrtord = $lrtord
416aAC                   endif

416aAC                   if        $lrtsequ
     C                   eval      lrtseq = $lrtseq
416aAC                   endif

416aAC                   if        $lrexcdu
     C                   eval      lrexcd = $lrexcd
416aAC                   endif


     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *  If match was found, create record as Inactive.

500tAC                   if        #matchfound
500tAC                   eval      lrstat = 'I'
500tAC                   eval      lrchgts     = currstampsys
500tAC                   eval      lrchguc     = currstampuc
500tAC                   eval      lrchgpgm    = $lrpgm
500tAC                   eval      lrchgemp    = $lremp#
500tAC                   eval      lrchgusr    = $lruser
500tAC                   eval      lrchgjob    = $lrjob
500tAC                   eval      lrchgnbr    = $lrjobn
500tAC                   endif

     *  Add record.

     C                   write(e)  lrrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDLIC'
     C                   eval      $pmessage = 'Error on "Add '
     C                                       + ' Lic Hist" command '
     C                                       + '('
     C                                       + %trim(%editc(lrwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(%editc(lrtrn#:'P'))
     C                                       + '/'
     C                                       + %trim(lrlcns)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   eval      $lrwhsee = '1'
     C                   eval      $lrlcnse = '1'
     C                   endif
600bAC                   eval      currFile = 'lrrec'
600bAC                   exsr      phWrtV1V2V3V4

     *  If match wasn't found, we're done.

500tAC                   if        not #matchfound
500tAC                   goto      endadd
500tAC                   endif
500tA
500tA*  Otherwise ...
500tA
500tA*    Create a new record showing above record going into match lic#
500tA
500tA*      - Get new sequence number.
500tA
500tAC                   call      'PIRLLP#'
500tAC                   parm      0             nxtlp#            7 0
500tAC                   eval      lrltrn = nxtlp#
500tAC                   eval      lrstat = 'A'
500tAC                   eval      lrexcd = ' '
500tA
500tA*      - Update From info with To info sent in.
500tA
500tAC                   eval      lrflic = lrlcns
500tAC                   eval      lrfcod = lrtcod
500tAC                   eval      lrfara = lrtara
500tAC                   eval      lrfwhd = lrtwhd
500tAC                   eval      lrfdsp = lrtdsp
500tAC                   eval      lrfbase = lrtbase
500tAC                   eval      lrfasl = lrtasl
500tAC                   eval      lrfloc = lrtloc
500tAC                   eval      lrflvl = lrtlvl
500tAC                   eval      lrfhnd = lrfhnd
500tAC                   eval      lrfslp = lrtslp
500tAC                   eval      lrfitm = lrtitm
500tAC                   eval      lrfityp = lrtityp
500tAC                   eval      lrfitms = lrtitms
500tA
500tA*      - Update To info with To info from match.
500tA
500tAC                   eval      lrlcns = #matchlrlcns
500tAC                   eval      lrtcod = #matchlrtcod
500tAC                   eval      lrtara = #matchlrtara
500tAC                   eval      lrtwhd = #matchlrtwhd
500tAC                   eval      lrtdsp = #matchlrtdsp
500tAC                   eval      lrtasl = #matchlrtasl
500tAC                   eval      lrtloc = #matchlrtloc
500tAC                   eval      lrtlvl = #matchlrtlvl
500tAC                   eval      lrthnd = #matchlrthnd
500tAC                   eval      lrtbase = #matchlrtbase
500tAC                   eval      lrtslp = #matchlrtslp
500tAC                   eval      lrtitm = #matchlrtitm
500tAC                   eval      lrtityp = #matchlrtityp
500tAC                   eval      lrtitms = #matchlrtitms
500tA
500tA*      - Update quantities
500tA
500tAC                   eval      lraqy1 = lrlqy1
500tAC                   eval      lraqy2 = lrlqy2
500tAC                   eval      lraqy3 = lrlqy3
500tA
500tAC                   eval      lrlqy1 = lrlqy1 + #matchlrlqy1
500tAC                   eval      lrlqy2 = lrlqy2 + #matchlrlqy2
500tAC                   eval      lrlqy3 = lrlqy3 + #matchlrlqy3
500tA
500tAC                   exsr      fixbrkdn
500tA
500tA*      - Update Added by info for new record.
500tA
500tAC                   eval      lraddts     = currstampsys
500tAC                   eval      lradduc     = currstampuc
500tAC                   eval      lraddpgm    = $lrpgm
500tAC                   eval      lraddemp    = $lremp#
500tAC                   eval      lraddusr    = $lruser
500tAC                   eval      lraddjob    = $lrjob
500tAC                   eval      lraddnbr    = $lrjobn
500tA
500tA*      - Initialize Changed by info for new record.
500tA
500tAC                   eval      lrchgts     = *loval
500tAC                   eval      lrchguc     = *loval
500tAC                   eval      lrchgpgm    = ' '
500tAC                   eval      lrchgemp    = 0
500tAC                   eval      lrchgusr    = ' '
500tAC                   eval      lrchgjob    = ' '
500tAC                   eval      lrchgnbr    = ' '
500tA
500tA*      - Write record.
500tA
500tAC                   if        debugnode
500tAC                   move      '       '     lrnode
500tAC                   endif
500tA
500tAC                   eval      len = %len(%trimr(lrnode))
500tAC                   eval      temp1a = %subst(lrnode:len:1)
500tAC                   move      temp1a        temp1n
500tAC                   if        temp1n < 9
500tAC                   eval      temp1n = temp1n + 1
500tAC                   move      temp1n        temp1a
500tAC                   eval      %subst(lrnode:len:1) = temp1a
500tAC                   endif
500tA
500tAC                   if        debugnode
500tAC                   move      'addlic'      lrnode
500tAC                   endif
500tA
500tAC                   write(e)  lrrec
500tAC                   if        %error
500tAC                   eval      error = *on
500tAC                   eval      $preturn = 'ERRADDLIM'
500tAC                   eval      $pmessage = 'Error on "Add '
500tAC                                       + ' Lic Hist" command '
500tAC                                       + '('
500tAC                                       + %trim(%editc(lrwhse:'Z'))
500tAC                                       + '/'
500tAC                                       + %trim(%editc(lrtrn#:'P'))
500tAC                                       + '/'
500tAC                                       + %trim(lrlcns)
500tAC                                       + ')'
500tAC                                       + '-' + f1messageid
500tAC                   eval      $lrwhsee = '1'
500tAC                   eval      $lrlcnse = '1'
500tAC                   endif
600bAC                   eval      currFile = 'lrrec'
600bAC                   exsr      phWrtV1V2V3V4

600bAC     endadd        tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500iA*----------------------------------------------------------------
500iA*  adjust - Adjust license quantity
500iA*----------------------------------------------------------------
500iA
500iAC     adjust        begsr
600bAC                   eval      currRoutine = 'adjust'
600bAC                   exsr      phpgmV1V2V3s
     C                   eval      error = *off
     C                   exsr      getcurrstamp

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endadjust

     * Get current record.

     C     lr1ky         setll     lichist1
     C     lr1ky         reade     lichist1
     C                   if        %eof
     C                   goto      endadjust
     C                   endif

     * Inactivate current record.

     C                   eval      lrstat = 'I '

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn

     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4

     * Create new record for adjustment.

     *    - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
     C                   eval      lrstat = 'A '
500qAC                   eval      lrexcd = ' '

     *    - Update From info with To info from original record.
     *    - Note, To info remains the same for an adjustment.

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

     C                   eval      lraqy1 = $lrlqy1
     C                   eval      lraqy2 = $lrlqy2
     C                   eval      lraqy3 = $lrlqy3

     C                   eval      lrlqy1 = lrlqy1 + $lrlqy1
     C                   eval      lrlqy2 = lrlqy2 + $lrlqy2
     C                   eval      lrlqy3 = lrlqy3 + $lrlqy3

500sAC                   exsr      fixbrkdn

     *    - Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *    - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '

     *    - Write or update record.

     C                   if        debugnode
     C                   move      '       '     lrnode
     C                   endif

     C                   eval      len = %len(%trimr(lrnode))
     C                   eval      temp1a = %subst(lrnode:len:1)
     C                   move      temp1a        temp1n
     C                   if        temp1n < 9
     C                   eval      temp1n = temp1n + 1
     C                   move      temp1n        temp1a
     C                   eval      %subst(lrnode:len:1) = temp1a
     C                   endif

     C                   if        debugnode
     C                   move      'adjust'      lrnode
     C                   endif

     C                   write     lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phWrtV1V2V3V4

600bAC     endadjust     tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  askin
     *
417dA*    See if calling program should ask for license when putting item
417dA*    into a slot.
     *
417dA*      Note: $lrlcns contains license in transit ('?' license).
417dA*            $lrtmlc contains original license taken out of slot.
417dA*            $lrfcod contains SLPICK flag of slot.
417dA*            $lrlqy are zero of entire tfr qty being put into slot,
417dA*                  otherwise contains partial qty being put into slot.
     *
     *----------------------------------------------------------------

     C     askin         begsr
600bAC                   eval      currRoutine = 'askin'
600bAC                   exsr      phpgmV1V2V3s
417dA
 1X  C                   select
417dA
417dA*  Don't ask if qty going into a Pick slot.
417dA
 1X  C                   when      $lrfcod = 'Y'
     C                   eval      $preturn = '*NO'
417dA
417dA*  Ask if putting a partial qty into the slot.
417dA
 1X  C                   when      $lrlqy1 > 0 or $lrlqy2 > 0 or $lrlqy3 > 0
     C                   eval      $preturn = '*YES'
417dA
417dA*  Don't ask if original license is being used (full qty taken out)
417dA
 1X  C                   when      $lrlcns = $lrflic
     C                   eval      $preturn = '*NO'
417dA
417dA*  Otherwise, ask.
417dA
     C                   other
     C                   eval      $preturn = '*YES'
417dA
     C                   endsl

600bAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  askout
     *
417dA*    See if calling program should ask for license when taking item
417dA*    out of a slot.
     *
     *----------------------------------------------------------------

     C     askout        begsr
600bAC                   eval      currRoutine = 'askout'
600bAC                   exsr      phpgmV1V2V3s
417dA
 1X  C                   select
 1X  C                   when      $lrlcns = ' '
 1X  C                             or %subst($lrlcns:1:3) = '*SU'
 1X  C                             or %subst($lrlcns:1:3) = '*MI'
 1X  C                             or %subst($lrlcns:1:3) = '*NA'
 1X  C                             or %subst($lrlcns:1:3) = '*NF'
     C                   eval      $preturn = '*NO'
     C                   other
     C                   eval      $preturn = '*MATCH'
     C***                eval      $preturn = '*OPT'
     C                   endsl

600bAC                   exsr      phpgmV1V2V3e
     C                   endsr

500gA*----------------------------------------------------------------
500gA*  chk4exist
500gA*
500gA*    Check if item already exists in base slot and if it exists
500gA*    in a specific slot position.
500gA*
500gA*----------------------------------------------------------------
500gA
500gAC     chk4exist     begsr
600bAC                   eval      currRoutine = 'askout'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh5
     C     error         cabeq     *on           endchk4exist

     C                   eval      $preturn = '*NOTFOUND'

     *  Loop through all records for base slot / item.

     C     lr5key        setll     lichist5
     C                   dow       forever = forever
     C     lr5key        reade(n)  lichist5

     C                   select
     C                   when      %eof(lichist5)
     C                   leave

     C                   when      lrtslp = $lrtslp
     C                   eval      $preturn = '*FOUNDSAME'
     C                   leave

     C                   other
     C                   eval      $preturn = '*FOUNDDIFF'

     C                   endsl

     C                   enddo

600bAC     endchk4exist  tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  clsputd
     *
     *    Update Directed putaway to show new location.
     *
     *----------------------------------------------------------------

     C     clsputd       begsr
600bAC                   eval      currRoutine = 'clsputd'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endclsputd


     C     lrkey         setll     lichist1
     C     lrkey         reade     lichist1
 2B  C                   if        not %eof

     *  Update To info for license.

     C                   eval      lrtcod = $lrtcod
     C                   eval      lrtara = $lrtara
417aAC                   eval      lrtslp = $lrtslp

     *  Update Changed by info for new record.

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn

 2E  C                   endif

600bAC     endclsputd    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  clsputm
     *
     *    Update Manual putaway to show new location.
     *
     *----------------------------------------------------------------

     C     clsputm       begsr
600bAC                   eval      currRoutine = 'clsputm'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endclsputm

     C     lrkey         setll     lichist1
     C     lrkey         reade     lichist1
 2B  C                   if        not %eof

     *  Update To info for license.

     C                   eval      lrtcod = $lrtcod
     C                   eval      lrtara = $lrtara
     C                   eval      lrtwhd = $lrtwhd
     C                   eval      lrtasl = $lrtasl
     C                   eval      lrtloc = $lrtloc
     C                   eval      lrtlvl = $lrtlvl
     C                   eval      lrthnd = $lrthnd
417aAC                   eval      lrtslp = $lrtslp
     C                   eval      lrlqy1 = $lrlqy1
     C                   eval      lrlqy2 = $lrlqy2
     C                   eval      lrlqy3 = $lrlqy3

500sAC                   exsr      fixbrkdn

     *  Update Changed by info for new record.

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn

     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4

 2E  C                   endif

600bAC     endclsputm    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

417iA*----------------------------------------------------------------
417iA*  clsputp - Close putaway using partial quantity.
417iA*----------------------------------------------------------------
417iA
417iAC     clsputp       begsr
600bAC                   eval      currRoutine = 'clsputp'
600bAC                   exsr      phpgmV1V2V3s
100bMC                   eval      error = *off
100bMC                   exsr      getcurrstamp

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endclsputp
500nA
500nA*  See if a matching Active record exists.
500nA
500nAC                   exsr      look4match
417iA
     * Get current record.

417jMC     lr1ky         setll     lichist1
417jMC     lr1ky         reade     lichist1
     C                   if        %eof
     C                   goto      endclsputp
     C                   endif

     * Calculate quantity not put away.

500oDC**                 if        lrlqy1 >= $lrlqy1
500oDC**                 eval      remain1 = lrlqy1 - $lrlqy1
500oMC                   if        lrlqy1 >= $lrnorm1
500oMC                   eval      remain1 = lrlqy1 - $lrnorm1
     C                   else
     C                   eval      remain1 = 0
     C                   endif

500oDC**                 if        lrlqy2 >= $lrlqy2
500oDC**                 eval      remain2 = lrlqy2 - $lrlqy2
500oMC                   if        lrlqy2 >= $lrnorm2
500oMC                   eval      remain2 = lrlqy2 - $lrnorm2
     C                   else
     C                   eval      remain2 = 0
     C                   endif

500oDC**                 if        lrlqy3 >= $lrlqy3
500oDC**                 eval      remain3 = lrlqy3 - $lrlqy3
500oMC                   if        lrlqy3 >= $lrnorm3
500oMC                   eval      remain3 = lrlqy3 - $lrnorm3
     C                   else
     C                   eval      remain3 = 0
     C                   endif
500nA
500nA*  If nothing remaining, execute CLSPUTT routine and get out.
500nA
500nAC                   if        remain1 = 0
500nAC                             and remain2 = 0
500nAC                             and remain3 = 0
500nAC                   exsr      clsputt
500nAC                   goto      endclsputp
500nAC                   endif

     * Update current In-Transit record with remaining quantity.

500nDC**                 if        remain1 > 0
500nDC**                           or remain2 > 0
500nDC**                           or remain3 > 0

     C                   eval      lrlqy1 = remain1
     C                   eval      lrlqy2 = remain2
     C                   eval      lrlqy3 = remain3

500sAC                   exsr      fixbrkdn

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn

     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4
500nDC**                 endif

     * Create new record for quantity putaway.

     *    - Get new sequence number.

500nDC**                 if        remain1 > 0
500nDC**                           or remain2 > 0
500nDC**                           or remain3 > 0
     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
500eDC**                 eval      lracfl = 'A '
500eMC                   eval      lrstat = 'A '
500nDC**                 endif

     *    - Update To information.

500nAC                   if        #matchfound
500nAC                   eval      lrstat = 'I'
500nAC                   eval      lrflic = lrlcns
500nAC                   exsr      zzchklcns
500nAC                   eval      lrlcns = $lrlcns
500nAC                   eval      lrtcod = #matchlrtcod
500nAC                   eval      lrtara = #matchlrtara
500nAC                   eval      lrtwhd = #matchlrtwhd
500nAC                   eval      lrtdsp = #matchlrtdsp
500nAC                   eval      lrtasl = #matchlrtasl
500nAC                   eval      lrtloc = #matchlrtloc
500nAC                   eval      lrtlvl = #matchlrtlvl
500nAC                   eval      lrthnd = #matchlrthnd
500nAC                   eval      lrtbase = #matchlrtbase
500nAC                   eval      lrtslp = #matchlrtslp
500nAC                   eval      lrtitm = #matchlrtitm
500nAC                   eval      lrtityp = #matchlrtityp
500nAC                   eval      lrtitms = #matchlrtitms
500nAC                   else
417jAC                   eval      lrflic = lrlcns
417jAC                   exsr      zzchklcns
417jAC                   eval      lrlcns = $lrlcns
     C                   eval      lrtcod = $lrtcod
     C                   eval      lrtara = $lrtara
     C                   eval      lrtwhd = $lrtwhd
     C                   eval      lrtdsp = $lrtdsp
     C                   eval      lrtasl = $lrtasl
     C                   eval      lrtloc = $lrtloc
     C                   eval      lrtlvl = $lrtlvl
     C                   eval      lrthnd = $lrthnd
500eAC                   eval      lrtbase = $lrtbase
     C                   eval      lrtslp = $lrtslp
     C                   eval      lrtitm = $lrtitm
500eAC                   eval      lrtityp = $lrtityp
500eAC                   eval      lrtitms = $lrtitms
500nAC                   endif
500nA
     C                   eval      lrlqy1 = $lrlqy1
     C                   eval      lrlqy2 = $lrlqy2
     C                   eval      lrlqy3 = $lrlqy3

500sAC                   exsr      fixbrkdn

500nAC                   eval      lraqy1 = $lrlqy1
500nAC                   eval      lraqy2 = $lrlqy2
500nAC                   eval      lraqy3 = $lrlqy3

500nAC                   eval      lraddts     = currstampsys
500nAC                   eval      lradduc     = currstampuc
500nAC                   eval      lraddpgm    = $lrpgm
500nAC                   eval      lraddemp    = $lremp#
500nAC                   eval      lraddusr    = $lruser
500nAC                   eval      lraddjob    = $lrjob
500nAC                   eval      lraddnbr    = $lrjobn
500nA
500nA*      - Initialize Changed by info for new record.
500nA
500nAC                   eval      lrchgts     = *loval
500nAC                   eval      lrchguc     = *loval
500nAC                   eval      lrchgpgm    = ' '
500nAC                   eval      lrchgemp    = 0
500nAC                   eval      lrchgusr    = ' '
500nAC                   eval      lrchgjob    = ' '
500nAC                   eval      lrchgnbr    = ' '

500nDC**                 eval      lrchgts     = currstampsys
500nDC**                 eval      lrchguc     = currstampuc
500nDC**                 eval      lrchgpgm    = $lrpgm
500nDC**                 eval      lrchgemp    = $lremp#
500nDC**                 eval      lrchgusr    = $lruser
500nDC**                 eval      lrchgjob    = $lrjob
500nDC**                 eval      lrchgnbr    = $lrjobn

500nM*    - Write record.

500nDC**                 if        remain1 > 0
500nDC**                           or remain2 > 0
500nDC**                           or remain3 > 0
417lA
417lAC                   if        debugnode
417lAC                   move      '       '     lrnode
417lAC                   endif
417lA
417lAC                   eval      len = %len(%trimr(lrnode))
417lAC                   eval      temp1a = %subst(lrnode:len:1)
417lAC                   move      temp1a        temp1n
417lAC                   if        temp1n < 9
417lAC                   eval      temp1n = temp1n + 1
417lAC                   move      temp1n        temp1a
417lAC                   eval      %subst(lrnode:len:1) = temp1a
417lAC                   endif
417lA
417lAC                   if        debugnode
417lAC                   move      'clsputp'     lrnode
417lAC                   endif
417lA
500qAC                   eval      lrexcd = ' '
     C                   write     lrrec1
500nDC**                 else
500nDC**                 update    lrrec1
500nDC**                 endif
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phWrtV1V2V3V4

     *  If no match was found, were done.

     C     #matchfound   cabeq     *off          endclsputp

     *  Otherwise ...

     *    Create a new record showing above record going into match lic#

     *      - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
     C                   eval      lrstat = 'A'
500qAC                   eval      lrexcd = ' '

     *      - Update From info with To info sent in.

     C                   eval      lrflic = $lrlcns
     C                   eval      lrfcod = $lrtcod
     C                   eval      lrfara = $lrtara
     C                   eval      lrfwhd = $lrtwhd
     C                   eval      lrfdsp = $lrtdsp
     C                   eval      lrfbase = $lrtbase
     C                   eval      lrfasl = $lrtasl
     C                   eval      lrfloc = $lrtloc
     C                   eval      lrflvl = $lrtlvl
     C                   eval      lrfhnd = $lrfhnd
     C                   eval      lrfslp = $lrtslp
     C                   eval      lrfitm = $lrtitm
     C                   eval      lrfityp = $lrtityp
     C                   eval      lrfitms = $lrtitms

     *      - Update To info with To info from match.

500nAC                   eval      lrlcns = #matchlrlcns
500nAC                   eval      lrtcod = #matchlrtcod
500nAC                   eval      lrtara = #matchlrtara
500nAC                   eval      lrtwhd = #matchlrtwhd
500nAC                   eval      lrtdsp = #matchlrtdsp
500nAC                   eval      lrtasl = #matchlrtasl
500nAC                   eval      lrtloc = #matchlrtloc
500nAC                   eval      lrtlvl = #matchlrtlvl
500nAC                   eval      lrthnd = #matchlrthnd
500nAC                   eval      lrtbase = #matchlrtbase
500nAC                   eval      lrtslp = #matchlrtslp
500nAC                   eval      lrtitm = #matchlrtitm
500nAC                   eval      lrtityp = #matchlrtityp
500nAC                   eval      lrtitms = #matchlrtitms

     *      - Update quantities

     C                   eval      lraqy1 = $lrlqy1
     C                   eval      lraqy2 = $lrlqy2
     C                   eval      lraqy3 = $lrlqy3

     C                   eval      lrlqy1 = $lrlqy1 + #matchlrlqy1
     C                   eval      lrlqy2 = $lrlqy2 + #matchlrlqy2
     C                   eval      lrlqy3 = $lrlqy3 + #matchlrlqy3

500sAC                   exsr      fixbrkdn

     *      - Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *      - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '

     *      - Write record.

     C                   if        debugnode
     C                   move      '       '     lrnode
     C                   endif

     C                   eval      len = %len(%trimr(lrnode))
     C                   eval      temp1a = %subst(lrnode:len:1)
     C                   move      temp1a        temp1n
     C                   if        temp1n < 9
     C                   eval      temp1n = temp1n + 1
     C                   move      temp1n        temp1a
     C                   eval      %subst(lrnode:len:1) = temp1a
     C                   endif

     C                   if        debugnode
     C                   move      'clsputp'     lrnode
     C                   endif

     C                   write     lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phWrtV1V2V3V4

600bAC     endclsputp    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

417iA*----------------------------------------------------------------
417iA*  clsputt - Close putaway using total quantity.
417iA*----------------------------------------------------------------
417iA
417iAC     clsputt       begsr
600bAC                   eval      currRoutine = 'clsputt'
600bAC                   exsr      phpgmV1V2V3s
100bMC                   eval      error = *off
100bMC                   exsr      getcurrstamp

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endclsputt
500nA
500nA*  See if a matching Active record exists.
500nA
500nAC                   exsr      look4match
500nA
500nA*  Get Sent license record.

     C     lr1ky         setll     lichist1
     C     lr1ky         reade     lichist1
 2B  C                   if        not %eof

     *  Update To info for license.

500nAC                   if        #matchfound
500nAC                   eval      lrstat = 'I'
500nAC                   eval      lrtcod = #matchlrtcod
500nAC                   eval      lrtara = #matchlrtara
500nAC                   eval      lrtwhd = #matchlrtwhd
500nAC                   eval      lrtdsp = #matchlrtdsp
500nAC                   eval      lrtasl = #matchlrtasl
500nAC                   eval      lrtloc = #matchlrtloc
500nAC                   eval      lrtlvl = #matchlrtlvl
500nAC                   eval      lrthnd = #matchlrthnd
500nAC                   eval      lrtbase = #matchlrtbase
500nAC                   eval      lrtslp = #matchlrtslp
500nAC                   eval      lrtitm = #matchlrtitm
500nAC                   eval      lrtityp = #matchlrtityp
500nAC                   eval      lrtitms = #matchlrtitms
500nAC                   else
     C                   eval      lrtcod = $lrtcod
     C                   eval      lrtara = $lrtara
     C                   eval      lrtwhd = $lrtwhd
     C                   eval      lrtdsp = $lrtdsp
     C                   eval      lrtasl = $lrtasl
     C                   eval      lrtloc = $lrtloc
     C                   eval      lrtlvl = $lrtlvl
     C                   eval      lrthnd = $lrthnd
500eAC                   eval      lrtbase = $lrtbase
     C                   eval      lrtslp = $lrtslp
     C                   eval      lrtitm = $lrtitm
500eAC                   eval      lrtityp = $lrtityp
500eAC                   eval      lrtitms = $lrtitms
500nAC                   endif
500nA
     C                   eval      lrlqy1 = $lrlqy1
     C                   eval      lrlqy2 = $lrlqy2
     C                   eval      lrlqy3 = $lrlqy3

500sAC                   exsr      fixbrkdn

     *  Update Changed by info for new record.

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn

     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4

 2E  C                   endif

     *  If no match was found, were done.

     C     #matchfound   cabeq     *off          endclsputt

     *  Otherwise ...

     *    Create a new record showing above record going into match lic#

     *      - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
     C                   eval      lrstat = 'A'
500qAC                   eval      lrexcd = ' '

     *      - Update From info with To info sent in.

     C                   eval      lrflic = $lrlcns
     C                   eval      lrfcod = $lrtcod
     C                   eval      lrfara = $lrtara
     C                   eval      lrfwhd = $lrtwhd
     C                   eval      lrfdsp = $lrtdsp
     C                   eval      lrfbase = $lrtbase
     C                   eval      lrfasl = $lrtasl
     C                   eval      lrfloc = $lrtloc
     C                   eval      lrflvl = $lrtlvl
     C                   eval      lrfhnd = $lrfhnd
     C                   eval      lrfslp = $lrtslp
     C                   eval      lrfitm = $lrtitm
     C                   eval      lrfityp = $lrtityp
     C                   eval      lrfitms = $lrtitms

     *      - Update To info with To info from match.

500nAC                   eval      lrlcns = #matchlrlcns
500nAC                   eval      lrtcod = #matchlrtcod
500nAC                   eval      lrtara = #matchlrtara
500nAC                   eval      lrtwhd = #matchlrtwhd
500nAC                   eval      lrtdsp = #matchlrtdsp
500nAC                   eval      lrtasl = #matchlrtasl
500nAC                   eval      lrtloc = #matchlrtloc
500nAC                   eval      lrtlvl = #matchlrtlvl
500nAC                   eval      lrthnd = #matchlrthnd
500nAC                   eval      lrtbase = #matchlrtbase
500nAC                   eval      lrtslp = #matchlrtslp
500nAC                   eval      lrtitm = #matchlrtitm
500nAC                   eval      lrtityp = #matchlrtityp
500nAC                   eval      lrtitms = #matchlrtitms

     *      - Update quantities

     C                   eval      lraqy1 = $lrlqy1
     C                   eval      lraqy2 = $lrlqy2
     C                   eval      lraqy3 = $lrlqy3

     C                   eval      lrlqy1 = $lrlqy1 + #matchlrlqy1
     C                   eval      lrlqy2 = $lrlqy2 + #matchlrlqy2
     C                   eval      lrlqy3 = $lrlqy3 + #matchlrlqy3

500sAC                   exsr      fixbrkdn

     *      - Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *      - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '

     *      - Write record.

     C                   if        debugnode
     C                   move      '       '     lrnode
     C                   endif

500vAC                   eval      lrnode = %trimr(lrnode) + '1'
500vDC**                 eval      len = %len(%trimr(lrnode))
500vDC**                 eval      temp1a = %subst(lrnode:len:1)
500vDC**                 move      temp1a        temp1n
500vDC**                 if        temp1n < 9
500vDC**                 eval      temp1n = temp1n + 1
500vDC**                 move      temp1n        temp1a
500vDC**                 eval      %subst(lrnode:len:1) = temp1a
500vDC**                 endif

     C                   if        debugnode
     C                   move      'clsputt'     lrnode
     C                   endif

     C                   write     lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phWrtV1V2V3V4

600bAC     endclsputt    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  crtsu  -  Create *SU (Startup) tracking record.
     *----------------------------------------------------------------

417jMC     crtsu         begsr
600bAC                   eval      currRoutine = 'crtsu'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh
     C     error         cabeq     *on           endcrtsu

417kDC**                 eval      lrrecr    = lrparm
417kAC                   exsr      fillrec

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
     C                   move      nxtlp#        temp7a
417jMC                   eval      lrlcns = '*SU' + temp7a
     C                   eval      lrolic = lrlcns

500eDC**                 eval      lracfl = 'A '
500eMC                   eval      lrstat = 'A '

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn
417laC                   eval      lrnode    = '1'

     C                   write     lrrec
600bAC                   eval      currFile = 'lrrec'
600bAC                   exsr      phWrtV1V2V3V4

600bAC     endcrtsu      tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  crtnf  -  Create *NF (Not Found) tracking record.
     *----------------------------------------------------------------

     C     crtnf         begsr
600bAC                   eval      currRoutine = 'crtnf'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh
     C     error         cabeq     *on           endcrtnf

417kDC**                 eval      lrrecr    = lrparm
417kAC                   exsr      fillrec

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
     C                   move      nxtlp#        temp7a
     C                   eval      lrlcns = '*NF' + temp7a
     C                   eval      lrolic = lrlcns

500eDC**                 eval      lracfl = 'A '
500eMC                   eval      lrstat = 'A '

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn
417laC                   eval      lrnode    = '1'

     C                   write     lrrec
600bAC                   eval      currFile = 'lrrec'
600bAC                   exsr      phWrtV1V2V3V4

600bAC     endcrtnf      tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr
416bA
416bA*----------------------------------------------------------------
416bA*  fileclose  Close file btswhse
416bA*----------------------------------------------------------------
416bA
416bAC     fileclose     begsr

     C                   if        %open(lichist)
     C                   close(e)  lichist
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRCLSLH'
     C                   eval      $pmessage = 'Error closing LICHIST file'
     C                   endif
     C                   endif

     C                   if        %open(lichist1)
     C                   close(e)  lichist1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRCLSLH1'
     C                   eval      $pmessage = 'Error closing LICHIST1 file'
     C                   endif
     C                   endif

     C                   if        %open(lichist2)
     C                   close(e)  lichist2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRCLSLH2'
     C                   eval      $pmessage = 'Error closing LICHIST2 file'
     C                   endif
     C                   endif

     C                   if        %open(lichist3)
     C                   close(e)  lichist3
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRCLSLH3'
     C                   eval      $pmessage = 'Error closing LICHIST3 file'
     C                   endif
     C                   endif

     C***                if        %open(licinfo)
     C**                 close(e)  licinfo
     C**                 if        %error
     C**                 eval      error = *on
     C**                 eval      $preturn = 'ERRCLSLI'
     C**                 eval      $pmessage = 'Error closing LICINFO file'
     C**                 endif
     C**                 endif

500 AC                   if        %open(lichist5)
500 AC                   close(e)  lichist5
500 AC                   if        %error
500 AC                   eval      error = *on
500 AC                   eval      $preturn = 'ERRCLSLH5'
500 AC                   eval      $pmessage = 'Error closing LICHIST5 file'
500 AC                   endif
500 AC                   endif

500gAC                   if        %open(lichist7)
500gAC                   close(e)  lichist7
500gAC                   if        %error
500gAC                   eval      error = *on
500gAC                   eval      $preturn = 'ERRCLSLH7'
500gAC                   eval      $pmessage = 'Error closing LICHIST7 file'
500gAC                   endif
500gAC                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopenlh  Open file lichist
416bA*----------------------------------------------------------------
416bA
416bAC     fileopenlh    begsr

     C                   if        not %open(lichist)
     C                   open(e)   lichist
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRLH'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file LICHIST in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopenlh1  Open file lichist1
416bA*----------------------------------------------------------------
416bA
416bAC     fileopenlh1   begsr

     C                   if        not %open(lichist1)
     C                   open(e)   lichist1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRLH1'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file LICHIST1 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopenlh2  Open file lichist2
416bA*----------------------------------------------------------------
416bA
416bAC     fileopenlh2   begsr

     C                   if        not %open(lichist2)
     C                   open(e)   lichist2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRLH2'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file LICHIST2 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopenlh3  Open file lichist3
416bA*----------------------------------------------------------------
416bA
416bAC     fileopenlh3   begsr

     C                   if        not %open(lichist3)
     C                   open(e)   lichist3
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRLH3'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file LICHIST3 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  fileopenlh5  Open file lichist5
500 A*----------------------------------------------------------------
500 A
500 AC     fileopenlh5   begsr

     C                   if        not %open(lichist5)
     C                   open(e)   lichist5
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRLH5'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file LICHIST5 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

500gA*----------------------------------------------------------------
500gA*  fileopenlh7  Open file lichist7
500gA*----------------------------------------------------------------
500gA
500gAC     fileopenlh7   begsr

     C                   if        not %open(lichist7)
     C                   open(e)   lichist7
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRLH7'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file LICHIST7 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopenli  Open file licinfo
416bA*----------------------------------------------------------------
416bA
416bAC     fileopenli    begsr

     C**                 if        not %open(licinfo)
     C**                 open(e)   licinfo
     C**                 if        %error
     C**                 eval      error = *on
     C**                 eval      $preturn  = 'OPNERRLI'
     C**                 eval      $pmessage = 'Error occured trying to '
     C**                                    + 'open file LICINFO in pgm '
     C**                                    + #pgm
     C**                 endif
     C**                 endif

     C                   endsr

     *----------------------------------------------------------------
     *  file2dstr Move file fields to data structure fields
     *----------------------------------------------------------------

     C     file2dstr     begsr

     * Initialize data structure.

     C                   eval      savever# = $lrver#
     C                   clear                   $lichist
500oAC                   clear                   $lichist2
     C                   eval      $lrver# = savever#

     * Move information to data structure.

     C                   eval      $lrwhsee = $driok
416aAC                   eval      $lrwhse = lrwhse

     C                   eval      $lrltrne = $driok
416aAC                   eval      $lrltrn = lrltrn

500eDC**                 eval      $lracfle = $driok
500eDC**                 eval      $lracfl = lracfl
500eMC                   eval      $lrstate = $driok
500eMC                   eval      $lrstat = lrstat

     C                   eval      $lrnodee = $driok
416aAC                   eval      $lrnode = lrnode

     C                   eval      $lrtrn#e = $driok
416aAC                   eval      $lrtrn# = lrtrn#

     C                   eval      $lrlbl#e = $driok
416aAC                   eval      $lrlbl# = lrlbl#

     C                   eval      $lrlcnse = $driok
416aAC                   eval      $lrlcns = lrlcns

     C                   eval      $lrflice = $driok
416aAC                   eval      $lrflic = lrflic

     C                   eval      $lrolice = $driok
416aAC                   eval      $lrolic = lrolic

     C                   eval      $lrlqy1e = $driok
416aAC                   eval      $lrlqy1 = lrlqy1

     C                   eval      $lrlqy2e = $driok
416aAC                   eval      $lrlqy2 = lrlqy2

     C                   eval      $lrlqy3e = $driok
416aAC                   eval      $lrlqy3 = lrlqy3

     C                   eval      $lraqy1e = $driok
416aAC                   eval      $lraqy1 = lraqy1

     C                   eval      $lraqy2e = $driok
416aAC                   eval      $lraqy2 = lraqy2

     C                   eval      $lraqy3e = $driok
416aAC                   eval      $lraqy3 = lraqy3


     C                   eval      $lrfcode = $driok
416aAC                   eval      $lrfcod = lrfcod

     C                   eval      $lrfarae = $driok
416aAC                   eval      $lrfara = lrfara

     C                   eval      $lrfwhde = $driok
416aAC                   eval      $lrfwhd = lrfwhd

     C                   eval      $lrfdspe = $driok
416aAC                   eval      $lrfdsp = lrfdsp

     C                   eval      $lrfasle = $driok
416aAC                   eval      $lrfasl = lrfasl

     C                   eval      $lrfloce = $driok
416aAC                   eval      $lrfloc = lrfloc

     C                   eval      $lrflvle = $driok
416aAC                   eval      $lrflvl = lrflvl

     C                   eval      $lrfhnde = $driok
416aAC                   eval      $lrfhnd = lrfhnd

500eAC                   eval      $lrfbasee = $driok
500eAC                   eval      $lrfbase = lrfbase

     C                   eval      $lrfslpe = $driok
416aAC                   eval      $lrfslp = lrfslp

     C                   eval      $lrfitme = $driok
416aAC                   eval      $lrfitm = lrfitm

500eAC                   eval      $lrfitype = $driok
500eAC                   eval      $lrfityp = lrfityp

500eAC                   eval      $lrfitmse = $driok
500eAC                   eval      $lrfitms = lrfitms


     C                   eval      $lrtcode = $driok
416aAC                   eval      $lrtcod = lrtcod

     C                   eval      $lrtarae = $driok
416aAC                   eval      $lrtara = lrtara

     C                   eval      $lrtwhde = $driok
416aAC                   eval      $lrtwhd = lrtwhd

     C                   eval      $lrtdspe = $driok
416aAC                   eval      $lrtdsp = lrtdsp

     C                   eval      $lrtasle = $driok
416aAC                   eval      $lrtasl = lrtasl

     C                   eval      $lrtloce = $driok
416aAC                   eval      $lrtloc = lrtloc

     C                   eval      $lrtlvle = $driok
416aAC                   eval      $lrtlvl = lrtlvl

     C                   eval      $lrthnde = $driok
416aAC                   eval      $lrthnd = lrthnd

500eAC                   eval      $lrtbasee = $driok
500eAC                   eval      $lrtbase = lrtbase

     C                   eval      $lrtslpe = $driok
416aAC                   eval      $lrtslp = lrtslp

     C                   eval      $lrtitme = $driok
416aAC                   eval      $lrtitm = lrtitm

500eAC                   eval      $lrtitype = $driok
500eAC                   eval      $lrtityp = lrtityp

500eAC                   eval      $lrtitmse = $driok
500eAC                   eval      $lrtitms = lrtitms

     C                   eval      $lrtorde = $driok
416aAC                   eval      $lrtord = lrtord

     C                   eval      $lrtseqe = $driok
416aAC                   eval      $lrtseq = lrtseq

     C                   eval      $lrexcde = $driok
416aAC                   eval      $lrexcd = lrexcd

     C                   endsr

417kA*----------------------------------------------------------------
417kA*  filllrrecr - Fill lrrecr
417kA*----------------------------------------------------------------
417kA
417kAC     fillrec       begsr
     C                   eval      lrwhse = $lrwhse
     C                   eval      lrltrn = $lrltrn
500eDC**                 eval      lracfl = $lracfl
500eMC                   eval      lrstat = $lrstat
     C                   eval      lrtrn# = $lrtrn#
     C                   eval      lrlbl# = $lrlbl#
     C                   eval      lrlcns = $lrlcns
     C                   eval      lrflic = $lrflic
     C                   eval      lrolic = $lrolic
     C                   eval      lrlqy1 = $lrlqy1
     C                   eval      lrlqy2 = $lrlqy2
     C                   eval      lrlqy3 = $lrlqy3
     C                   eval      lraqy1 = $lraqy1
     C                   eval      lraqy2 = $lraqy2
     C                   eval      lraqy3 = $lraqy3
     C                   eval      lrfcod = $lrfcod
     C                   eval      lrfara = $lrfara
     C                   eval      lrfwhd = $lrfwhd
     C                   eval      lrfasl = $lrfasl
     C                   eval      lrfloc = $lrfloc
     C                   eval      lrflvl = $lrflvl
     C                   eval      lrfhnd = $lrfhnd
     C                   eval      lrfslp = $lrfslp
     C                   eval      lrtcod = $lrtcod
     C                   eval      lrtara = $lrtara
     C                   eval      lrtwhd = $lrtwhd
     C                   eval      lrtasl = $lrtasl
     C                   eval      lrtloc = $lrtloc
     C                   eval      lrtlvl = $lrtlvl
     C                   eval      lrthnd = $lrthnd
     C                   eval      lrtslp = $lrtslp
     C                   eval      lrtord = $lrtord
     C                   eval      lrtseq = $lrtseq
     C                   eval      lrexcd = $lrexcd
     C**                 eval      lradts = $lradts
     C*????              eval      lraemp = $lraemp
417lAC*????              eval      lrcemp = $lrcemp
     C*????              eval      lrcusr = $lrcusr
     C*????              eval      lrcjob = $lrcjob
     C*????              eval      lrcjbn = $lrcjbn
     C                   endsr

500sA*----------------------------------------------------------------
500sA*  fixbrkdn  Fix breakdown quantities.
500sA*----------------------------------------------------------------
500sA
500sAC     fixbrkdn      begsr

     *  Get item information.

     C                   exsr      getitem
     C                   if        error
     C                   eval      error = *off
     C                   goto      endfixbrkdn
     C                   endif

     *  First make sure there are no negative available brkdn2/3 qtys.

     *    Breakdown 3 ...

     C                   if        $itumq3 > 0
     C                   dow       lrlqy3 < 0
     C                   eval      lrlqy2 = lrlqy2 - 1
     C                   eval      lrlqy3 = lrlqy3 + $itumq3
500uDC**                 eval      lrlqy2 = lrlqy2 - 1
500uDC**                 eval      lrlqy3 = lrlqy3 + $itumq3
     C                   enddo
     C                   endif

     *    Breakdown 2 ...

     C                   if        $itumq2 > 0
     C                   dow       lrlqy2 < 0
     C                   eval      lrlqy1 = lrlqy1 - 1
     C                   eval      lrlqy2 = lrlqy2 + $itumq2
500uDC**                 eval      lrlqy1 = lrlqy1 - 1
500uDC**                 eval      lrlqy2 = lrlqy2 + $itumq2
     C                   enddo
     C                   endif

     *  Now try to "up" available/stock quantities.

     *    Breakdown 3 ...

     C                   if        $itumq3 > 0
     C                   dow       lrlqy3 >= $itumq3
     C                   eval      lrlqy3 = lrlqy3 - $itumq3
     C                   eval      lrlqy2 = lrlqy2 + 1
500uDC**                 eval      lrlqy3 = lrlqy3 - $itumq3
500uDC**                 eval      lrlqy2 = lrlqy2 + 1
     C                   enddo
     C                   endif

     *    Breakdown 2 ...

     C                   if        $itumq2 > 0
     C                   dow       lrlqy2 >= $itumq2
     C                   eval      lrlqy2 = lrlqy2 - $itumq2
     C                   eval      lrlqy1 = lrlqy1 + 1
500uDC**                 eval      lrlqy2 = lrlqy2 - $itumq2
500uDC**                 eval      lrlqy1 = lrlqy1 + 1
     C                   enddo
     C                   endif

     C     endfixbrkdn   endsr

100bA*----------------------------------------------------------------
100bA*  getcurrstamp  Get current timestamps
100bA*----------------------------------------------------------------
100bA
100bAC     getcurrstamp  begsr

100bMC                   callp     getmicrotime(currstampuc:currstampsys)
100bAC     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr

500sA*----------------------------------------------------------------
500sA*  getitem  Get item info.
500sA*----------------------------------------------------------------
500sA
500sAC     getitem       begsr
     C                   eval      error = *off

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

500uDC**                 eval      $itwhse = $lrwhse
500uDC**                 eval      $ititem = $lrtitm
500uMC                   eval      $itwhse = lrwhse
500uMC                   eval      $ititem = lrtitm

     C                   eval      driitem = *on
     C                   call(e)   'DRIITEM'
     C                   parm      '*GETMAIN'    $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   endsl

     C     endgetitem    endsr

     *----------------------------------------------------------------
     *  getlic#
     *
     *    Retrieve license plate for specific slot.
     *
     *----------------------------------------------------------------

     C     getlic#       begsr

     *  Open file.

     C                   exsr      fileopenlh2
     C     error         cabeq     *on           endgetlic#

     C     lr2key        setll     lichist2
     C     lr2key        reade (n) lichist2
 2B  C                   if        not %eof
     C                   eval      $lrlcns = lrlcns
417gAC                   eval      $lrtcod = lrtcod
417gAC                   eval      $lrtara = lrtara
417aAC                   eval      $lrtslp = lrtslp
     C                   eval      $preturn = '*OK'
     C                   else
     C                   eval      $preturn = '*NOTFOUND'
     C                   endif

     C     endgetlic#    endsr

     *----------------------------------------------------------------
     *  getlot#
     *
     *    Retrieve lot number for specific slot.
     *
     *----------------------------------------------------------------

     C     getlot#       begsr

     *  Open file.

     C                   exsr      fileopenlh2
     C     error         cabeq     *on           endgetlot#

     C     lr2key        setll     lichist2
     C     lr2key        reade (n) lichist2
 2B  C                   if        not %eof
     C                   eval      $lrlcns = lrlcns
417gAC                   eval      $lrtcod = lrtcod
417gAC                   eval      $lrtara = lrtara
     C                   eval      $preturn = '*OK     '
     C                   else
     C                   eval      $preturn = '*NOTFOUND'
     C                   endif

     C     endgetlot#    endsr

100bA*----------------------------------------------------------------
100bA*  getltrn   Get license history transaction number.
100bA*----------------------------------------------------------------
100bA
100bAC     getltrn       begsr

     C                   call      'PIRLLP#'
     C                   parm      0             nxtltrn#

     C                   endsr

     *----------------------------------------------------------------
     *  getslot
     *
417bA*    Retrieve slot for specific license.
     *
     *----------------------------------------------------------------

     C     getslot       begsr

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endgetslot
417bA
417bAC     lrkey         setll     lichist1
417bAC     lrkey         reade (n) lichist1
417bAC                   if        not %eof
417bAC                   eval      $lrlcns = lrlcns
417bAC                   eval      $lrtcod = lrtcod
417bAC                   eval      $lrtara = lrtara
417bAC                   eval      $lrtwhd = lrtwhd
417bAC                   eval      $lrtasl = lrtasl
417bAC                   eval      $lrtloc = lrtloc
417bAC                   eval      $lrtlvl = lrtlvl
417bAC                   eval      $lrthnd = lrthnd
417bAC                   eval      $lrtslp = lrtslp
417bAC                   eval      $preturn = '*OK'
417bAC                   else
417bAC                   eval      $preturn = '*NOTFOUND'
417bAC                   endif

     C     endgetslot    endsr

500eA*----------------------------------------------------------------
500eA*  gettrack  Get tracking options.
500eA*
500eA*  Note: This does not get the item tracking level.
500eA*    Re: Subprogram assumes it is sent in and then just
500eA*        verifies it.
500eA*
500eA*----------------------------------------------------------------
500eA
500eAC     gettrack      begsr

     C                   eval      $lcmd = *blanks
     C                   eval      $lprg = #pgm
     C                   eval      $lwhse2 = $lrwhse

     C                   call      'GETTRACK'
     C                   parm                    $lparm

     C                   eval      trackpos    = $ltrackpos
     C                   eval      trackposmrg = $lposmrg
     C                   eval      trackposrtn = $lposrtn
     C                   eval      trackpsplit  = $lpsplit
     C                   eval      tracktsplit  = $ltsplit

     C                   endsr

     *----------------------------------------------------------------
     *  inzchkflds  Initialize check fields.
     *----------------------------------------------------------------

     C     inzchkflds    begsr

     C                   eval      $lrwhsee = $driok
     C                   eval      $lrltrne = $driok
500eDC**                 eval      $lracfle = $driok
500eMC                   eval      $lrstate = $driok
     C                   eval      $lrnodee = $driok
     C                   eval      $lrtrn#e = $driok
     C                   eval      $lrlbl#e = $driok
     C                   eval      $lrlcnse = $driok
     C                   eval      $lrflice = $driok
     C                   eval      $lrolice = $driok
     C                   eval      $lrlqy1e = $driok
     C                   eval      $lrlqy2e = $driok
     C                   eval      $lrlqy3e = $driok
     C                   eval      $lraqy1e = $driok
     C                   eval      $lraqy2e = $driok
     C                   eval      $lraqy3e = $driok
     C                   eval      $lrfcode = $driok
     C                   eval      $lrfarae = $driok
     C                   eval      $lrfwhde = $driok
     C                   eval      $lrfdspe = $driok
     C                   eval      $lrfasle = $driok
     C                   eval      $lrfloce = $driok
     C                   eval      $lrflvle = $driok
     C                   eval      $lrfhnde = $driok
500eAC                   eval      $lrfbasee = $driok
     C                   eval      $lrfslpe = $driok
     C                   eval      $lrfitme = $driok
500eAC                   eval      $lrfitmse = $driok
500eAC                   eval      $lrfitype = $driok
     C                   eval      $lrtcode = $driok
     C                   eval      $lrtarae = $driok
     C                   eval      $lrtwhde = $driok
     C                   eval      $lrtdspe = $driok
     C                   eval      $lrtasle = $driok
     C                   eval      $lrtloce = $driok
     C                   eval      $lrtlvle = $driok
     C                   eval      $lrthnde = $driok
500eAC                   eval      $lrtbasee = $driok
     C                   eval      $lrtslpe = $driok
     C                   eval      $lrtitme = $driok
500eAC                   eval      $lrtitype = $driok
500eAC                   eval      $lrtitmse = $driok
     C                   eval      $lrtorde = $driok
     C                   eval      $lrtseqe = $driok
     C                   eval      $lrexcde = $driok

     C                   endsr

500nA*----------------------------------------------------------------
500nA*  look4match  See if there is an active record a that matches
500nA*              sent whse/whdp/aisl/loc/lvl/item information.
500nA*----------------------------------------------------------------
500nA
500nAC     look4match    begsr
600bAC                   eval      currRoutine = 'look4match'
600bAC                   exsr      phpgmV1V2V3s
     C                   eval      error = *off
     C                   exsr      getcurrstamp
500vA
500vA*  Only look for match when working with slots.
500vA
500vAC     $lrtcod       cabne     'S'           endlook4match

     *  Open file.

     C                   exsr      fileopenlh7
     C     error         cabeq     *on           endlook4match

     *  Look for an Active record where To info matches sent info.

     C                   eval      #matchfound  = *off
     C                   eval      #matchlrlqy1 = 0
     C                   eval      #matchlrlqy2 = 0
     C                   eval      #matchlrlqy3 = 0

     C     lr7key        setll     lichist7
     C                   dow       forever = forever
     C     lr7key        reade     lichist7                             78

     C                   if        %eof(lichist7)
     C                   leave
     C                   endif

     *    Skip locked records

     C                   if        *in78
     C                   iter
     C                   endif

     *    Match found.

     *      Save information.

     C                   eval      #matchfound = *on
     C                   eval      #matchlrlcns  = lrlcns
     C                   eval      #matchlrtcod  = lrtcod
     C                   eval      #matchlrtara  = lrtara
     C                   eval      #matchlrtwhd  = lrtwhd
     C                   eval      #matchlrtdsp  = lrtdsp
     C                   eval      #matchlrtasl  = lrtasl
     C                   eval      #matchlrtloc  = lrtloc
     C                   eval      #matchlrtlvl  = lrtlvl
     C                   eval      #matchlrthnd  = lrthnd
     C                   eval      #matchlrtbase = lrtbase
     C                   eval      #matchlrtslp  = lrtslp
     C                   eval      #matchlrtitm  = lrtitm
     C                   eval      #matchlrtityp = lrtityp
     C                   eval      #matchlrtitms = lrtitms
     C                   eval      #matchlrlqy1  = #matchlrlqy1 + lrlqy1
     C                   eval      #matchlrlqy2  = #matchlrlqy2 + lrlqy2
     C                   eval      #matchlrlqy3  = #matchlrlqy3 + lrlqy3

     *      Inactivate record.

     C                   eval      lrstat = 'I '
     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
     C                   update    lrrec7
600bAC                   eval      currFile = 'lrrec7'
600bAC                   exsr      phUpdV1V2V3V4

     C                   enddo

600bAC     endlook4match tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500gA*----------------------------------------------------------------
500gA*  merge
500gA*
500gA*    Merge records that match the item/slot sent in, if any.
500gA*
500nA*    **** NOT USED ****
500gA*
500gA*----------------------------------------------------------------
500gA
500gAC     merge         begsr
600bAC                   eval      currRoutine = 'merge'
600bAC                   exsr      phpgmV1V2V3s
100bMC                   eval      error = *off
100bMC                   exsr      getcurrstamp

     *  Open file.

     C                   exsr      fileopenlh7
     C     error         cabeq     *on           endmerge

     *  First see if multiple records exsist for slot/item/pos.

     C                   eval      count = 0
     C     lr7key        setll     lichist7
     C                   dow       forever = forever
     C     lr7key        reade     lichist7                             78

     C                   if        %eof(lichist7)
     C                   leave
     C                   endif

     *    Skip locked records

     C                   if        *in78
     C                   iter
     C                   endif

     *    Skip pallets that are on the floor.

     C                   if        lrtcod = 'F'
     C                   iter
     C                   endif

     *    Usable record, increment count.

     C                   eval      count = count + 1

     C                   enddo

     *  If count <= 1 then there is nothing to merge.

     C     count         cable     1             endmerge

     *  Otherwise, merge the records.
417lA
     *    Initialize merge totals.

417lAC                   eval      count = 0

417lAC                   eval      mergelqy1 = 0
417lAC                   eval      mergelqy2 = 0
417lAC                   eval      mergelqy3 = 0

     *    Loop through records and merge.

     C     lr7key        setll     lichist7
     C                   dow       forever = forever
     C     lr7key        reade     lichist7                             78

     C                   if        %eof(lichist7)
     C                   leave
     C                   endif

     *      Skip locked records

     C                   if        *in78
     C                   iter
     C                   endif

     *      Skip pallets that are on the floor.

     C                   if        lrtcod = 'F'
     C                   iter
     C                   endif

     *      Mark current record as inactive.

500eMC                   eval      lrstat = 'I '
     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
     C                   update    lrrec7
600bAC                   eval      currFile = 'lrrec7'
600bAC                   exsr      phUpdV1V2V3V4

     *      Create new record showing quantity going into Merge license.
     *      Note, this record is created as inactive because the result
     *      of this routine is a new single merge license record.

500eMC                   eval      lrstat = 'I '
500qAC                   eval      lrexcd = ' '

     *        Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#

     *        First time throught, get new license plate for merge record.

     C                   eval      count = count + 1
     C                   if        count = 1
     C                   eval      $lrlcns = '*MG'
     C                   exsr      zzchklcns
     C                   endif

     *        Update From info with To info from original record.
     *        Note, the To information stays the same.

500aAC                   eval      lrflic = lrlcns
     C                   eval      lrfcod = lrtcod
     C                   eval      lrfara = lrtara
     C                   eval      lrfwhd = lrtwhd
     C                   eval      lrfdsp = lrtdsp
500eAC                   eval      lrfbase = lrtbase
     C                   eval      lrfasl = lrtasl
     C                   eval      lrfloc = lrtloc
     C                   eval      lrflvl = lrtlvl
     C                   eval      lrfhnd = lrfhnd
417aAC                   eval      lrfslp = lrtslp
417aAC                   eval      lrfitm = lrtitm
500eAC                   eval      lrfityp = lrtityp
500eAC                   eval      lrfitms = lrtitms

     *        Set new license number.

500aAC                   eval      lrlcns = $lrlcns

     *        Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *        Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '
417lA
417lA*        Update thread.
417lA
417lAC                   if        debugnode
417lAC                   move      '       '     lrnode
417lAC                   endif
417lA
417lAC                   eval      lrnode = %trimr(lrnode) + '1'
417lA
417lAC                   if        debugnode
417lAC                   move      'merge  '     lrnode
417lAC                   endif

     C                   write     lrrec7
600bAC                   eval      currFile = 'lrrec7'
600bAC                   exsr      phWrtV1V2V3V4
417lA
417lA*        Add quantities to merge totals
417lA
417lAC                   eval      mergelqy1 = mergelqy1 + lrlqy1
417lAC                   eval      mergelqy2 = mergelqy2 + lrlqy2
417lAC                   eval      mergelqy3 = mergelqy3 + lrlqy3

     C                   enddo

     *    Create new merge record.

     *      Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
500eMC                   eval      lrstat = 'A '

     *      Update From info with To info from original record.
     *      Note, most From fields remembered from last record written.

500aAC                   eval      lrflic = $lrlcns
     C                   eval      lrfcod = 'M'
     C                   eval      lrfara = 'Merge'
417lA
417lAC                   eval      lrlqy1 = mergelqy1
417lAC                   eval      lrlqy2 = mergelqy2
417lAC                   eval      lrlqy3 = mergelqy3

500sAC                   exsr      fixbrkdn

     *      Set new license number.

500aAC                   eval      lrlcns = $lrlcns

     *      Because we can't have more than one original license number,
     *      set the original license number to the new merge license.

500aAC                   eval      lrolic = $lrlcns

     *      Update Added by info for new record.

100bMC                   exsr      getcurrstamp

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *      Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '
417lA
417lA*      Update thread.
417lA
417lAC                   if        debugnode
417lAC                   move      '       '     lrnode
417lAC                   endif
417lA
417lAC                   eval      lrnode = %trimr(lrnode) + '1'
417lA
417lAC                   if        debugnode
417lAC                   move      'merge  '     lrnode
417lAC                   endif

500qAC                   eval      lrexcd = ' '
     C                   write     lrrec7
600bAC                   eval      currFile = 'lrrec7'
600bAC                   exsr      phWrtV1V2V3V4
417lA
600bAC     endmerge      tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  movback
     *
417bA*    Move back items in push-back slot to make room in front.
     *
     *----------------------------------------------------------------

     C     movback       begsr
600bAC                   eval      currRoutine = 'movback'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh3
     C     error         cabeq     *on           endmovback
417bA
500 DC**   lr3key        setll     lichist3
500 MC     lr3key        setgt     lichist3
417bAC                   dow       forever = forever
500 DC**   lr3key        reade     lichist3                             78
500 MC     lr3key        readpe    lichist3                             78
417bAC                   select
417bAC                   when      %eof(lichist3)
417bAC                   leave
500 A
500 A*  Skip locked records
500 A
500 AC                   when      *in78
500 AC                   iter
417bA
417bA*  Skip pallets that are on the floor.
417bA
417bAC                   when      lrtcod = 'F'
417bAC                   iter
417iA
417iA*  Skip pallets with a position of 0.
417bA
417iAC                   when      lrtslp = 0
417iAC                   iter
417bA
417bAC                   other
417bAC                   eval      lrtslp = lrtslp + 1
417bAC                   update    lrrec3
600bAC                   eval      currFile = 'lrrec3'
600bAC                   exsr      phUpdV1V2V3V4
417bA
417bAC                   endsl
417bAC                   enddo

600bAC     endmovback    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500 A*----------------------------------------------------------------
500 A*  movbackf
500 A*
500 A*    Move back items on floor.
500 A*
500 A*----------------------------------------------------------------
500 A
500 AC     movbackf      begsr
600bAC                   eval      currRoutine = 'movbackf'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh3
     C     error         cabeq     *on           endmovbackf

     C     lr3key        setgt     lichist3
     C                   dow       forever = forever
     C     lr3key        readpe    lichist3
     C                   select
     C                   when      %eof(lichist3)
     C                   leave

     *  Skip pallets that are in slot

     C                   when      lrtcod = 'S'
     C                   iter

     *  Skip pallets with a position of 0.

     C                   when      lrtslp = 0
     C                   iter

     C                   other
     C                   eval      lrtslp = lrtslp + 1
     C                   update    lrrec3
600bAC                   eval      currFile = 'lrrec3'
600bAC                   exsr      phUpdV1V2V3V4

     C                   endsl
     C                   enddo

600bAC     endmovbackf   tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  movefwd
     *
417cA*    Move back items in push-back slot to make room in front.
     *
     *----------------------------------------------------------------

     C     movefwd       begsr
600bAC                   eval      currRoutine = 'movefwd'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh3
     C     error         cabeq     *on           endmovefwd
417cA
500 DC**   lr3akey       setgt     lichist3
500 MC     lr3key        setll     lichist3
417cAC                   dow       forever = forever
500 DC**   lr3key        readpe    lichist3
500 AC     lr3key        reade     lichist3
417cAC                   select
417cAC                   when      %eof(lichist3)
417cAC                   leave
417cA
417bA*  Skip pallets that are on the floor.
417cA
417bAC                   when      lrtcod = 'F'
417bAC                   iter
417iA
417iA*  Skip pallets with a position of 0.
417cA
417iAC                   when      lrtslp = 0
417iAC                   iter
417bA
417cAC                   other
417cAC                   eval      lrtslp = lrtslp - 1
417cAC                   update    lrrec3
600bAC                   eval      currFile = 'lrrec3'
600bAC                   exsr      phUpdV1V2V3V4
417cA
417cAC                   endsl
417cAC                   enddo

600bAC     endmovefwd    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500 A*----------------------------------------------------------------
500 A*  movefwdf
500 A*
500 A*    Move back items on floor.
500 A*
500 A*----------------------------------------------------------------
500 A
500 AC     movefwdf      begsr
600bAC                   eval      currRoutine = 'movefwdf'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh3
     C     error         cabeq     *on           endmovefwdf

     C     lr3key        setll     lichist3
     C                   dow       forever = forever
     C     lr3key        reade     lichist3
     C                   select
     C                   when      %eof(lichist3)
     C                   leave

     *  Skip pallets that are in slot

     C                   when      lrtcod = 'S'
     C                   iter

     *  Skip pallets with a position of 0.

     C                   when      lrtslp = 0
     C                   iter

     C                   other
     C                   eval      lrtslp = lrtslp - 1
     C                   update    lrrec3
600bAC                   eval      currFile = 'lrrec3'
600bAC                   exsr      phUpdV1V2V3V4

     C                   endsl
     C                   enddo

600bAC     endmovefwdf   tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  newlic#
     *
     *    Verify license plate/ lot number doesn't exist.
     *
     *----------------------------------------------------------------

     C     newlic#       begsr

     C     lrkey         setll     lichist                                50
 2B  C                   if        *in50 = *on
     C                   eval      $preturn = '*FOUND'
     C                   else
     C                   eval      $preturn = '*NOTFOUND'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  newlot#
     *
     *    Verify lot number doesn't exist.
     *
     *----------------------------------------------------------------

     C     newlot#       begsr

     C     lrkey         setll     lichist                                50
 2B  C                   if        *in50 = *on
     C                   eval      $preturn = '*FOUND'
     C                   else
     C                   eval      $preturn = '*NOTFOUND'
     C                   endif

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  missinglp
500 A*
500 A*    License plate missing (could not be verified)
500 A*
500 A*----------------------------------------------------------------
500 A
500 AC     missinglp     begsr
600bAC                   eval      currRoutine = 'missinglp'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endmissinglp

     C     lrkey         setll     lichist1
     C     lrkey         reade     lichist1
     C                   if        not %eof
500eDC**                 eval      lracfl = 'I '
500eMC                   eval      lrstat = 'I '

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4

     *  Create new license record to show in transit from slot to
     *  new location. To code will still show unknown because we
     *  won't know for sure thats where the product is until the
     *  transaction is closed.
     *
     *    - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
     C                   move      nxtlp#        temp7a
     C                   eval      lrlcns = '*ML' + temp7a
     C                   eval      lrolic = lrlcns
500eDC**                 eval      lracfl = 'A '
500eMC                   eval      lrstat = 'A '
500qAC                   eval      lrexcd = ' '

     *    - Update From info with To info from original record.

     C                   eval      lrfcod = lrtcod
     C                   eval      lrfara = lrtara
     C                   eval      lrfwhd = lrtwhd
500kAC                   eval      lrfdsp = lrtdsp
500kAC                   eval      lrfbase = lrtbase
     C                   eval      lrfasl = lrtasl
     C                   eval      lrfloc = lrtloc
     C                   eval      lrflvl = lrtlvl
     C                   eval      lrfhnd = lrthnd
     C                   eval      lrfslp = lrtslp
500kAC                   eval      lrfitm = lrtitm
500kAC                   eval      lrfityp = lrtityp
500kAC                   eval      lrfitms = lrtitms

     *    - To info stays the same because item hasn't moved.

     *    - Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *    - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '

     *    - Thread doesn't change when recording a missing LP.

     C                   if        debugnode
     C                   move      'misslp'      lrnode
     C                   endif

     C                   write     lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phWrtV1V2V3V4
     C                   endif

600bAC     endmissinglp  tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

417hA*----------------------------------------------------------------
417hA*  PULL     Pull license out of slot.
417hA*----------------------------------------------------------------
417hA
417hAC     pull          begsr
600bAC                   eval      currRoutine = 'pull'
600bAC                   exsr      phpgmV1V2V3s

500 A*  First, move existing floor licenses back.
500 A
500 AC                   exsr      movbackf

500 M*  Then, pull license out of slot and put on floor.

500 MC                   exsr      pull2
500lA
500lA*  If nothing updated, then reverse the move done above.
500lA
500lAC                   if        not locupdated
500lAC                   exsr      movefwdf
500lAC                   endif

417jM*  Next, move existing slot licenses forward.

     C                   exsr      movefwd

600bAC                   exsr      phpgmV1V2V3e
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  pull2
500 A*
500 A*    Pull all license plates from a specific location.
500 A*
500 A*----------------------------------------------------------------
500 A
500 AC     pull2         begsr
600bAC                   eval      currRoutine = 'pull2'
600bAC                   exsr      phpgmV1V2V3s
500bAC                   eval      error = *off
500bAC                   exsr      getcurrstamp
500lAC                   eval      locupdated = *off

     *  Open file.

     C                   exsr      fileopenlh3
     C     error         cabeq     *on           endpull2

     C                   eval      $lrtslp = 1
     C     lr3akey       setll     lichist3
     C                   dow       forever = forever
     C     lr3akey       reade     lichist3

     *  Only want to work with licenses in the slot.

     C                   select
     C                   when      %eof(lichist3)
     C                   leave
     C                   when      lrtcod <> 'S '
     C                   iter
     C                   endsl

     *  If the From and To locations are the same,
     *    Then just update the record.

     C                   if        lrfcod = lrtcod
     C                             and lrfara = lrtara
     C                             and lrfdsp = lrtdsp
500eAC                             and lrfbase = lrtbase

     C                   eval      lrtcod = 'F'
     C                   eval      lrtara = 'Floor'
     C                   eval      lrtslp = 1

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn

500lAC                   eval      locupdated = *on
     C                   update    lrrec3
     C                   if        %error
     C                   endif
600bAC                   eval      currFile = 'lrrec3'
600bAC                   exsr      phUpdV1V2V3V4

     C                   iter
     C                   endif

     *  Otherwise, if the From and To locations are not the same,
     *    Then create a new record going from slot to floor.

     *    Set current record to Inactive.

500eDC**                 eval      lracfl = 'I '
500eMC                   eval      lrstat = 'I '
     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
     C                   update    lrrec3
600bAC                   eval      currFile = 'lrrec3'
600bAC                   exsr      phUpdV1V2V3V4

     *    Create new license record to show moving license from the
     *    slot to the floor.
     *
     *      - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
500eDC**                 eval      lracfl = 'A '
500eMC                   eval      lrstat = 'A '
500qAC                   eval      lrexcd = ' '

     *      - Update From info with To info from original record.

     C                   if        $lrlcns <> $lrflic
     C                   eval      lrflic = $lrflic
500cAC                   else
500cAC                   eval      lrflic = lrlcns
     C                   endif

     C                   eval      lrfcod = lrtcod
     C                   eval      lrfara = lrtara
     C                   eval      lrfwhd = lrtwhd
     C                   eval      lrfasl = lrtasl
     C                   eval      lrfloc = lrtloc
     C                   eval      lrflvl = lrtlvl
     C                   eval      lrfhnd = lrthnd
     C                   eval      lrfdsp = lrtdsp
500eAC                   eval      lrfbase = lrtbase
     C                   eval      lrfslp = lrtslp
500kAC                   eval      lrfitm = lrtitm
500kAC                   eval      lrfitms = lrtitms
500kAC                   eval      lrfityp = lrtityp

     *    - Update To info with new destination info.

     C                   eval      lrtcod = 'F'
     C                   eval      lrtara = 'Floor'
     C                   eval      lrtslp = 1

     *    - Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *    - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '

     *    - Update thread.

     C                   if        debugnode
     C                   move      '       '     lrnode
     C                   endif

     C                   eval      lrnode = %trimr(lrnode) + '1'

     C                   if        debugnode
     C                   move      'pull2  '     lrnode
     C                   endif

500lAC                   eval      locupdated = *on
     C                   write     lrrec3
600bAC                   eval      currFile = 'lrrec3'
600bAC                   exsr      phWrtV1V2V3V4

     C                   iter

     C                   enddo

600bAC     endpull2      tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

417hA*----------------------------------------------------------------
417hA*  PUSH     Push license into slot.
417hA*----------------------------------------------------------------
417hA
417hAC     push          begsr
600bAC                   eval      currRoutine = 'push'
600bAC                   exsr      phpgmV1V2V3s

     *  First, move existing licenses back.

     C                   exsr      movback

     *  Next, add new license.

     C                   eval      $lrtcod = 'S'
     C                   eval      $lrtara = 'Slot'
     C                   eval      $lrtslp = 1
     C                   exsr      updloc
500lA
500lA*  If nothing updated, then reverse the move done above.
500lA
500lAC                   if        not locupdated
500lAC                   exsr      movefwd
500lAC                   endif
500 A
500 A*  Then, move floor pallets forward (if any).
500 A
500 AC                   exsr      movefwdf

600bAC                   exsr      phpgmV1V2V3e
     C                   endsr

417iA*----------------------------------------------------------------
417iA*  PUSHPAP  Push putaway into slot - Partial qty.
417iA*----------------------------------------------------------------
417iA
417iAC     pushpap       begsr
600bAC                   eval      currRoutine = 'pushpap'
600bAC                   exsr      phpgmV1V2V3s

     *  First, move existing licenses back.

     C                   exsr      movback

     *  Next, close partial putaway.

     C                   eval      $lrtcod = 'S'
     C                   eval      $lrtara = 'Slot'
     C                   eval      $lrtslp = 1
     C                   exsr      clsputp

600bAC                   exsr      phpgmV1V2V3e
     C                   endsr

417iA*----------------------------------------------------------------
417iA*  PUSHPAT  Push putaway into slot - Entire qty.
417iA*----------------------------------------------------------------
417iA
417iAC     pushpat       begsr
600bAC                   eval      currRoutine = 'pushpat'
600bAC                   exsr      phpgmV1V2V3s

     *  First, move existing licenses back.

     C                   exsr      movback

     *  Next, close entire putaway.

     C                   eval      $lrtcod = 'S'
     C                   eval      $lrtara = 'Slot'
     C                   eval      $lrtslp = 1
     C                   exsr      clsputt
500rDC**
500rDC** Then, move floor pallets forward (if any).
500rDC**
500rDC**                 exsr      movefwdf

600bAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  recgetlh  Get LICHIST record.
     *----------------------------------------------------------------

     C     recgetlh      begsr

     *  Open file.

     C                   exsr      fileopenlh
     C     error         cabeq     *on           endgetlh

     *  Get record.

     C                   eval      kywhse  = $lrwhse
     C                   eval      kytrn#  = $lrtrn#

     C                   if        lock1
     C*??? keylh         chain     lichist
     C                   else
     C*??? keylh         chain(n)  lichist
     C                   endif

     C                   if        %found
     C                   eval      found = *on
     C                   else
     C                   eval      found = *off
     C                   endif

     C     endgetlh      endsr

500pA*----------------------------------------------------------------
500pA*  rmvzero   Remove (Inactivate) record for a specific slot if
500pA*            all quantities are zero.
500pA*----------------------------------------------------------------
500pA
500pAC     rmvzero       begsr
600bAC                   eval      currRoutine = 'rmvzero'
600bAC                   exsr      phpgmV1V2V3s
     C                   eval      error = *off
     C                   exsr      getcurrstamp

     *  Open file.

     C                   exsr      fileopenlh7
     C     error         cabeq     *on           endrmvzero

     *  Look for an Active record where To info matches sent info.

     C                   eval      found = *off

     C     lr7key        setll     lichist7
     C                   dow       forever = forever
     C     lr7key        reade     lichist7                             78

     C                   if        %eof(lichist7)
     C                   leave
     C                   endif

     *    Skip locked records

     C                   if        *in78
     C                   iter
     C                   endif

     *    Skip record if quantity exists

     C                   if        lrlqy1 <> 0
     C                             or lrlqy2 <> 0
     C                             or lrlqy3 <> 0
     C                   iter
     C                   endif

     *    Match found with zero quantity - Inactivate record.

     C                   eval      lrstat = 'I '
     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
     C                   update    lrrec7
600bAC                   eval      currFile = 'lrrec7'
600bAC                   exsr      phUpdV1V2V3V4

     C                   eval      found = *on

     C                   enddo

     *  If record Inactivated, then skrunch pallet positions together.

     C                   if        found
     C                   exsr      scrunch
     C                   endif

600bAC     endrmvzero    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500pA*----------------------------------------------------------------
500pA*  rmvztrn   Remove (Inactivate) record for a specific slot if
500pA*            all quantities are zero, then do a RTNALL
500pA*----------------------------------------------------------------
500pA
500pAC     rmvzrtn       begsr
600bAC                   eval      currRoutine = 'rmvzrtn'
600bAC                   exsr      phpgmV1V2V3s

     C                   exsr      rmvzero
     C                   exsr      rtnall

600bAC     endrmvzrtn    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500 A*----------------------------------------------------------------
500 A*  RTNALL   Return all floor pallets to slot.
500 A*----------------------------------------------------------------
500 A
500 AC     rtnall        begsr
600bAC                   eval      currRoutine = 'rtnall'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

500gDC**                 exsr      fileopenlh5
500gMC                   exsr      fileopenlh3
     C     error         cabeq     *on           endrtnall

     *  Loop until no more floor pallets are found.

500gDC**   lr3key        setll     lichist5
500gMC     lr3key        setll     lichist3
     C                   dow       forever = forever
500gDC**   lr3key        reade(n)  lichist5
500gMC     lr3key        reade(n)  lichist3
     C                   select
500gDC**                 when      %eof(lichist5)
500gMC                   when      %eof(lichist3)
     C                   leave

     *    Skip pallets that are in the slot.

     C                   when      lrtcod = 'S'
     C                   iter

     *    Push pallet into slot.

     C                   other
     C                   eval      $lrtslp = lrtslp
     C                   exsr      push
500gDC**   lr3key        setll     lichist5
500gMC     lr3key        setll     lichist3

     C                   endsl

     C                   enddo

600bAC     endrtnall     tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500pA*----------------------------------------------------------------
500pA*  scrunch  scrunch pallet positions togther.
500pA*----------------------------------------------------------------
500pA
500pAC     scrunch       begsr
600bAC                   eval      currRoutine = 'scrunch'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh3
     C     error         cabeq     *on           endscrunch

     *  Scrunch pallets in slot and then any that are on the floor.

     C                   eval      currcod = ' '
     C                   dow       forever = forever

     C                   select
     C                   when      currcod = ' '
     C                   eval      currcod = 'S'
     C                   when      currcod = 'S'
     C                   eval      currcod = 'F'
     C                   other
     C                   leave
     C                   endsl

     *    Keep looping until nothing is scrunched.

     C                   dou       not scrunched
     C                   eval      scrunched = *off

     *      Try and scrunch recs for slot.

     C                   eval      currslp = 1
     C     lr3keyp       setll     lichist3
     C                   dow       forever = forever
     C     lr3key        reade     lichist3                             78

     C                   if        %eof(lichist3)
     C                   leave
     C                   endif

     *        If record is locked, get out.

     C                   if        *in78
     C                   leave
     C                   endif

     *        Skip pallets that don't match the current code.

     C                   if        lrtcod <> currcod
     C                   iter
     C                   endif

     *        If rec found with current slot position, move on to next pos.

     C                   if        lrtslp = currslp
     C                   eval      currslp = currslp + 1
     C     lr3keyp       setll     lichist3
     C                   iter
     C                   endif

     *        Otherwise, we found a hole so decrement slot position of rec

     C                   eval      lrtslp = lrtslp - 1
     C                   update    lrrec3
600bAC                   eval      currFile = 'lrrec3'
600bAC                   exsr      phUpdV1V2V3V4
     C                   eval      scrunched = *on

     C                   enddo

     C                   enddo

     C                   enddo

600bAC     endscrunch    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  undoput
     *
     *    Undo putaway. Transaction canceled.
     *
     *----------------------------------------------------------------

     C     undoput       begsr
600bAC                   eval      currRoutine = 'undoput'
600bAC                   exsr      phpgmV1V2V3s
500bAC                   eval      error = *off
500bAC                   exsr      getcurrstamp

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endundoput

     C     lrkey         setll     lichist1
     C     lrkey         reade     lichist1
 2B  C                   if        not %eof

     *  Update To info with From info.

     C                   eval      lrtcod = lrfcod
     C                   eval      lrtara = lrfara
500aAC                   eval      lrtitm = lrfitm
500eAC                   eval      lrtityp = lrfityp
500eAC                   eval      lrtitms = lrfitms

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4
     C                   endif

600bAC     endundoput    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500cA*----------------------------------------------------------------
500cA*  undorpl
500cA*
500cA*    Undo replenishment. Transaction canceled.
500cA*
500cA*----------------------------------------------------------------
500cA
500cAC     undorpl       begsr
600bAC                   eval      currRoutine = 'undorpl'
600bAC                   exsr      phpgmV1V2V3s
     C                   eval      error = *off
     C                   exsr      getcurrstamp

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endundorpl

     C     lrkey         setll     lichist1
     C     lrkey         reade     lichist1
     C                   if        not %eof
500hA
500hA*  Only update record if on Floor or in transit.
500hA
500hAC                   if        lrtcod <> 'F' and lrtcod <> '?'
500hAC                   unlock    lichist1
500hAC                   goto      endundorpl
500hAC                   endif

     *  Update To info with From info.

     C                   eval      lrtcod = lrfcod
     C                   eval      lrtara = lrfara
     C                   eval      lrtitm = lrfitm
500eAC                   eval      lrtityp = lrfityp
500eAC                   eval      lrtitms = lrfitms
     C                   eval      lrtwhd = lrfwhd
     C                   eval      lrtasl = lrfasl
     C                   eval      lrtloc = lrfloc
     C                   eval      lrtlvl = lrflvl
     C                   eval      lrthnd = lrfhnd
     C                   eval      lrtdsp = lrfdsp
500eAC                   eval      lrtbase = lrfbase
     C                   eval      lrtslp = lrfslp

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4
     C                   endif
500jA
500jA*  Return To info.
500jA
500jAC                   eval      $lrwhse  = lrwhse
500jAC                   eval      $lrtcod  = lrtcod
500jAC                   eval      $lrtara  = lrtara
500jAC                   eval      $lrtitm  = lrtitm
500jAC                   eval      $lrtityp = lrtityp
500jAC                   eval      $lrtitms = lrtitms
500jAC                   eval      $lrtwhd  = lrtwhd
500jAC                   eval      $lrtasl  = lrtasl
500jAC                   eval      $lrtloc  = lrtloc
500jAC                   eval      $lrtlvl  = lrtlvl
500jAC                   eval      $lrthnd  = lrthnd
500jAC                   eval      $lrtdsp  = lrtdsp
500jAC                   eval      $lrtbase = lrtbase
500jAC                   eval      $lrtslp  = lrtslp

600bAC     endundorpl    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  updloc
     *
417fA*    Update pushback pallet position and location.
     *
     *----------------------------------------------------------------

     C     updloc        begsr
600bAC                   eval      currRoutine = 'updloc'
600bAC                   exsr      phpgmV1V2V3s
500lAC                   eval      locupdated = *off

     *  Open file.

     C                   exsr      fileopenlh3
     C     error         cabeq     *on           endupdloc

500 DC**   lr3akey       setgt     lichist3
500 MC     lr3akey       setll     lichist3
417fAC                   dow       forever = forever
500 DC**   lr3akey       readpe    lichist3
500 MC     lr3akey       reade     lichist3
417fA
417fAC                   select
417fAC                   when      %eof(lichist3)
417fAC                   leave
417fA
417fA*  Moving pallet to floor. Update only pallets in slot.
417fA*  Moving pallet to slot. Update only pallets on floor.
417fA
417fAC                   when      $lrtcod = 'F ' and lrtcod <> 'S '
417fAC                             or $lrtcod = 'S ' and lrtcod <> 'F '
417fAC                   iter
417fA
417fAC                   other
417fA
417fAC                   eval      lrtcod = $lrtcod
417fAC                   eval      lrtara = $lrtara
417fAC                   eval      lrtslp = $lrtslp

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
417fA
500lAC                   eval      locupdated = *on
417fAC                   update    lrrec3
417fAC                   select
417fAC                   when      %error
417fA
417fA*  Log Exception
417fA
417fAC                   eval      $preturn = '*ERROR  '
417fAC                   endsl
600bAC                   eval      currFile = 'lrrec3'
600bAC                   exsr      phUpdV1V2V3V4
417fAC                   endsl
417fAC                   enddo

600bAC     endupdloc     tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

417iA*----------------------------------------------------------------
417iA*  updloc0  - Update pushback pallet location to zero.
417iA*----------------------------------------------------------------
417iA
417iAC     updloc0       begsr
600bAC                   eval      currRoutine = 'updloc0'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh3
     C     error         cabeq     *on           endupdloc0

500 DC**   lr3key        setgt     lichist3
500 MC     lr3key        setll     lichist3

     C                   dow       forever = forever
500 DC**   lr3key        readpe    lichist3
500 MC     lr3key        reade     lichist3
     C                   if        %eof(lichist3)
     C                   leave
     C                   endif

     *  Moving pallet to floor. Update only pallets in slot.
     *  Moving pallet to slot. Update only pallets on floor.

     C                   if        $lrtcod = 'F ' and lrtcod <> 'S '
     C                             or $lrtcod = 'S ' and lrtcod <> 'F '
     C                   iter
     C                   endif

     *  Set position to 0.

     C                   eval      lrtslp = 0
     C                   eval      lrtcod = $lrtcod
417fAC                   eval      lrtara = $lrtara

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn

     C                   update(e) lrrec3
     C                   if        %error
     C                   eval      $preturn = '*ERROR  '
     C                   endif
600bAC                   eval      currFile = 'lrrec3'
600bAC                   exsr      phUpdV1V2V3V4

     C                   enddo

600bAC     endupdloc0    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  updput
     *
     *    Update putaway to show in transit.
     *
     *----------------------------------------------------------------

     C     updput        begsr
600bAC                   eval      currRoutine = 'updput'
600bAC                   exsr      phpgmV1V2V3s
100bMC                   eval      error = *off
100bMC                   exsr      getcurrstamp

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endupdput

     C     lrkey         setll     lichist1
     C     lrkey         reade     lichist1

 2B  C                   if        not %eof
500eDC**                 eval      lracfl = 'I '
500eMC                   eval      lrstat = 'I '
     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4
     C                   else
     C                   clear                   lrrec
     C                   eval      lrwhse = $lrwhse
     C                   eval      lrlcns = $lrlcns
     C                   eval      lrtcod = '?'
     C                   eval      lrtara = 'Unknown'
     C                   eval      lrtitm = $lrtitm
500eAC                   eval      lrtityp = $lrtityp
500eAC                   eval      lrtitms = $lrtitms
     C                   eval      lrolic = $lrlcns
     C                   endif

     *  Create new license record to show in transit from dock to
     *  location unknown.
     *
     *  - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
500eDC**                 eval      lracfl = 'A '
500eMC                   eval      lrstat = 'A '
500qAC                   eval      lrexcd = ' '

     *  - Update From info with To info from original record.

500aAC                   eval      lrflic = lrlcns
     C                   eval      lrfcod = lrtcod
     C                   eval      lrfara = lrtara
     C                   eval      lrfwhd = lrtwhd
     C                   eval      lrfdsp = lrtdsp
500eAC                   eval      lrfbase = lrtbase
     C                   eval      lrfasl = lrtasl
     C                   eval      lrfloc = lrtloc
     C                   eval      lrflvl = lrtlvl
     C                   eval      lrfhnd = lrfhnd
417aAC                   eval      lrfslp = lrtslp
417aAC                   eval      lrfitm = lrtitm
500eAC                   eval      lrfityp = lrtityp
500eAC                   eval      lrfitms = lrtitms

     *  - Update To info for new record.

     C                   eval      lrtcod = $lrtcod

416aAC                   if        $lrtarau
     C                   eval      lrtara = $lrtara
     C                   else
     C                   eval      lrtara = ' '
416aAC                   endif

416aAC                   if        $lrtwhdu
     C                   eval      lrtwhd = $lrtwhd
     C                   else
     C                   eval      lrtwhd = ' '
416aAC                   endif

416aAC                   if        $lrtdspu
     C                   eval      lrtdsp = $lrtdsp
     C                   else
     C                   eval      lrtdsp = ' '
416aAC                   endif

416aAC                   if        $lrtaslu
     C                   eval      lrtasl = $lrtasl
     C                   else
     C                   eval      lrtasl = ' '
416aAC                   endif

416aAC                   if        $lrtlocu
     C                   eval      lrtloc = $lrtloc
     C                   else
     C                   eval      lrtloc = 0
416aAC                   endif

416aAC                   if        $lrtlvlu
     C                   eval      lrtlvl = $lrtlvl
     C                   else
     C                   eval      lrtlvl = 0
416aAC                   endif

416aAC                   if        $lrthndu
     C                   eval      lrthnd = $lrthnd
     C                   else
     C                   eval      lrthnd = ' '
416aAC                   endif

500eAC                   if        $lrtbaseu
500eAC                   eval      lrtbase = $lrtbase
500eAC                   else
500eAC                   eval      lrtbase = ' '
500eAC                   endif

416aAC                   if        $lrtslpu
     C                   eval      lrtslp = $lrtslp
     C                   else
     C                   eval      lrtslp = 0
416aAC                   endif

416aAC                   if        $lrtitmu
     C                   eval      lrtitm = $lrtitm
     C                   else
500mDC**                 eval      lrtitm = ' '
500mMC                   eval      lrtitm = lrfitm
416aAC                   endif

500eAC                   if        $lrtitypu
500eAC                   eval      lrtityp = $lrtityp
500eAC                   else
500mDC**                 eval      lrtityp = ' '
500mMC                   eval      lrtityp = lrfityp
500eAC                   endif

500eAC                   if        $lrtitmsu
500eAC                   eval      lrtitms = $lrtitms
500eAC                   else
500mDC**                 eval      lrtitms = ' '
500mMC                   eval      lrtitms = lrfitms
500eAC                   endif

     *  - Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *  - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '
417lA
417lA*  - Update thread.
417lA
417lAC                   if        debugnode
417lAC                   move      '       '     lrnode
417lAC                   endif
417lA
417lAC                   eval      lrnode = %trimr(lrnode) + '1'
417lA
417lAC                   if        debugnode
417lAC                   move      'updput '     lrnode
417lAC                   endif

     C                   write     lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phWrtV1V2V3V4

600bAC     endupdput     tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  updrplp
     *
     *    Update replenishment to show in transit. Partial qty.
     *
     *----------------------------------------------------------------

     C     updrplp       begsr
600bAC                   eval      currRoutine = 'updrplp'
600bAC                   exsr      phpgmV1V2V3s
100bMC                   eval      error = *off
100bMC                   exsr      getcurrstamp

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endupdrplp

500 DC**   lrkey         setll     lichist1
500 DC**   lrkey         reade     lichist1
500 MC     lrkeyrpl      setll     lichist1
500 MC     lrkeyrpl      reade     lichist1

500 AC                   select

500 MC                   when      %eof
     C                   clear                   lrrec
     C                   eval      lrwhse = $lrwhse
500 DC**                 eval      lrlcns = $lrlcns
500 MC                   eval      lrlcns = $lrflic
     C                   eval      lrtcod = '?'
     C                   eval      lrtara = 'Unknown'
     C                   exsr      updrplpother

500 AC                   when      lrtcod = 'F'
500qAC                             or lrtcod = '?'
500 AC                             or lrfcod = lrtcod
500 AC                                and lrfara = lrtara
500 AC                                and lrfdsp = lrtdsp
500 AC                   exsr      updrplpfloor

500 AC                   other
500 AC                   exsr      updrplpother

500 AC                   endsl

500eA*  Send back "in transit" license.
500eA
500eAC                   eval      $lrlcns = lic4tfrqty

600bAC     endupdrplp    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500 A*----------------------------------------------------------------
500 A*  updrplpfloor
500 A*
500 A*    Update replenishment to show in transit. Partial qty.
500 A*    License is coming from Floor or From/To info is the same.
500 A*    Therefore, a new rec was already created when it was pulled.
500 A*    Therefore, update the quantity of the current record.
500 A*      and create a new record for transit.
500 A*
500 A*----------------------------------------------------------------
500 A
500 AC     updrplpfloor  begsr
600bAC                   eval      currRoutine = 'updrplpfloor'
600bAC                   exsr      phpgmV1V2V3s
     C                   eval      error = *off
500eA
500eA*  Determine where the current and new LP's should go.
500eA
500eAC                   if        tracktsplit = '3'
500eAC                   exsr      gettrack
500eAC                   endif
500eA
500eAC                   select
500eA
500eA*    Current LP goes with Tfr qty
500eA*    and Remaining qty gets new LP, which will be generated later.
500eA
500eAC                   when      tracktsplit = '2'
500eAC                   eval      lic4tfrqty = lrlcns
500eAC                   eval      lic4rmnqty = '*NEW/$LRLCNS*'
500eA
500eA*    Otherwise ...
500eA*      Current LP stays with Remaining qty
500eA*      and Tfr qty gets new LP, which will be generated later.
500eA
500eAC                   other
500eAC                   eval      lic4rmnqty = lrlcns
500eAC                   eval      lic4tfrqty = '*NEW/$LRLCNS*'
500eA
500eAC                   endsl

     *  Update the current rec with the qty being left.

     C                   eval      lrlqy1 = lrlqy1 - $lrlqy1
     C                   eval      lrlqy2 = lrlqy2 - $lrlqy2
     C                   eval      lrlqy3 = lrlqy3 - $lrlqy3

500sAC                   exsr      fixbrkdn

500 DC**                 eval      lraqy1 = lraqy1 + $lrlqy1
500 DC**                 eval      lraqy2 = lraqy2 + $lrlqy2
500 DC**                 eval      lraqy3 = lraqy3 + $lrlqy3

500 MC                   eval      lraqy1 = lraqy1 - $lrlqy1
500 MC                   eval      lraqy2 = lraqy2 - $lrlqy2
500 MC                   eval      lraqy3 = lraqy3 - $lrlqy3

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn

500eA*  Update the current rec license that is to stay with the
500eA*  remaining qty.
500eA
500eAC                   if        lic4rmnqty = '*NEW/$LRLCNS*'
500eAC                   exsr      zzchklcns
500eAC                   eval      lic4rmnqty = $lrlcns
500eAC                   endif
500eA
500eAC                   eval      lrlcns = lic4rmnqty

     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4

     *  Create second record:

     *  Second record will hold qty that is being transfered.
     *  To code will show location unknown until transaction
     *  is closed.

     *   - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
500eDC**                 eval      lracfl = 'A '
500eMC                   eval      lrstat = 'A '
500qAC                   eval      lrexcd = ' '

     *   - Update To info with new destination info.

500eDC**                 exsr      zzchklcns
500eDC**                 eval      lrlcns = $lrlcns
500eA
500eAC                   if        lic4tfrqty = '*NEW/$LRLCNS*'
500eAC                   exsr      zzchklcns
500eAC                   eval      lic4tfrqty = $lrlcns
500eAC                   endif
500eA
500eMC                   eval      lrlcns = lic4tfrqty

     C                   eval      lrtcod = $lrtcod

416aAC                   if        $lrtarau
     C                   eval      lrtara = $lrtara
     C                   else
     C                   eval      lrtara = ' '
416aAC                   endif

416aAC                   if        $lrtwhdu
     C                   eval      lrtwhd = $lrtwhd
     C                   else
     C                   eval      lrtwhd = ' '
416aAC                   endif

416aAC                   if        $lrtdspu
     C                   eval      lrtdsp = $lrtdsp
     C                   else
     C                   eval      lrtdsp = ' '
416aAC                   endif

416aAC                   if        $lrtaslu
     C                   eval      lrtasl = $lrtasl
     C                   else
     C                   eval      lrtasl = ' '
416aAC                   endif

416aAC                   if        $lrtlocu
     C                   eval      lrtloc = $lrtloc
     C                   else
     C                   eval      lrtloc = 0
416aAC                   endif

416aAC                   if        $lrtlvlu
     C                   eval      lrtlvl = $lrtlvl
     C                   else
     C                   eval      lrtlvl = 0
416aAC                   endif

416aAC                   if        $lrthndu
     C                   eval      lrthnd = $lrthnd
     C                   else
     C                   eval      lrthnd = ' '
416aAC                   endif

500eAC                   if        $lrtbaseu
500eAC                   eval      lrtbase = $lrtbase
500eAC                   else
500eAC                   eval      lrtbase = ' '
500eAC                   endif

416aAC                   if        $lrtslpu
     C                   eval      lrtslp = $lrtslp
     C                   else
     C                   eval      lrtslp = 0
416aAC                   endif

416aAC                   if        $lrtitmu
     C                   eval      lrtitm = $lrtitm
     C                   else
500mDC**                 eval      lrtitm = ' '
500mMC                   eval      lrtitm = lrfitm
416aAC                   endif

500eAC                   if        $lrtitypu
500eAC                   eval      lrtityp = $lrtityp
500eAC                   else
500mDC**                 eval      lrtityp = ' '
500mMC                   eval      lrtityp = lrfityp
500eAC                   endif

500eAC                   if        $lrtitmsu
500eAC                   eval      lrtitms = $lrtitms
500eAC                   else
500mDC**                 eval      lrtitms = ' '
500mMC                   eval      lrtitms = lrfitms
500eAC                   endif

     *   - Update qty being transfered from current location.

     C                   eval      lrlqy1 = $lrlqy1
     C                   eval      lrlqy2 = $lrlqy2
     C                   eval      lrlqy3 = $lrlqy3

500sAC                   exsr      fixbrkdn

500nDC**                 eval      lraqy1 = 0
500nDC**                 eval      lraqy2 = 0
500nDC**                 eval      lraqy3 = 0

500nMC                   eval      lraqy1 = $lrlqy1
500nMC                   eval      lraqy2 = $lrlqy2
500nMC                   eval      lraqy3 = $lrlqy3

     *   - Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *   - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '
417lA
417lA*   - Update thread.
417lA
417lAC                   if        debugnode
417lAC                   move      '       '     lrnode
417lAC                   endif
417lA
500 DC**                 eval      lrnode = %trimr(lrnode) + '2'
500 AC                   eval      len = %len(%trimr(lrnode))
500vDC**                 eval      %subst(lrnode:len:1) = '2'
500vAC                   eval      temp1a = %subst(lrnode:len:1)
500vAC                   move      temp1a        temp1n
500vAC                   if        temp1n < 9
500vAC                   eval      temp1n = temp1n + 1
500vAC                   move      temp1n        temp1a
500vAC                   eval      %subst(lrnode:len:1) = temp1a
500vAC                   endif
417lA
417lAC                   if        debugnode
417lAC                   move      'updrplp'     lrnode
417lAC                   endif

     C                   write     lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phWrtV1V2V3V4

600bAC     endupdrplpflr tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500 A*----------------------------------------------------------------
500 A*  updrplpother
500 A*
500 A*    Update replenishment to show in transit. Partial qty.
500 A*    License is not coming from Floor.
500 A*    Therefore, create two new records.
500 A*
500 A*----------------------------------------------------------------
500 A
500 AC     updrplpother  begsr
600bAC                   eval      currRoutine = 'updrplpother'
600bAC                   exsr      phpgmV1V2V3s
     C                   eval      error = *off
500eA
500eA*  Determine where the current and new LP's should go.
500eA
500eAC                   if        tracktsplit = '3'
500eAC                   exsr      gettrack
500eAC                   endif
500eA
500eAC                   select
500eA
500eA*    Current LP goes with Tfr qty
500eA*    and Remaining qty gets new LP.
500eA
500eAC                   when      tracktsplit = '2'
500eAC                   eval      lic4tfrqty = lrlcns
500eAC                   exsr      zzchklcns
500eAC                   eval      lic4rmnqty = $lrlcns
500eA
500eA*    Otherwise ...
500eA*      Current LP stays with Remaining qty
500eA*      and Tfr qty gets new LP.
500eA
500eAC                   other
500eAC                   eval      lic4rmnqty = lrlcns
500eAC                   exsr      zzchklcns
500eAC                   eval      lic4tfrqty = $lrlcns
500eA
500eAC                   endsl

     *  Set current record to Inactive.

     C                   if        not %eof(lichist1)
500eDC**                 eval      lracfl = 'I '
500eMC                   eval      lrstat = 'I '
     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4
     C                   endif

     *  Create two new license records:
     *    First record will hold qty left in current location.
     *    Second record will hold qty that is being transfered.
     *  To code will show location unknown until transaction
     *  is closed.
     *
     *  Create first record for qty being left behind.
     *   - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
500eDC**                 eval      lracfl = 'A '
500eMC                   eval      lrstat = 'A '
500qAC                   eval      lrexcd = ' '

     *   - Update From info with To info from original record.

500eDC**                 if        $lrlcns <> $lrflic
500eDC**                 eval      lrflic = $lrflic
500eDC**                 endif
500eMC                   eval      lrflic = lic4rmnqty

     C                   eval      lrfcod = lrtcod
     C                   eval      lrfara = lrtara
     C                   eval      lrfdsp = lrtdsp
     C                   eval      lrfwhd = lrtwhd
     C                   eval      lrfasl = lrtasl
     C                   eval      lrfloc = lrtloc
     C                   eval      lrflvl = lrtlvl
     C                   eval      lrfhnd = lrthnd
500eAC                   eval      lrfbase = lrtbase
417aAC                   eval      lrfslp = lrtslp
500kAC                   eval      lrfitm = lrtitm
500kAC                   eval      lrfityp = lrtityp
500kAC                   eval      lrfitms = lrtitms

     *   - Update qty being left in current location.

     C                   eval      lrlqy1 = lrlqy1 - $lrlqy1
     C                   eval      lrlqy2 = lrlqy2 - $lrlqy2
     C                   eval      lrlqy3 = lrlqy3 - $lrlqy3

500sAC                   exsr      fixbrkdn

500 DC**                 eval      lraqy1 = lraqy1 + $lrlqy1
500 DC**                 eval      lraqy2 = lraqy2 + $lrlqy2
500 DC**                 eval      lraqy3 = lraqy3 + $lrlqy3

500 MC                   eval      lraqy1 = lraqy1 - $lrlqy1
500 MC                   eval      lraqy2 = lraqy2 - $lrlqy2
500 MC                   eval      lraqy3 = lraqy3 - $lrlqy3

     *   - Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *   - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '
417lA
417lA*   - Update thread.
417lA
417lAC                   if        debugnode
417lAC                   move      '       '     lrnode
417lAC                   endif
417lA
417lAC                   eval      lrnode = %trimr(lrnode) + '1'
417lA
417lAC                   if        debugnode
417lAC                   move      'updrplp'     lrnode
417lAC                   endif

     C                   write     lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phWrtV1V2V3V4

     *  Create 2nd record.
     *   - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
500eDC**                 eval      lracfl = 'A '
500eMC                   eval      lrstat = 'A '
500qAC                   eval      lrexcd = ' '

     *   - Update To info with new destination info.

500eDC**                 exsr      zzchklcns
500eDC**                 eval      lrlcns = $lrlcns
500eMC                   eval      lrlcns = lic4tfrqty

     C                   eval      lrtcod = $lrtcod

416aAC                   if        $lrtarau
     C                   eval      lrtara = $lrtara
     C                   else
     C                   eval      lrtara = ' '
416aAC                   endif

416aAC                   if        $lrtwhdu
     C                   eval      lrtwhd = $lrtwhd
     C                   else
     C                   eval      lrtwhd = ' '
416aAC                   endif

416aAC                   if        $lrtdspu
     C                   eval      lrtdsp = $lrtdsp
     C                   else
     C                   eval      lrtdsp = ' '
416aAC                   endif

416aAC                   if        $lrtaslu
     C                   eval      lrtasl = $lrtasl
     C                   else
     C                   eval      lrtasl = ' '
416aAC                   endif

416aAC                   if        $lrtlocu
     C                   eval      lrtloc = $lrtloc
     C                   else
     C                   eval      lrtloc = 0
416aAC                   endif

416aAC                   if        $lrtlvlu
     C                   eval      lrtlvl = $lrtlvl
     C                   else
     C                   eval      lrtlvl = 0
416aAC                   endif

416aAC                   if        $lrthndu
     C                   eval      lrthnd = $lrthnd
     C                   else
     C                   eval      lrthnd = ' '
416aAC                   endif

500eAC                   if        $lrtbaseu
500eAC                   eval      lrtbase = $lrtbase
500eAC                   else
500eAC                   eval      lrtbase = ' '
500eAC                   endif

416aAC                   if        $lrtslpu
     C                   eval      lrtslp = $lrtslp
     C                   else
     C                   eval      lrtslp = 0
416aAC                   endif

416aAC                   if        $lrtitmu
     C                   eval      lrtitm = $lrtitm
     C                   else
500mDC**                 eval      lrtitm = ' '
500mMC                   eval      lrtitm = lrfitm
416aAC                   endif

500eAC                   if        $lrtitypu
500eAC                   eval      lrtityp = $lrtityp
500eAC                   else
500mDC**                 eval      lrtityp = ' '
500mMC                   eval      lrtityp = lrfityp
500eAC                   endif

500eAC                   if        $lrtitmsu
500eAC                   eval      lrtitms = $lrtitms
500eAC                   else
500mDC**                 eval      lrtitms = ' '
500mMC                   eval      lrtitms = lrfitms
500eAC                   endif

     *   - Update qty being transfered from current location.

     C                   eval      lrlqy1 = $lrlqy1
     C                   eval      lrlqy2 = $lrlqy2
     C                   eval      lrlqy3 = $lrlqy3

500sAC                   exsr      fixbrkdn

     C                   eval      lraqy1 = 0
     C                   eval      lraqy2 = 0
     C                   eval      lraqy3 = 0

     *   - Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *   - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '
417lA
417lA*   - Update thread.
417lA
417lAC                   if        debugnode
417lAC                   move      '       '     lrnode
417lAC                   endif
417lA
500 DC**                 eval      lrnode = %trimr(lrnode) + '2'
500 AC                   eval      len = %len(%trimr(lrnode))
500vDC**                 eval      %subst(lrnode:len:1) = '2'
500vAC                   eval      temp1a = %subst(lrnode:len:1)
500vAC                   move      temp1a        temp1n
500vAC                   if        temp1n < 9
500vAC                   eval      temp1n = temp1n + 1
500vAC                   move      temp1n        temp1a
500vAC                   eval      %subst(lrnode:len:1) = temp1a
500vAC                   endif
417lA
417lAC                   if        debugnode
417lAC                   move      'updrplp'     lrnode
417lAC                   endif

     C                   write     lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phWrtV1V2V3V4

600bAC     endupdrplpoth tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  updrplt
     *
     *    Update replenishment to show in transit. Entire qty.
     *
500nA*    **** NOT USED ****
     *
     *----------------------------------------------------------------

     C     updrplt       begsr
600bAC                   eval      currRoutine = 'updrplt'
600bAC                   exsr      phpgmV1V2V3s
500bAC                   eval      error = *off
500bAC                   exsr      getcurrstamp

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endupdrplt

500 DC**   lrkey         setll     lichist1
500 DC**   lrkey         reade     lichist1
500 MC     lrkeyrpl      setll     lichist1
500 MC     lrkeyrpl      reade     lichist1

500 AC                   select

500 MC                   when      %eof
500 AC                   exsr      updrpltother

500 MC                   when      lrtcod = 'F'
500 AC                             or lrfcod = lrtcod
500 AC                                and lrfara = lrtara
500 AC                                and lrfdsp = lrtdsp
500 MC                   exsr      updrpltfloor

500 MC                   other
500 MC                   exsr      updrpltother

500 MC                   endsl

600bAC     endupdrplt    tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500 A*----------------------------------------------------------------
500 A*  updrpltfloor
500 A*
500 A*    Update replenishment to show in transit. Entire qty.
500 A*    License is coming from Floor or From/To info is the same.
500 A*    Therefore, a new rec was already created when it was pulled.
500 A*    Therefore, update current record to show in transit.
500 A*
500 A*----------------------------------------------------------------
500 A
500 AC     updrpltfloor  begsr
600bAC                   eval      currRoutine = 'updrpltfloor'
600bAC                   exsr      phpgmV1V2V3s

     *  Update current license record to show in transit from slot to
     *  new location. To code will still show unknown because we
     *  won't know for sure thats where the product is until the
     *  transaction is closed.

     *    - Update To info with new destination info.

500 AC                   exsr      zzchklcns
500 AC                   eval      lrlcns = $lrlcns

     C                   eval      lrtcod = $lrtcod
     C                   eval      lrtara = $lrtara
     C                   eval      lrtwhd = $lrtwhd
     C                   eval      lrtasl = $lrtasl
     C                   eval      lrtloc = $lrtloc
     C                   eval      lrtlvl = $lrtlvl
     C                   eval      lrthnd = $lrthnd
500bAC                   eval      lrtdsp = $lrtdsp
500eAC                   eval      lrtbase = $lrtbase
417aAC                   eval      lrtslp = $lrtslp

     *    - Update Changed by info.

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn

     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4

600bAC     endupdrpltflr tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

500 A*----------------------------------------------------------------
500 A*  updrpltother
500 A*
500 A*    Update replenishment to show in transit. Entire qty.
500 A*    License is not coming from Floor.
500 A*    Therefore, create new record.
500 A*
500 A*----------------------------------------------------------------
500 A
500 AC     updrpltother  begsr
600bAC                   eval      currRoutine = 'updrpltother'
600bAC                   exsr      phpgmV1V2V3s

     *  Set current record to Inactive.

     C                   if        not %eof(lichist1)
500eDC**                 eval      lracfl = 'I '
500eMC                   eval      lrstat = 'I '
     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4
     C                   endif

     *  Create new license record to show in transit from slot to
     *  new location. To code will still show unknown because we
     *  won't know for sure thats where the product is until the
     *  transaction is closed.
     *
     *    - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
500eDC**                 eval      lracfl = 'A '
500eMC                   eval      lrstat = 'A '
500qAC                   eval      lrexcd = ' '

     *    - Update From info with To info from original record.

500 AC                   if        $lrlcns <> $lrflic
500 AC                   eval      lrflic = $lrflic
500 AC                   endif

     C                   eval      lrfcod = lrtcod
     C                   eval      lrfara = lrtara
     C                   eval      lrfwhd = lrtwhd
     C                   eval      lrfasl = lrtasl
     C                   eval      lrfloc = lrtloc
     C                   eval      lrflvl = lrtlvl
     C                   eval      lrfhnd = lrthnd
500bAC                   eval      lrfdsp = lrtdsp
500eAC                   eval      lrfbase = lrtbase
417aAC                   eval      lrfslp = lrtslp
500kAC                   eval      lrfitm = lrtitm
500kAC                   eval      lrfityp = lrtityp
500kAC                   eval      lrfitms = lrtitms

     *    - Update To info with new destination info.

500 AC                   exsr      zzchklcns
500 AC                   eval      lrlcns = $lrlcns

     C                   eval      lrtcod = $lrtcod
     C                   eval      lrtara = $lrtara
     C                   eval      lrtwhd = $lrtwhd
     C                   eval      lrtasl = $lrtasl
     C                   eval      lrtloc = $lrtloc
     C                   eval      lrtlvl = $lrtlvl
     C                   eval      lrthnd = $lrthnd
500bAC                   eval      lrtdsp = $lrtdsp
500eAC                   eval      lrtbase = $lrtbase
417aAC                   eval      lrtslp = $lrtslp

     *    - Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *    - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '
417lA
417lA*    - Update thread.
417lA
417lAC                   if        debugnode
417lAC                   move      '       '     lrnode
417lAC                   endif
417lA
417lAC                   eval      lrnode = %trimr(lrnode) + '1'
417lA
417lAC                   if        debugnode
417lAC                   move      'updrplt'     lrnode
417lAC                   endif

     C                   write     lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phWrtV1V2V3V4

600bAC     endupdrpltoth tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

600aA*----------------------------------------------------------------
600aA*  updtrnlbl
600aA*
600aA*    Update tran#/lbl# for license
600aA*
600aA*----------------------------------------------------------------
600aA
600aAC     updtrnlbl     begsr
600bAC                   eval      currRoutine = 'updtrnlbl'
600bAC                   exsr      phpgmV1V2V3s
     C                   exsr      getcurrstamp

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endupdtrnlbl


     C     lrkey         setll     lichist1
     C     lrkey         reade     lichist1
     C                   if        not %eof

     C                   eval      lrtrn# = $lrtrn#
     C                   eval      lrlbl# = $lrlbl#

     *  Update Changed by info

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn

     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4

     C                   endif

600bAC     endupdtrnlbl  tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

     *----------------------------------------------------------------
     *  vfyaddlic  Verify information for *ADDLIC.
     *----------------------------------------------------------------

     C     vfyaddlic     begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfyaddlic

     *  Validate warehouse.

     C                   eval      vfywhse = *on
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $lrwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $lrwhsee = $drierror
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #pgm
     C                   goto      endvfyaddlic

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $lrwhsee = $drierror
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfyaddlic

     C                   endsl

     C     endvfyaddlic  endsr

500iA*----------------------------------------------------------------
500iA*  vfyadjust  Verify information for *ADJUST
500iA*----------------------------------------------------------------
500iA
500iAC     vfyadjust     begsr

     C                   exsr      inzchkflds

     C     endvfyadjust  endsr

     *----------------------------------------------------------------
     *  vfyaskin   Verify information for *ASKIN.
     *----------------------------------------------------------------

     C     vfyaskin      begsr

     C                   exsr      inzchkflds

     C     endvfyaskin   endsr

     *----------------------------------------------------------------
     *  vfyaskout  Verify information for *ASKOUT.
     *----------------------------------------------------------------

     C     vfyaskout     begsr

     C                   exsr      inzchkflds

     C     endvfyaskout  endsr

500gA*----------------------------------------------------------------
500gA*  vfychk4exist  Verify information for *CHK4EXIST
500gA*----------------------------------------------------------------
500gA
500gAC     vfychk4exist  begsr

     C                   exsr      inzchkflds

     C     endvfychk4ex  endsr

     *----------------------------------------------------------------
     *  vfyclsputd  Verify information for *CLSPUTD.
     *----------------------------------------------------------------

     C     vfyclsputd    begsr

     C                   exsr      inzchkflds

     C     endvfyclsputd endsr

     *----------------------------------------------------------------
     *  vfyclsputm  Verify information for *CLSPUTM.
     *----------------------------------------------------------------

     C     vfyclsputm    begsr

     C                   exsr      inzchkflds

     C     endvfyclsputm endsr

     *----------------------------------------------------------------
     *  vfyclsputp  Verify information for *CLSPUTP.
     *----------------------------------------------------------------

     C     vfyclsputp    begsr

     C                   exsr      inzchkflds

     C     endvfyclsputp endsr

     *----------------------------------------------------------------
     *  vfyclsputt  Verify information for *CLSPUTT.
     *----------------------------------------------------------------

     C     vfyclsputt    begsr

     C                   exsr      inzchkflds

     C     endvfyclsputt endsr

     *----------------------------------------------------------------
     *  vfycrtnf    Verify information for *CRTNF.
     *----------------------------------------------------------------

     C     vfycrtnf      begsr

     C                   exsr      inzchkflds

     C     endvfycrtnf   endsr

     *----------------------------------------------------------------
     *  vfycrtsu    Verify information for *CRTSU.
     *----------------------------------------------------------------

     C     vfycrtsu      begsr

     C                   exsr      inzchkflds

     C     endvfycrtsu   endsr

     *----------------------------------------------------------------
     *  vfygetlic#  Verify information for *GETLIC#
     *----------------------------------------------------------------

     C     vfygetlic#    begsr

     C                   exsr      inzchkflds

     C     endvfygetlic# endsr

     *----------------------------------------------------------------
     *  vfygetlot#  Verify information for *GETLOT#
     *----------------------------------------------------------------

     C     vfygetlot#    begsr

     C                   exsr      inzchkflds

     C     endvfygetlot# endsr

     *----------------------------------------------------------------
     *  vfygetslot  Verify information for *GETSLOT
     *----------------------------------------------------------------

     C     vfygetslot    begsr

     C                   exsr      inzchkflds

     C     endvfygetslot endsr

500gA*----------------------------------------------------------------
500gA*  vfymerge  Verify information for *MERGE
500gA*----------------------------------------------------------------
500gA
500gAC     vfymerge      begsr

     C                   exsr      inzchkflds

     C     endvfymerge   endsr

     *----------------------------------------------------------------
     *  vfymovback  Verify information for *MOVBACK
     *----------------------------------------------------------------

     C     vfymovback    begsr

     C                   exsr      inzchkflds

     C     endvfymovback endsr

     *----------------------------------------------------------------
     *  vfymovefwd  Verify information for *MOVEFWD
     *----------------------------------------------------------------

     C     vfymovefwd    begsr

     C                   exsr      inzchkflds

     C     endvfymovefwd endsr

     *----------------------------------------------------------------
     *  vfynewlic#  Verify information for *NEWLIC#
     *----------------------------------------------------------------

     C     vfynewlic#    begsr

     C                   exsr      inzchkflds

     C     endvfynewlic# endsr

     *----------------------------------------------------------------
     *  vfynewlot#  Verify information for *NEWLOT#
     *----------------------------------------------------------------

     C     vfynewlot#    begsr

     C                   exsr      inzchkflds

     C     endvfynewlot# endsr

500 A*----------------------------------------------------------------
500 A*  vfymissinglp  Verify information for *MISSINGLP
500 A*----------------------------------------------------------------
500 A
500 AC     vfymissinglp  begsr

     C                   exsr      inzchkflds

     C     endvfymisslp  endsr

     *----------------------------------------------------------------
     *  vfypull     Verify information for *PULL
     *----------------------------------------------------------------

     C     vfypull       begsr

     C                   exsr      inzchkflds

     C     endvfypull    endsr

     *----------------------------------------------------------------
     *  vfypush     Verify information for *PUSH
     *----------------------------------------------------------------

     C     vfypush       begsr

     C                   exsr      inzchkflds

     C     endvfypush    endsr

     *----------------------------------------------------------------
     *  vfypushpap  Verify information for *PUSHPAP
     *----------------------------------------------------------------

     C     vfypushpap    begsr

     C                   exsr      inzchkflds

     C     endvfypushpap endsr

     *----------------------------------------------------------------
     *  vfypushpat  Verify information for *PUSHPAT
     *----------------------------------------------------------------

     C     vfypushpat    begsr

     C                   exsr      inzchkflds

     C     endvfypushpat endsr

500pA*----------------------------------------------------------------
500pA*  vfyrmvzero  Verify information for *RMVZERO
500pA*----------------------------------------------------------------
500pA
500pAC     vfyrmvzero    begsr

     C                   exsr      inzchkflds

     C     endvfyrmvzero endsr

500pA*----------------------------------------------------------------
500pA*  vfyrmvzrtn  Verify information for *RMVZRTN
500pA*----------------------------------------------------------------
500pA
500pAC     vfyrmvzrtn    begsr

     C                   exsr      inzchkflds

     C     endvfyrmvzrtn endsr

500 A*----------------------------------------------------------------
500 A*  vfyrtnall   Verify information for *RTNALL
500 A*----------------------------------------------------------------
500 A
500 AC     vfyrtnall     begsr

     C                   exsr      inzchkflds

     C     endvfyrtnall  endsr

     *----------------------------------------------------------------
     *  vfyundoput  Verify information for *UNDOPUT
     *----------------------------------------------------------------

     C     vfyundoput    begsr

     C                   exsr      inzchkflds

     C     endvfyundoput endsr

500cA*----------------------------------------------------------------
500cA*  vfyundorpl  Verify information for *UNDORPL
500cA*----------------------------------------------------------------
500cA
500cAC     vfyundorpl    begsr

     C                   exsr      inzchkflds

     C     endvfyundorpl endsr

     *----------------------------------------------------------------
     *  vfyupdloc   Verify information for *UPDLOC
     *----------------------------------------------------------------

     C     vfyupdloc     begsr

     C                   exsr      inzchkflds

     C     endvfyupdloc  endsr

     *----------------------------------------------------------------
     *  vfyupdloc0  Verify information for *UPDLOC0
     *----------------------------------------------------------------

     C     vfyupdloc0    begsr

     C                   exsr      inzchkflds

     C     endvfyupdloc0 endsr

     *----------------------------------------------------------------
     *  vfyupdput   Verify information for *UPDPUT
     *----------------------------------------------------------------

     C     vfyupdput     begsr

     C                   exsr      inzchkflds

     C     endvfyupdput  endsr

     *----------------------------------------------------------------
     *  vfyupdrplp  Verify information for *UPDRPLP
     *----------------------------------------------------------------

     C     vfyupdrplp    begsr

     C                   exsr      inzchkflds

     C     endvfyupdrplp endsr

     *----------------------------------------------------------------
     *  vfyupdrplt  Verify information for *UPDRPLT
     *----------------------------------------------------------------

     C     vfyupdrplt    begsr

     C                   exsr      inzchkflds

     C     endvfyupdrplt endsr

600aA*----------------------------------------------------------------
600aA*  vfyupdtrnlbl  Verify information for *UPDTRNLBL
600aA*----------------------------------------------------------------
600aA
600aAC     vfyupdtrnlbl  begsr

     C                   exsr      inzchkflds

     C     endvfyupdtl   endsr

     *----------------------------------------------------------------
     *  vfywhsesent  Verify that warehouse was sent
     *----------------------------------------------------------------

     C     vfywhsesent   begsr

     C                   if        not $lrwhseu
     C                   eval      error = *on
     C                   eval      $lrwhsee = $drierror
     C                   eval      $preturn  = 'WHSENOTSNT'
     C                   eval      $pmessage = 'Warehouse code must be sent'
     C                   endif

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  vfywrongloc   Verify information for *WRONGLOC
500 A*----------------------------------------------------------------
500 A
500 AC     vfywrongloc   begsr

     C                   exsr      inzchkflds

     C     endvfywronglocendsr

500 A*----------------------------------------------------------------
500 A*  wrongloc
500 A*
500 A*    License plate found at wrong location.
500 A*
500 A*----------------------------------------------------------------
500 A
500 AC     wrongloc      begsr
600bAC                   eval      currRoutine = 'wrongloc'
600bAC                   exsr      phpgmV1V2V3s

     *  Open file.

     C                   exsr      fileopenlh1
     C     error         cabeq     *on           endwrongloc

     C     lrkey         setll     lichist1
     C     lrkey         reade     lichist1
     C                   if        not %eof
500eDC**                 eval      lracfl = 'I '
500eMC                   eval      lrstat = 'I '

     C                   eval      lrchgts     = currstampsys
     C                   eval      lrchguc     = currstampuc
     C                   eval      lrchgpgm    = $lrpgm
     C                   eval      lrchgemp    = $lremp#
     C                   eval      lrchgusr    = $lruser
     C                   eval      lrchgjob    = $lrjob
     C                   eval      lrchgnbr    = $lrjobn
     C                   update    lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phUpdV1V2V3V4

     *  Create new license record to show in transit from slot to
     *  new location. To code will still show unknown because we
     *  won't know for sure thats where the product is until the
     *  transaction is closed.
     *
     *    - Get new sequence number.

     C                   call      'PIRLLP#'
     C                   parm      0             nxtlp#            7 0
     C                   eval      lrltrn = nxtlp#
500eDC**                 eval      lracfl = 'A '
500eMC                   eval      lrstat = 'A '
500qAC                   eval      lrexcd = ' '

     *    - Update From info with To info from original record.

     C                   eval      lrfcod = lrtcod
     C                   eval      lrfara = lrtara
     C                   eval      lrfwhd = lrtwhd
     C                   eval      lrfasl = lrtasl
     C                   eval      lrfloc = lrtloc
     C                   eval      lrflvl = lrtlvl
     C                   eval      lrfhnd = lrthnd
     C                   eval      lrfslp = lrtslp

     *    - Update To infomation with new location.

     C                   eval      lrtcod = $lrtcod
     C                   eval      lrtara = $lrtara
     C                   eval      lrtwhd = $lrtwhd
     C                   eval      lrtasl = $lrtasl
     C                   eval      lrtloc = $lrtloc
     C                   eval      lrtlvl = $lrtlvl
     C                   eval      lrthnd = $lrthnd
417aAC                   eval      lrtslp = $lrtslp

     *    - Update Added by info for new record.

     C                   eval      lraddts     = currstampsys
     C                   eval      lradduc     = currstampuc
     C                   eval      lraddpgm    = $lrpgm
     C                   eval      lraddemp    = $lremp#
     C                   eval      lraddusr    = $lruser
     C                   eval      lraddjob    = $lrjob
     C                   eval      lraddnbr    = $lrjobn

     *    - Initialize Changed by info for new record.

     C                   eval      lrchgts     = *loval
     C                   eval      lrchguc     = *loval
     C                   eval      lrchgpgm    = ' '
     C                   eval      lrchgemp    = 0
     C                   eval      lrchgusr    = ' '
     C                   eval      lrchgjob    = ' '
     C                   eval      lrchgnbr    = ' '

     *    - Thread doesn't change when recording a missing LP.

     C                   if        debugnode
     C                   move      'updrplt'     lrnode
     C                   endif

     C                   write     lrrec1
600bAC                   eval      currFile = 'lrrec1'
600bAC                   exsr      phWrtV1V2V3V4
     C                   endif

600bAC     endwrongloc   tag
600bAC                   exsr      phpgmV1V2V3e
600bMC                   endsr

417jA*----------------------------------------------------------------
417jA*  zzchklcns - Check for special license code.
417jA*
417jA*  A special license begins with an '*' and is followed by 2 char.
417jA*  Example: *NA identifies a lic that wasn't applied when requested.
417jA*  To create a unique license, the lic tran# is appended.
417jA*
417jA*----------------------------------------------------------------
417jA
417jAC     zzchklcns     begsr

     C                   if        %subst($lrlcns:1:1) = '*'
     C                             and %subst($lrlcns:4:1) = ' '
     C                   move      lrltrn        temp7a
     C                   eval      $lrlcns = %trim($lrlcns) + temp7a
     C                   endif

     C                   endsr

600cA*----------------------------------------------------------------
600cA*  wrtLicLog  - Call WRTLICLOG
600cA*----------------------------------------------------------------
600cA
     C     wrtLicLog     begsr

600dDC*                  call      'WRTLICLOG'
600dDC*                  parm      '*WRITE'      pllCmd            8
600dDC*                  parm                    pllPgm           10
600dDC*                  parm                    pllEmp#           5 0
600dDC*                  parm                    pllUser          10
600dDC*                  parm                    pllStampSys
600dDC*                  parm                    pllStampUc
600dDC*                  parm                    pllWhse           3 0
600dDC*                  parm                    pllLTrn           7 0
600dDC*                  parm                    pllAction         3
600dDC*                  parm                    pllTrn#           7 0
600dDC*                  parm                    pllLbl#           7 0
600dDC*                  parm                    pllLcns          15
600dDC*                  parm                    pllOLcns         15
600dDC*                  parm                    pllVrfy           1
600dDC*                  parm                    pllFLcns         15
600dDC*                  parm                    pllAQty1          5 0
600dDC*                  parm                    pllAQty2          5 0
600dDC*                  parm                    pllAQty3          5 0
600dDC*                  parm                    pllRQty1          5 0
600dDC*                  parm                    pllRQty2          5 0
600dDC*                  parm                    pllRQty3          5 0
600dDC*                  parm                    pllCode           1
600dDC*                  parm                    pllArea          15
600dDC*                  parm                    pllWhdp           5
600dDC*                  parm                    pllDisp          12
600dDC*                  parm                    pllAisl           3
600dDC*                  parm                    pllLoc            3 0
600dDC*                  parm                    pllRlvl           2 0
600dDC*                  parm                    pllHand           2
600dDC*                  parm                    pllBase          12
600dDC*                  parm                    pllPos            3 0
600dDC*                  parm                    pllItem          15
600dDC*                  parm                    pllIType          1
600dDC*                  parm                    pllIChg           1
600dDC*                  parm                    pllSItem         15
600dDC*                  parm                    pllSIType         1
600dDC*                  parm                    pllEntD           8 0
600dDC*                  parm                    pllExpD           8 0
600dDC*                  parm                    pllOrd           10 0
600dDC*                  parm                    pllSeq            5 0
600dDC*                  parm                    pllExcd           8

     C                   endsr

600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------
600bA*  Phrase Routines
600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------

600bA*----------------------------------------------------------------
600bA*  phClearVars  - Clear phrase variables
600bA*----------------------------------------------------------------
600bA
      /free
       begsr phClearVars;

         v1 = ' ';
         v2 = ' ';
         v3 = ' ';
         v4 = ' ';
         v5 = ' ';

       endsr;
      /end-free

600bA*----------------------------------------------------------------
600bA*  phWrtPhrase  - Write logging phrase
600bA*----------------------------------------------------------------

      /free
       begsr phWrtPhrase;

         pWhse = lrWhse;
         if lrChgEmp = 0;
           pEmp# = lrAddEmp;
         else;
           pEmp# = lrChgEmp;
         endif;
         pUser = #curruser;
         pPgm  = #pgm;
         pItem = lrTItm;
         pWhdp = lrTWhd;
         if lrTCod = 'S' or lrTCod='F';
           pLocation = lrTdsp;
         else;
           pLocation = lrTAra;
         endif;
         pTrn# = lrTrn#;
         pLcns = lrLcns;
         pLtrn = lrLtrn;

      /end-free
     C                   call      'WRTPHRASE'
     c                   parm                    pPhraseId
     c                   parm                    pWhse
     c                   parm                    pEmp#
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pItem
     c                   parm                    pWhdp
     c                   parm                    pLocation
     c                   parm                    pTrn#
     c                   parm                    pLcns
     c                   parm                    pLtrn
     c                   parm                    v1
     c                   parm                    v2
     c                   parm                    v3
     c                   parm                    v4
     c                   parm                    v5
      /free


         if %error;
           eval error = error;
         endif;

       endsr;
      /end-free

600bA*----------------------------------------------------------------
600bA*  phPgmV1V2V3e
600bA*----------------------------------------------------------------
600bA
      /free
       begsr phPgmV1V2V3e;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $psubcmd;
         v2 = currRoutine;
         v3 = 'End';

         exsr phWrtPhrase;

         exsr popRoutine;

       endsr;
      /end-free

600bA*----------------------------------------------------------------
600bA*  phPgmV1V2V3s
600bA*----------------------------------------------------------------
600bA
      /free
       begsr phPgmV1V2V3s;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $psubcmd;
         v2 = currRoutine;
         v3 = 'Start';

         exsr phWrtPhrase;

         exsr pushRoutine;

       endsr;
      /end-free

600bA*----------------------------------------------------------------
600bA*  phUpdV1V2V3V4
600bA*----------------------------------------------------------------
600bA
      /free
       begsr phUpdV1V2V3V4;

         pPhraseId = updV1V2V3V4;

         exsr phClearVars;
         v1 = %trimr(currRoutine) + '-' + currFile;
         if error = *on;
           v2 = 'Err: ' + $preturn;
           v3 = %subst($pmessage:1:30);
           v4 = %subst($pmessage:31:30);
         endif;

         exsr phWrtPhrase;

       endsr;
      /end-free

600bA*----------------------------------------------------------------
600bA*  phWrtV1V2V3V4
600bA*----------------------------------------------------------------
600bA
      /free
       begsr phWrtV1V2V3V4;

         pPhraseId = wrtV1V2V3V4;

         exsr phClearVars;
         v1 = %trimr(currRoutine) + '-' + currFile;
         if error = *on;
           v2 = 'Err: ' + $preturn;
           v3 = %subst($pmessage:1:30);
           v4 = %subst($pmessage:31:30);
         endif;

         exsr phWrtPhrase;

       endsr;
      /end-free

600bA*----------------------------------------------------------------
600bA*  pushRoutine  -  Add routine to stack
600bA*----------------------------------------------------------------
600bA
      /free
       begsr pushRoutine;

         for i = stackCount downto 1;
           eval aRoutine(i+1) = aRoutine(i);
         endfor;

         aRoutine(1) = currRoutine;
         stackCount += 1;

       endsr;
      /end-free

600bA*----------------------------------------------------------------
600bA*  popRoutine  -  Remove routine from stack
600bA*----------------------------------------------------------------
600bA
      /free
       begsr popRoutine;

         for i = 1 to stackCount-1;
           eval aRoutine(i) = aRoutine(i+1);
         endfor;

         aRoutine(stackCount) = ' ';
         stackCount -= 1;
         currRoutine = aRoutine(1);

       endsr;
      /end-free
