     H OPTION(*NODEBUGIO)
720aAH Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OI300     Resequence Stops
     *  26 January 2009
     *  Chuck Manny
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *  01/26/09  CWM  5.20
     *    - Created
     *
530 A*  01/21/10  MLB  5.30
     *    - Fix: Revised pgm to fix how internal 2 digit stop#
     *      is computed.
530aA*  04/07/10  MLB  5.30a
     *    - Fix: Revised pgm to compute internal stop number
     *      instead of using extended stop number from Host if
     *      less than 100.  Was causing stops larger than 99 to
     *      all be assigned an internal stop number of 99.
     *
650 A*  05/29/13  RTR  6.50
     *    - Enh: Changes for Stop/Drop processing:
     *      Use logical RTESTP3, look for change in Drop Display RTSSD
     *      instead of Ext Stop 5, RTSST5.
     *
710a *  01/12/18  RTR  7.10
     *    - Fix: Change 650 mod to handle when RTSSD not populated to
     *      support older versions.
     *
720aA*  08/30/18  RBD  7.20a
     *    - Fix: Added logic to see if this is an addon route and
     *      if so write to arrays the stop and large stop (from
     *      RTESTP) for each of the like host routes that are of
     *      today's routes. Then use the arrays to ensure that this
     *      addon route's stops use the same stop id's as the other
     *      route(s) for the same stop or if there's a new stop that
     *      it picks up with the next higher number.
     *
720bA*    10/01/18  RBD  7.20b
     *      - If route departure dates are populated use them rather
     *        than Loader start and end times to determine if there's a
     *        like host route for the same day.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*  01/21/11  MLB  DRY
     *    - Revised program to assign the internal stop number the same
     *      as the extended stop number when less than 99. Dairyland
     *      wants it to work the way it did prior to the 5.30a patch
     *      being installed.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf
     *
GLP A*  09/26/16  NLK  GLPa
     *    - ENH: GLP for AMP routes only updt Stop# with a
     *      sequencial number to help with training and put
     *      order in the AMP process
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: I Supply
     *
ISYaA*    05/27/20  RBD  ISYa
     *      - Enh:  Determine add on routes by using first 4 characters
     *        of route.
     *
ISYbA*    06/23/20  RBD  ISYb
     *      - Enh: Ignore loader cycle time for determining add ons,
     *        instead require the parent and add ons be no more than
     *        three days apart.  Don't have to worry about time of day.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

650 Df*rtestp1   uf   e           k disk
650 Afrtestp3   uf   e           k disk
     fordh      uf   e           k disk
GLPaAfordhm2    if   e           k disk
720aAFoptions   if   E           k disk
720aAFrtehed    if   E           k disk    prefix(r_)
720aAFrtehed1   if   E           k disk    rename(rhrec:rhrec1)

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

720aA*----------------------------------------------------------------
720aA*  RTESTP arrays to hold stop and large stop of like host routes
     *
720aAD aryStp2         s              2  0 dim(99) ASCEND
720aAD aryStp5         s              5  0 dim(99)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

720aA*----------------------------------------------------------------
720aA*  *LOADER  -  Loader options.
720aA*----------------------------------------------------------------
720aA*
720aA* Fields
720aA*
     *    OPSTTM  -  Start time for a day's routes.
     *    OPENTM  -  End time for a day's routes.
     *    OPLDOR  -  Loading order.
     *    OPTLID  -  Speak trailer id.
     *    OPRWCL  -  Speak row/column.
     *    OPVYPL  -  Verify pallet position.
     *    OPVFYP  -  Verify pallet label against pick label.
     *    OPADDO  -  Auto define add-on routes Y/N.
     *    OPEQIP  -  Load Equip by zone Y/N.
     *    OPBYPL  -  Bypass entry of qty when loading equipment Y/N.
     *    OPBYPR  -  Bypass entry of qty when returning equipment Y/N.
     *
     * Data structure
     *
     D opdata          ds
     D  opsttm                 1      6  0
     D  opentm                 7     12  0
     D  opldor                13     13
     D  optlid                14     14
     D  oprwcl                15     15
     D  opvypl                16     16
     D  opvfyp                17     17
     D  opaddo                18     18
     D  opeqip                19     19
     D  opbypl                20     20
     D  opbypr                21     21
     D  optend               117    117

