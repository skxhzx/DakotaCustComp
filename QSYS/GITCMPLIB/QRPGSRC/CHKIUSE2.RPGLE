      /copy *libl/qcopysrc,hspecs
640aAH DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CHKIUSE2  Truck Build - Check route inuse status - Ver 2
     *  20 December 2013
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    12/20/13  DAS  6.50
     *      - Created.
     *            Based on and replaces CHKIUSE
     *
650aA*    03/27/14  DAS  6.50a
     *      - Added check to verify route id.
     *
650bA*    05/02/14  DAS  6.50b
     *      - Added bfcdebug logic
     *
650cA*    05/02/14  DAS  6.50c
     *      - Added return to the end
     *
650dA*    05/05/14  DAS  6.50d
     *      - Removed check for same session.
     *
650eA*    04/15/14  RTR  6.50e
     *      - Added type 51 for import errors.
710aA*    12/30/17  DAS  7.10a
     *      - Activated call to WrtRteLog
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Frtehed    if   e           k disk
     Frteinuse  uf a e           k disk
     Frteinuse1 uf   e           k disk    rename(riurec: riurec1)
650bAFbfcdbgflg if   e           k disk    usropn
650bAFbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /COPY QCOPYSRC,ID#LEDYARD

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10
650bAD dbgflgExists    s               n
650bAD debug           s               n

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Command.
     *              *CLEAR   - Clear inuse flag.
650aA*              *CLEARCI - Clear inuse flag called using CI option.
650aA*              *CLEARDD - Clear inuse flag called from DD.
650aA*              *CLEARUT - Clear inuse flag called from utility menu.
650cA*              *CLRSESS - Clear inuse for a session
650bA*              *GETIUSE - Get inuse status
     *              *INUSE1  - Set status 1/0 Open - Aloc/build
650bA*              *INUSE11 - Set status 1/1 Open - Deleting
650bA*              *INUSE12 - Set status 1/2 Open - Editing
650bA*              *INUSE13 - Set status 1/3 Open - Truck Detail
     *              *INUSE2  - Set status 2/0 Built - Pick/print.
650bA*              *INUSE21 - Set status 2/1 Built - Unallocating
650bA*              *INUSE22 - Set status 2/2 Built - Editing
650bA*              *INUSE23 - Set status 2/3 Built - Truck Detail
650bA*              *INUSE24 - Set status 2/4 Built - Drag Drop
650bA*              *INUSE25 - Set status 2/5 Built - Rebuild
650bA*              *INUSE26 - Set status 2/6 Built - Stage/Print (USF)
417  *              *INUSE3  - Set status 3/0 Printed - Close trans.
650bA*              *INUSE31 - Set status 3/1 Printed - Unallocating
650bA*              *INUSE32 - Set status 3/2 Printed - Export Catchweight
417  *              *INUSE4  - Set status 4/0 Closed - Export trans.
650bA*              *INUSE5  - Set status 5/0 Open - Importing (OI285)
650eA*              *INUSE51 - Set status 5/1 Open - Import Errors (OI285S)
650bA*              *INUSE6  - Set status 6/0 Staged - Merge/Print (USF)
     *              *VERIFY  - Check if route is inuse.
LED A*              *CKCWGT  - Mark catchweights as exported.
LED A*              *CLRCWGT - Clear catchweights exported flag.
     *      $PWHSE  Warehouse number.
     *      $PRTID  Route Id.