720aA*----------------------------------------------------------------
720aA*  Standard variables and constants
720aA*----------------------------------------------------------------

720aA /copy qcopysrc,c#stdvar
720aA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
720aAdaddonRte         s               n
ISYbAdISYaddon         s               n
720aAdix               s              2  0
720aAdsix              s              1    inz('6')
     dwkDktStp         s              2  0 inz
650 Dd*hldst5           s                   like(rtsst5)
650 Adhldst9           s                   like(rtssd)
720bAD departDt        s              8  0
720bAD pDepartDt       s              8  0
GLPaAD AMPrte          s               n
GLPaAD AMPstp          s              2  0 inz
ISYaAD pRte4           s              5
     D @getcl          c                   const('GETCLIENT')
GLPaA /copy qcopysrc,id#GLP
ISYaA /copy qcopysrc,ID#ISUPPLY

720aA*----------------------------------------------------------------
720aA*  Sub-procedure prototypes
720aA*----------------------------------------------------------------

720aAd BldAryStp       pr
720aAd GetOptions      pr

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Redefinition data structures
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
     *----------------------------------------------------------------
     d  status           *status
     d  rowin                370    370
     d  colin                371    371
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID to resequence
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     *
     *----------------------------------------------------------------
     *  Main line
     *
     c     keyRts        klist
     c                   kfld                    $pwhse
     c                   kfld                    $prtid
     *
     c     keyOrd        klist
     c                   kfld                    rtswhs
     c                   kfld                    rtsord
     *

720aA /free

720aA   BldAryStp();

720aA /end-free

     *
     C                   eval      wkDktStp = 0
650 DC*                  eval      hldst5 = *loval
650 AC                   eval      hldst9 = *loval
650 Dc*    keyRts        setll     rtestp1
650 Mc     keyRts        setll     rtestp3
650 Dc*                  dou       %eof(rtestp1)
650 Mc                   dou       %eof(rtestp3)
650 Dc*    keyRts        reade     rtestp1
650 Mc     keyRts        reade     rtestp3
650 Dc*                  if        %eof(rtestp1)
650 Mc                   if        %eof(rtestp3)
     c                   leave
     c                   endif
710aA*
710aA*      If RTSSD not populated, load it with RTSST5
710aAc                   if        rtssd = *blanks
710aAc                   eval      rtssd = %char(rtsst5)
710aAc                   endif
530 A*
530 AC                   select
GLPaAC                   when      AMPrte
GLPaAC                   eval      ampstp = ampstp + 1
GLPaAC                   eval      rtsstp = ampstp

720aAc                   when      addonRte = *on
720aA /free
720aA   if %lookup(rtsst5:aryStp5) > 0;
720aA     ix = %lookup(rtsst5:aryStp5);
720aA     rtsstp = aryStp2(ix);
720aA   else;
720aA     ix = %lookup(*zeros:aryStp2);
720aA     if ix > 0 and ix <= 99;
720aA       rtsstp = ix;
720aA       aryStp2(ix) = rtsstp;
720aA       aryStp5(ix) = rtsst5;
720aA     else;
720aA       ix = 99;
720aA       rtsstp = ix;
720aA       aryStp2(ix) = rtsstp;
720aA       aryStp5(ix) = rtsst5;
720aA     endif;
720aA   endif;
720aA /end-free


530aDC*                  when      rtsst5 <= 99
530aDC*                  eval      rtsstp   = rtsst5
530aDC*                  eval      wkDktstp = rtsst5
530 A*
     *
     *      Do not allow 2-digit stop number to be incremented
     *      past 99, otherwise terminal error will occur.
530 DC*                  if        wkDktStp < 99
530aDC*                  when          rtsst5 >= 100
530aDC*                            and hldst5 <> rtsst5
650 DC*                  when          hldst5 <> rtsst5
650 MC                   when          hldst9 <> rtssd
530 AC                             and wkDktStp < 99
     c                   eval      wkDktStp = wkDktStp + 1
     c                   eval      rtsstp = wkDktStp
650 Dc*                  eval      hldst5 = rtsst5
650 Mc                   eval      hldst9 = rtssd
530 A*
530 A*      Set Internal stop nbr to Wk Dakota stop# when Host stop#
530 A*      did not change.
530aDC*                  when          rtsst5 >= 100
530aDC*                            and hldst5 = rtsst5
650 DC*                  when          hldst5 = rtsst5
650 MC                   when          hldst9 = rtssd
530 AC                             and wkDktStp < 99
530 Ac                   eval      rtsstp = wkDktStp
530 A*
530 DC*                  else
530 MC                   other
     C                   eval      rtsstp = 99
530 DC*                  endif
530 MC                   endsl
     *
     c                   update    rtsRec
     *
     c     keyOrd        chain     ordh
     c                   if        %found(ordh)
     c                   eval      ohstop = rtsstp
     c                   update    ohRec
     c                   endIf
     *
     c                   enddo
     *
     c                   eval      *inlr = *on


     *
     *   If AMP-pick, assign sequential STOP numbers
     *
     *----------------------------------------------------------------
     C     *inzsr        begsr
500 A*
500 A* Get client id.
500 A*
500 AC                   call      @getcl
500 AC                   parm                    client           10
CWDbAC                   parm                    clientloc        10

720aA /free

720aA  getOptions();

720aA /end-free

500 A*
GLPaAC     keyAMP        klist
GLPaAC                   kfld                    $pwhse
GLPaAC                   kfld                    $prtid
GLPaAC                   eval      AMPrte = *off
GLPaAC                   eval      ampstp = 0
720bDC**                 if        client = greenleaf
GLPaAC                   eval      hmmsc4 = *blanks
GLPaAC     keyAMP        chain     ordhm2                             79
GLPaAC                   if        %subst(hmmsc4:13:1) = 'Y'
GLPaAC                   eval      AMPrte = *on
GLPaAC                   endif

720bA /free

720bA   // Setup departure date for imported route, if there is one
720bA      if %found and %check('0123456789' : %subst(hmmsc4:1:12)) = 0;
720bA        pDepartDt = %dec(%subst(hmmsc4:1:8):8:0);

720bA      else;

720bA        pDepartDt = 0;

720bA      endif;

720bA /end-free

720bDC**                 endif

GLPaAC                   endsr

720aA*----------------------------------------------------------------
720aA*  BldAryStp   See if this is an addon route and if so write to
720aA*              arrays the stop and large stop (from RTESTP) for
720aA*              each of the like host routes that are of today's
720aA*              routes. Then use the arrays to ensure that this
720aA*              addon route's stops use the same stop id's as the
720aA*              other route(s) for the same stop or if there's a new
720aA*              stop that it picks up with the next higher number.
720aA*
720aA*----------------------------------------------------------------
720aA
     p BldAryStp       b
     d BldAryStp       pi

      /free

       chain ($pwhse: $pRtid) rtehed;

        // Look for matching host route

ISYaA   if client = isupply;
ISYaA     pRte4 = %subst(r_rhrte:1:4);
ISYaA     SqlStmt = 'select '
ISYaA           +   'rhwhse, rhrte, rhrtid, rhimpd, '
ISYaA           +   'rhimpt, rhstat '
ISYaA           + 'from rtehed1 '
ISYaA           + 'where rhwhse = ' + %char($pWhse)
ISYaA           +   ' and substring(rhrte,1,4) = ' + sq + (pRte4) + sq
ISYaA           +   ' and rhrtid <> ' + sq + ($pRtid) + sq
ISYaA           +   ' and rhstat <= ' + sq + %trim(six) + sq;
ISYaA   else;

        SqlStmt = 'select '
                +   'rhwhse, rhrte, rhrtid, rhimpd, '
                +   'rhimpt, rhstat '
                + 'from rtehed1 '
                + 'where rhwhse = ' + %char($pWhse)
                +   ' and rhrte = ' + sq + (r_rhrte) + sq
                +   ' and rhrtid <> ' + sq + ($pRtid) + sq
                +   ' and rhstat <= ' + sq + %trim(six) + sq;