650cA*      $PPGM   Calling program
650cA*      $PUSER  User
650cA*      $PSESSID   Session id
     *
     *    Returned Parameters
     *      $PRTN     *OK      - No lock or set/clear successful.
     *                *ERROR   - Locked to different session or set/clear error.
     *      $iuTEXT10  Inuse status short text
     *      $iuTEXT30  Inuse status long text
     *      $iuCmd     Inuse command
     *      $iuPgm     Inuse program
     *      $iuUSER    Inuse user
     *      $iuSESSID  Inuse session id
     *      $iuJOBNAME Inuse job name
     *      $iuJOBNBR  Inuse job number
     *      $iuJOBUSR  Inuse job user
     *      $iuSTAMP   Inuse timestamp
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $ppgm            20
     C                   parm                    $puser           10
     C                   parm                    $psessid         40
     C                   parm                    $prtn             8
     C                   parm                    $iutext10        10
     C                   parm                    $iutext30        30
     C                   parm                    $iucmd            8
     C                   parm                    $iupgm           20
     C                   parm                    $iuuser          10
     C                   parm                    $iuSessId        40
     C                   parm                    $iuJobName       10
     C                   parm                    $iuJobNbr         6
     C                   parm                    $iuJobUser       10
     C                   parm                    $iuStamp         26

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
650bA
650bA    if dbgflgExists;
650bA      chain(e) (#pgm) bfcdbgflg;
650bA      if %found(bfcdbgflg);
650bA        debug = (bdfflag = 1);
650bA      else;
650bA        debug = *off;
650bA      endif;
650bA    endif;

        // Initialize return fields

        $prtn = '';
        $iucmd = '';
        $iusessid = '';
        $iupgm = '';
        $iuuser = '';
        $iustamp = '';
        $iujobuser = '';
        $iujobname = '';
        $iujobnbr = '';
        $iutext10 = '';
        $iutext30 = '';

        // Initialize input fields

        if $psessid = '';
          $psessid = %trimr(#jobnbr) + '/'
                   + %trimr(#job) + '/'
                   + #user;
        endif;

        if $puser = '';
          $puser = #curruser;
        endif;

        select;

          // Clear inuse flag for route

          when $pcmd = '*CLEAR'
            or $pcmd = '*CLEARCI'
            or $pcmd = '*CLEARDD'
            or $pcmd = '*CLEARUT';
              exsr Clear;

          // Clear inuse flag for session

          when $pcmd = '*CLRSESS';
              exsr ClearSess;

          // Get inuse flag

          when $pcmd = '*GETIUSE';
            exsr Get;

          // Set inuse flag

          when %subst($pcmd:1:6) = '*INUSE';
            exsr Set;

          // Check route - if route marked for inuse

          when $pcmd = '*VERIFY';
            exsr Get;

        endsl;

        if debug;
          exsr wrtDebugParms;
        endif;

        return;
      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

650bA    open(e) bfcdbgflg;
650bA    if %error;
650bA      dbgflgExists = *off;
650bA    else;
650bA      dbgflgExists = *on;
650bA    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Clear   Clear In-Use
     *----------------------------------------------------------------

      /free
       begsr Clear;

         chain(e) ($pwhse: $prtid) rteinuse;

         select;

           when %status(rteinuse) = recordLocked;
             $prtn = '*ERROR';
             dderm = 'Cannot Clear. RTEINUSE locked.';
             $iutext10 = 'Cannot Clr';
             $iutext30 = 'Cannot clear. RTEINUSE locked.';

           when not %found(rteinuse);
             $prtn = '*OK';
             dderm = 'Already clear';

           other;
             delete(e) riurec;
             if %error;
               $prtn = '*ERROR';
               dderm = 'Error deleting RTEINUSE record for '
                     + %char($pwhse) + '/' + $prtid;
             $iutext10 = 'Cannot Clr';
             $iutext30 = 'Cannot clear. RTEINUSE Dlt Err.';
             else;
               $prtn = '*OK';
               dderm = %trimr(riucmd) + ' lock removed';
             endif;

         endsl;

         exsr WrtDDLOG;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ClearSess   Clear inuse for session
     *----------------------------------------------------------------

      /free
       begsr ClearSess;

         setll ($psessid) rteinuse1;
         dow forever = forever;

           reade(e) ($psessid) rteinuse1;

           select;

             when %eof(rteinuse1);
               leave;

             when %status(rteinuse1) = recordLocked;
               $prtn = '*ERROR';
               dderm = 'Cannot Clear. RTEINUSE locked.';
               $iutext10 = 'Cannot Clr';
               $iutext30 = 'Cannot clear. RTEINUSE locked.';
               exsr WrtDDLOG;
               leave;

             other;
               delete(e) riurec1;
               if %error;
                 $prtn = '*ERROR';
                 dderm = 'Error deleting RTEINUSE record for '
                       + %char($pwhse) + '/' + $prtid;
                 $iutext10 = 'Cannot Clr';
                 $iutext30 = 'Cannot clear. RTEINUSE Dlt Err.';
               else;
                 $prtn = '*OK';
                 dderm = %trimr(riucmd) + ' lock removed';
               endif;

           endsl;

           exsr WrtDDLOG;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Get    Get In-Use
     *----------------------------------------------------------------

      /free
       begsr Get;

        chain(n)($pwhse: $prtid) rteinuse;

        select;

          when %found(rteinuse);
650dD       //if riusessid = $psessid;
650dD       //  $prtn = '*OK';
650dD       //else;
              $prtn = '*ERROR';
650dD       //endif;
            exsr GetInfo;

          other;
            $prtn = '*OK';

        endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr GetCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetInfo    Get inuse info
     *----------------------------------------------------------------

      /free
       begsr GetInfo;

        $iucmd = riucmd;
        $iusessid = riusessid;
        $iupgm = riupgm;
        $iuuser = riuuser;
        $iustamp = %char(riuts);
        $iujobuser = riujusr;
        $iujobname = riujob;
        $iujobnbr = riunbr;

        select;

          when riucmd = '*INUSE1';
            $iutext10 = 'Aloc/Build';
            $iutext30 = 'Allocate & Build';

          when riucmd = '*INUSE11';
            $iutext10 = 'Deleting';
            $iutext30 = 'Deleting';

          when riucmd = '*INUSE12';
            $iutext10 = 'Editing';
            $iutext30 = 'Editing';

          when riucmd = '*INUSE13';
            $iutext10 = 'Trk Detail';
            $iutext30 = 'Truck Detail';

          when riucmd = '*INUSE2';
            $iutext10 = 'Pick/Print';
            $iutext30 = 'Pick & Print';

          when riucmd = '*INUSE21';
            $iutext10 = 'Unallocate';
            $iutext30 = 'Unallocating';

          when riucmd = '*INUSE22';
            $iutext10 = 'Editing';
            $iutext30 = 'Editing';

          when riucmd = '*INUSE23';
            $iutext10 = 'Trk Detail';
            $iutext30 = 'Truck Detail';

          when riucmd = '*INUSE24';
            $iutext10 = 'Drag Drop';
            $iutext30 = 'Drag Drop';

          when riucmd = '*INUSE25';
            $iutext10 = 'Rebuild';
            $iutext30 = 'Rebuild';

          when riucmd = '*INUSE26';
            $iutext10 = 'Pick/Stage';
            $iutext30 = 'Pick & Stage';

          when riucmd = '*INUSE3';
            $iutext10 = 'Close Tran';
            $iutext30 = 'Close Transactions';

          when riucmd = '*INUSE31';
            $iutext10 = 'Unallocate';
            $iutext30 = 'Unallocating';

          when riucmd = '*INUSE32';
            $iutext10 = 'Export Cwt';
            $iutext30 = 'Exporting Catch Weights';

          when riucmd = '*INUSE4';
            $iutext10 = 'Exporting';
            $iutext30 = 'Exporting';

          when riucmd = '*INUSE5';
            $iutext10 = 'Importing';
            $iutext30 = 'Importing';

650eA     when riucmd = '*INUSE51';
650eA       $iutext10 = 'Import Err';
650eA       $iutext30 = 'Import Error';

          when riucmd = '*INUSE6';
            $iutext10 = 'Merge/Prnt';
            $iutext30 = 'Merge Orphans & Print';

          other;
            $iutext10 = 'In-Use ' + %trimr(riucmd);
            $iutext30 = 'In-Use (' + %trimr(riucmd) + ')';

        endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Set     Set In-Use
     *----------------------------------------------------------------

      /free
       begsr Set;

650bA    // Verify route exists
650bA
650bA    chain(e) ($pwhse: $prtid) rtehed;
650bA    if not %found(rtehed);
650bA      $prtn = '*ERROR';
650bA      dderm = 'Route not found (' + %trim($prtid) + ')';
650bA      $iutext10 = 'Not Found';
650bA      $iutext30 = 'Route not found (' + %trim($prtid) + ')';
650bA      exsr WrtDDLOG;
650bA      leavesr;
650bA    endif;

         // Set flag

         chain(e) ($pwhse: $prtid) rteinuse;

         select;

           when %status(rteinuse) = recordLocked;
             $prtn = '*ERROR';
             dderm = 'Cannot Set. RTEINUSE locked.';
             $iutext10 = 'Cannot Set';
             $iutext30 = 'Cannot set. RTEINUSE locked.';

650dD      //when %found(rteinuse) and riusessid <> $psessid;
650dM        when %found(rteinuse);
             unlock rteinuse;
             $prtn = '*ERROR';
             dderm = 'Already in use ('
                   + %trimr(riucmd) + ')';
             exsr GetInfo;

650dD      //when %found(rteinuse) and riusessid = $psessid;
650dM      when %found(rteinuse);
             riucmd  = $pcmd;
             riupgm  = $ppgm;
             riuuser = $puser;
             exsr GetCurrStamp;
             riuts   = currstampsys;
             riuuc   = currstampuc;
             riucusr = #curruser;
             riujusr = #user;
             riujob  = #job;
             riunbr  = #jobnbr;

             update(e) riurec;
             if %error;
               $prtn = '*ERROR';
               dderm = 'Error updating RTEINUSE record for '
                     + %char($pwhse) + '/' + $prtid;
               $iutext10 = 'Cannot Set';
               $iutext30 = 'Cannot set. RTEINUSE Upd Err.';
             else;
               $prtn = '*OK';
               dderm = %trimr(riucmd) + ' lock set';
             endif;

           when not %found(rteinuse);
             riuwhse = $pwhse;
             riurtid = $prtid;
             riucmd  = $pcmd;
             riupgm  = $ppgm;
             riuuser = $puser;
             riusessid = $psessid;
             exsr GetCurrStamp;
             riuts   = currstampsys;
             riuuc   = currstampuc;
             riucusr = #curruser;
             riujusr = #user;
             riujob  = #job;
             riunbr  = #jobnbr;

             write(e) riurec;
             if %error;
               $prtn = '*ERROR';
               dderm = 'Error writing RTEINUSE record for '
                     + %char($pwhse) + '/' + $prtid;
               $iutext10 = 'Cannot Set';
               $iutext30 = 'Cannot set. RTEINUSE Wrt Err.';
             else;
               $prtn = '*OK';
               dderm = %trimr(riucmd) + ' lock set';
             endif;

         endsl;

         exsr WrtDDLOG;

650cA    return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WrtDDLOG   Write DDLOG record
     *----------------------------------------------------------------

     C     WrtDDLOG      begsr

     C                   call      'WRTDDLOG'
     C                   parm      $pwhse        ddWhse            3 0
     C                   parm      $prtid        ddRtid            5
     C                   parm      0             ddGrpId           7 0
     C                   parm      '4'           ddRecType         1
     C                   parm      ''            ddMovType         1
     C                   parm      ''            ddUsed            1
     C                   parm      0             ddFromPltId       7 0
     C                   parm      0             ddToPltId         7 0
     C                   parm      0             ddStop            2 0
     C                   parm      0             ddLbl#            7 0
     C                   parm      0             ddNewLbl#         7 0
     C                   parm      0             ddPcs             5 0
     C                   parm      ' '           ddCurUser        10
     C                   parm      #prog         ddpgm            10
     C                   parm      $pcmd         ddrtn            10
     C                   parm                    dderm            80

710aMC                   exsr      zzWrtRteLog

     C                   eval      ddrtn = ''
     C                   eval      dderm = ''
     C                   endsr

650aA*----------------------------------------------------------------
650aA*  zzWrtRteLog  Write GLORTELOG record
650aA*----------------------------------------------------------------
650aA
650aAC     zzWrtRteLog   begsr

     C                   call      'WRTRTELOG'
     C                   parm      $pwhse        ddWhse            3 0
     C                   parm      $prtid        ddRtid            5
     C                   parm      ''            ddmrid           26
     C                   parm      0             ddGrpId           7 0
     C                   parm      'INUSE'       ddGrpCode        10
     C                   parm      $pcmd         ddSubGrp         12
     C                   parm      '5'           ddType            1
     C                   parm      ''            ddCurUsr         10
     C                   parm      #prog         ddpgm            10
     C                   parm      ''            ddJobqTS         26
     C                   parm      ''            ddJobqUC         26

     C                   endsr

650bA*----------------------------------------------------------------
650bA*  wrtDebugParms  Write out debug parm record
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = 'sID:' + %trimr($pSessid) + ', '
                  + 'Cmd:' + %trimr($pCmd) + ', '
                  + 'Whs:' + %char($pWhse) + ', '
                  + 'Rtid:' + %trimr($pRtid) + ', '
                  + 'Pgm:' + %trimr($pPgm) + ', '
                  + 'Usr=' + %trimr($pUser)
                  + 'Rtn:' + %trimr($pRtn) + ', '
                  + 'it10:' + %trimr($iutext10) + ', '
                  + 'it30:' + %trimr($iutext30) + ', '
                  + 'icmd:' + %trimr($iucmd) + ', '
                  + 'ipgm:' + %trimr($iupgm) + ', '
                  + 'iusr:' + %trimr($iuuser) + ', '
                  + 'isid:' + %trimr($iusessid) + ', '
                  + 'ijob:' + %trimr($iujobname) + '/ '
                            + %trimr($iujobnbr) + '/ '
                            + %trimr($iujobuser) + ', '
                  + 'its:'  + %trimr($iuStamp);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