ISYaA   endif;

        exec sql prepare rtesel from :SqlStmt;
        exec sql declare rtecsr cursor for rtesel;
        exec sql open rtecsr;

        dow forever = forever;

ISYbA     ISYaddon = *off;

          exec sql fetch next from rtecsr
                   into :rhwhse, :rhrte, :rhrtid, :rhimpd,
                        :rhimpt, :rhstat;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

720bA     // If imported route has a departure date see if the like
720bA     // route does too and if they match you've got an add on,
720bA     // otherwise use loader date and times
720bA     if pDepartDt <> 0;
720bA       chain (rhwhse: rhrtid) ordhm2;
720bA       if %found and %check('0123456789' : %subst(hmmsc4:1:12)) = 0;
720bA         departDt = %dec(%subst(hmmsc4:1:8):8:0);

720bA       else;

720bA         departDt = 0;

720bA       endif;
720bA     endif;

720bA /end-free

720bA     // Incoming route and like route have same departure date
720bA     // so this means you have a legit add on
720bAC                   if        pDepartDt <> 0 and
720bAC                             pDepartDt = departDt
720bAC                   goto      skipLdrDate
720bAC                   endif

720bA /free

ISYbA     if client = isupply;
ISYbA       if rhimpd < %dec(%char(%date() - %Days(3):*ISO0):8:0);
ISYbA         iter;
ISYbA       else;
ISYbA         ISYaddon = *on;
ISYbA       endif;
ISYbA     endif;

ISYbA /end-free

ISYbA     // ISY route is an add on
ISYbAC                   if        ISYaddon = *on
ISYbAC                   goto      skipLdrDate
ISYbAC                   endif

720bA /free

720bA       // If you got this far you've got to use Loader date and time

          // Matching route imported before yesterday, keep looking
          if rhimpd < %Dec(%Date() - %Days(1): *iso);
            iter;
          endif;

          // Matching route imported today before end time
          // but it's now after end time, keep looking
          if rhimpd = %dec(%date():*iso)
                      and rhimpt <= opentm
                      and %dec(%time():*hms) > opentm;
            iter;
          endif;

          // Matching route imported yesterday but it's now after
          // end time, keep looking
          if rhimpd = %Dec(%Date() - %Days(1): *iso)
                      and %dec(%time():*hms) > opentm;
            iter;
          endif;

          // Matching route imported yesterday before start time,
          // keep looking
          if rhimpd = %Dec(%Date() - %Days(1): *iso)
                      and rhimpt < opsttm;
            iter;
          endif;

720bA /end-free

720bAC     skipLdrDate   tag

720bA /free

          // If you got this far this is an addon route
          addonRte = *on;

          // Add matching route's stops and large stops to arrays

          SqlStmt = 'select '
                  +   'rtsst5, rtsstp '
                  + 'from rtestp '
                  + 'where rtswhs = ' + %char(rhwhse)
                  +   ' and rtsrid = ' + sq + (rhrtid) + sq;

          exec sql prepare stpsel from :SqlStmt;
          exec sql declare stpcsr cursor for stpsel;
          exec sql open stpcsr;

          dow forever = forever;

            exec sql fetch next from stpcsr
                     into :rtsst5, :rtsstp;

            if sqlstt <> sqlSuccess;
              leave;
            endif;

            if %lookup(rtsst5:aryStp5) = 0;
              ix = %lookup(*zeros:aryStp5);
              aryStp2(ix) = rtsstp;
              aryStp5(ix) = rtsst5;
            endif;

            enddo;

          exec sql close stpcsr;

          enddo;

        exec sql close rtecsr;

      /end-free

     p BldAryStp       e

720aA*----------------------------------------------------------------
720aA*  GetOptions  Get options
720aA*----------------------------------------------------------------
720aA
     p GetOptions      b
     d GetOptions      pi

      /free

       chain ($pwhse: '*LOADER') Options;
       if not %found;
         opsttm = 0;
         opentm = 0;
       endif;

      /end-free

     p GetOptions      e

     *----------------------------------------------------------------
