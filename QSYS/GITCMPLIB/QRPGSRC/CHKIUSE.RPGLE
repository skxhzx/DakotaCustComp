650aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
650cA* NEW PROGRAMS SHOULD CALL CHKIUSE2.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CHKIUSE   Truck Build - Check route inuse status.
     *  25 July 2002
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    07/25/02  MLB  4.16
     *      - Created.
417 A*    10/08/03  RH   4.17
     *      - Add indicator 78 for locked record.
     *      - Add *INUSE3 & *INUSE4.
     *
500 A*    04/27/05  MLB  5.00
     *      - Enh: Add new client custom code support.
     *
650aA*    03/28/13  DAS  6.50a
     *      - Converted to ILE.
     *      - Added commande *CLEARCI, *CLEARUT.
     *      - Added logging to DDLOG.
     *
650bA*    04/09/13  DAS  6.50b
     *      - Restructured program to use subroutines.
     *      - Added command *GETIUSE
     *      - Added optional return parameters $pflag, $ptext10, $ptext30
     *
650cA*    12/23/13  DAS  6.50c
     *      - Revised to call new CHKIUSE2 program, except for commands
     *        *CHKCWGT and *CLRCWGT.
     *      - RHSHPD will no longer be used for standard Inuse locks.
     *        Instead, new file RTEINUSE will record inuse locks.
     *
650dA*    02/07/14  DAS  6.50d
     *      - Added RTEINUSE file.
     *      - Revised to only call CHKIUSE2 if RTEINUSE file exists.
     *
650eA*    04/15/14  RTR  6.50e
     *      - Added type 51 for import errors.
     *
700aA*    04/01/16   RH  7.00
     *    Original 11/22/13  MLB  6.50c missed in previous update
     *      - Fix: Revised pgm to check for valid numeric value in $PCMD
     *        string before allowing update to $pflag2. This was done to
     *        prevent error msg RNX0105-A character representation of a
     *        numeric value is in error from being logged to the joblog.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ledyard's
     *
LED A*    04/27/05  MLB  LED
     *      - Revised program to add new commands to support
     *        exporting of item catchweights before route is exported.
     *        New cmds: *CKCWGT and *CLRCWGT.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frtehed    uf   e           k disk
650dAFrteinuse  if   e           k disk    usropn
     *
500 A*----------------------------------------------------------------
500 A*  Customer id
500 A*
LED A /COPY QCOPYSRC,ID#LEDYARD
     D @getcl          c                   const('GETCLIENT')
LED D*             RHSHPD                          RHIUSE
LED A*----------------------------------------------------------------
LED A*  Re-Defintion data structure
LED A*
LED AD                 ds
LED AD  rhcwex                 7      7  0
LED A*
LED AD  rhiuse                 8      8  0
650bAD  rhiuse2                6      6  0
LED A*
LED AD  rhshpd                 1      8  0
LED A*

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  flag1          s              1  0
     D  flag2          s              1  0
     D  text10         s             10
     D  text30         s             30
650dAD  rteinuseExist  s               n

     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
500 A*
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     Irhrec
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Command.
     *              *CLEAR   - Clear inuse flag.
650aA*              *CLEARCI - Clear inuse flag called using CI option.
650aA*              *CLEARUT - Clear inuse flag called from utility menu.
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
     *
     *    Returned Parameters
     *      $PRTN     *OK      - Route available for processing.
     *                *ERROR   - Route not available for processing.
     *      $PFLAG    In-Use flag pos 8
     *      $PSUBFLAG In-Use flag pos 7
     *      $PTEXT10  In-Use status short text
     *      $PTEXT30  In-Use status long text
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prtn             8
650bAC                   parm                    $pflag            1 0
650bAC                   parm                    $psubflag         1 0
650bAC                   parm                    $ptext10         10
650bAC                   parm                    $ptext30         30

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

650cA*  Call CHKIUSE2 program if not Ledyard's commands
650dA*  and RTEINUSE file exists.
650cA
650cAC                   if        $pcmd <> '*CKCWGT '
650cAC                             and $pcmd <> '*CLRCWGT'
650dAC                             and rteinuseExist
650cAC                   exsr      zzzCHKIUSE2
650cAC                   return
650cAC                   endif

650bDC**   rhkey         chain     rtehed                             7978

     C                   select

     *    Clear inuse flag

     C                   when      $pcmd = '*CLEAR  '
650aAC                             or $pcmd = '*CLEARCI'
650aAC                             or $pcmd = '*CLEARUT'
650bAC                   exsr      zzClear

650bA*    Get inuse flag
650bA
650bAC                   when      $pcmd = '*GETIUSE'
650bAC                   exsr      zzGet

     *    Set In-Use flag

650bDC**                 when      $pcmd = '*INUSE1 '
650bMC                   when      %subst($pcmd:1:6) = '*INUSE'
650bAC                   exsr      zzSet

     *    Check route - If route marked for Inuse.

     C                   when      $pcmd = '*VERIFY '
650bAC                   exsr      zzVerify

LED A*    Mark route - Selected for Export catchwgt processing.

650bDC**                 when      client = ledyard  and
650bDC**                           $pcmd = '*CKCWGT '
650bMC                   when      $pcmd = '*CKCWGT '
650bAC                   exsr      zzSetCwgt

LED A*    Clear catchweight flag

LED AC                   when      $pcmd = '*CLRCWGT'
650bAC                   exsr      zzClearCwgt

     C                   endsl
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
500 A*
500 A* Get client id.
500 A*
500 AC                   call      @getcl
500 AC                   parm                    client           10
650dA
650dA* Open RTEINUSE file
650dA
650dAC                   open(e)   rteinuse
650dAC                   if        %error
650dAC                   eval      rteinuseExist = *off
650dAC                   else
650dAC                   eval      rteinuseExist = *on
650dAC                   close(e)  rteinuse
650dAC                   endif
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for RTEHED file.
     *
     C     rhkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     C                   endsr

650bA*----------------------------------------------------------------
650bA*  zzClear      Clear In-Use
650bA*----------------------------------------------------------------
650bA
650bAC     zzClear       begsr

     C     rhkey         chain     rtehed                             7978

     C                   select

     *    Route not found. Flag error.
     C                   when      *in79  or
     C                             not *in79  and
417  C                             not *in78  and
     C                             rhiuse = 0
     C                   eval      $prtn = '*OK     '
     C                   unlock    rtehed
650aAC                   if        *in79
650aAC                   eval      dderm = 'Record not found ('
650aAC                                   + %char($pwhse) + '/' + $prtid + ')'
650aAC                   else
650aAC                   eval      dderm = 'Already clear'
650aAC                   endif
     *
     *    Route found. Not available for processing.
     C                   when      not *in79  and
417  C                             not *in78  and
     C                             rhiuse <> 0
     C                   eval      $prtn = '*OK     '
     C                   eval      rhiuse = *zeros
650bAC                   eval      rhiuse2 = 0
     C                   update    rhrec
     C                   unlock    rtehed
     *
417  *  Record locked, can not process.
417  C                   when      *in78
417  C                   eval      $prtn = '*ERROR  '
650aAC                   eval      dderm = 'Record locked. Cannot clear.'
     *
     C                   endsl
650aAC                   exsr      zzWrtDDLOG

     C                   endsr

650bA*----------------------------------------------------------------
650bA*  zzClearCwgt   Clear catch wieght
650bA*----------------------------------------------------------------
650bA
650bAC     zzClearCwgt   begsr

     C     rhkey         chain     rtehed                             7978

LED AC                   select
LED A*
LED A*    Route not found. Flag Ok.
LED AC                   when      *in79  or
LED AC                             not *in79  and
LED AC                             not *in78  and
LED AC                             rhcwex = 0
LED AC                   eval      $prtn = '*OK     '
LED AC                   unlock    rtehed
LED A*
LED A*    Route found. Clear catchwgt export flag.
LED AC                   when      not *in79  and
LED AC                             not *in78  and
LED AC                             rhcwex <> 0
LED AC                   eval      $prtn = '*OK     '
LED AC                   eval      rhcwex = *zeros
LED AC                   update    rhrec
LED AC                   unlock    rtehed
LED A*
LED A*  Record locked, can not process.
LED AC                   when      *in78
LED AC                   eval      $prtn = '*ERROR  '
LED A*
LED AC                   endsl
     C                   endsr

650bA*----------------------------------------------------------------
650bA*  zzGet        Get In-Use
650bA*----------------------------------------------------------------
650bA
650bAC     zzGet         begsr
      /free

        chain(n)($pwhse: $prtid) rtehed;

        if %found(rtehed);

          $prtn = '*OK';

        else;

          $prtn = '*ERROR';
          rhiuse = 0;
          rhiuse2 = 0;
          text10 = 'Rt Not Fnd';
          text30 = 'Route Not Found';

        endif;

        exsr zzGetText;

      /end-free
     C                   endsr

650bA*----------------------------------------------------------------
650bA*  zzGetText    Get Text
650bA*----------------------------------------------------------------
650bA
650bAC     zzGetText     begsr
      /free

        select;

          when rhiuse = 0;
            text10 = '';
            text30 = '';

          when rhiuse = 1 and rhiuse2 = 0;
            text10 = 'Aloc/Build';
            text30 = 'Allocate & Build';

          when rhiuse = 1 and rhiuse2 = 1;
            text10 = 'Deleting';
            text30 = 'Deleting';

          when rhiuse = 1 and rhiuse2 = 2;
            text10 = 'Editing';
            text30 = 'Editing';

          when rhiuse = 1 and rhiuse2 = 3;
            text10 = 'Trk Detail';
            text30 = 'Truck Detail';

          when rhiuse = 2 and rhiuse2 = 0;
            text10 = 'Pick/Print';
            text30 = 'Pick & Print';

          when rhiuse = 2 and rhiuse2 = 1;
            text10 = 'Unallocate';
            text30 = 'Unallocating';

          when rhiuse = 2 and rhiuse2 = 2;
            text10 = 'Editing';
            text30 = 'Editing';

          when rhiuse = 2 and rhiuse2 = 3;
            text10 = 'Trk Detail';
            text30 = 'Truck Detail';

          when rhiuse = 2 and rhiuse2 = 4;
            text10 = 'Drag Drop';
            text30 = 'Drag Drop';

          when rhiuse = 2 and rhiuse2 = 5;
            text10 = 'Rebuild';
            text30 = 'Rebuild';

          when rhiuse = 2 and rhiuse2 = 6;
            text10 = 'Pick/Stage';
            text30 = 'Pick & Stage';

          when rhiuse = 3 and rhiuse2 = 0;
            text10 = 'Close Tran';
            text30 = 'Close Transactions';

          when rhiuse = 3 and rhiuse2 = 1;
            text10 = 'Unallocate';
            text30 = 'Unallocating';

          when rhiuse = 3 and rhiuse2 = 2;
            text10 = 'Export Cwt';
            text30 = 'Exporting Catch Weights';

          when rhiuse = 4 and rhiuse2 = 0;
            text10 = 'Exporting';
            text30 = 'Exporting';

          when rhiuse = 5 and rhiuse2 = 0;
            text10 = 'Importing';
            text30 = 'Importing';

650eA     when rhiuse = 5 and rhiuse2 = 1;
650eA       text10 = 'Imp Error';
650eA       text30 = 'Import Error';

          when rhiuse = 6 and rhiuse2 = 0;
            text10 = 'Merge/Prnt';
            text30 = 'Merge Orphans & Print';

          other;
            text10 = 'In-Use ' + %char(rhiuse) + '/' + %char(rhiuse2);
            text30 = 'In-Use ' + %char(rhiuse) + '/' + %char(rhiuse2);

        endsl;

        if %parms >= 5;
          $pFlag = rhiuse;
        endif;

        if %parms >= 6;
          $pSubFlag = rhiuse2;
        endif;

        if %parms >= 7;
          $pText10 = text10;
        endif;

        if %parms >= 8;
          $pText30 = text30;
        endif;

      /end-free
     C                   endsr

650bA*----------------------------------------------------------------
650bA*  zzSet        Set In-Use
650bA*----------------------------------------------------------------
650bA
650bAC     zzSet         begsr

      /free

          monitor;
            flag1 = %dec(%subst($pcmd:7:1):1:0);
          on-error;
            flag1 = 0;
          endmon;

700aA     if  %subst($pcmd:8:1) >= '0'
700aA     and %subst($pcmd:8:1) <= '9';
          monitor;
            flag2 = %dec(%subst($pcmd:8:1):1:0);
          on-error;
            flag2 = 0;
          endmon;
700a      else;
700a        flag2 = 0;
700a      endif;

      /end-free

     C     rhkey         chain     rtehed                             7978

     C                   select

     *    Route not found. Flag error.
     C                   when      *in79  and
417  C                             not *in78
     C                   eval      $prtn = '*ERROR  '
     C                   unlock    rtehed
650aAC                   eval      dderm = 'Route not found'

     *    Route found. Not available for processing.
     C                   when      not *in79  and
417  C                             not *in78  and
     C                             rhiuse <> 0
     C                   eval      $prtn = '*ERROR  '
     C                   unlock    rtehed
650aAC                   eval      dderm = 'Already in use ('
650aAC                                   + %char(rhiuse) + ')'
650bAC                   exsr      zzGetText
     *
     *    Route found. Available for processing.
     C                   when      not *in79  and
417  C                             not *in78  and
     C                             rhiuse = 0
     C                   eval      $prtn = '*OK     '
650bDC**                 eval      rhiuse = 1
650bAC                   eval      rhiuse = flag1
650bAC                   eval      rhiuse2 = flag2
     C                   update    rhrec
     C                   unlock    rtehed
     *
417  *  Record locked, can not process.
417  C                   when      *in78
417  C                   eval      $prtn = '*ERROR  '
650aAC                   eval      dderm = 'Record locked. Cannot lock.'
     *
     C                   endsl
650aAC                   exsr      zzWrtDDLOG

     C                   endsr

650bA*----------------------------------------------------------------
650bA*  zzSetCwgt   Set catch wieght
650bA*----------------------------------------------------------------
650bA
650bAC     zzSetCwgt     begsr

650bAC                   if        client <> ledyard
650bAC                   eval      $prtn = '*OK'
650bAC                   leavesr
650bAC                   endif

     C     rhkey         chain     rtehed                             7978

LED AC                   select
LED A*
LED A*    Route not found. Flag error.
LED AC                   when      *in79  and
LED AC                             not *in78
LED AC                   eval      $prtn = '*ERROR  '
LED AC                   unlock    rtehed
LED A*
LED A*    Route found. Not available for catchwgt export processing.
LED AC                   when      not *in79  and
LED AC                             not *in78  and
LED AC                             rhcwex <> 0
LED AC                   eval      $prtn = '*ERROR  '
LED AC                   unlock    rtehed
LED A*
LED A*    Route found. Available for catchwgt export processing.
LED AC                   when      not *in79  and
LED AC                             not *in78  and
LED AC                             rhcwex = 0
LED AC                   eval      $prtn = '*OK     '
LED AC                   eval      rhcwex = 1
LED AC                   update    rhrec
LED AC                   unlock    rtehed
LED A*
LED A*  Record locked, can not process.
LED AC                   when      *in78
LED AC                   eval      $prtn = '*ERROR  '
LED A*
LED AC                   endsl

     C                   endsr

650bA*----------------------------------------------------------------
650bA*  zzVerify     Verify In-Use
650bA*----------------------------------------------------------------
650bA
650bAC     zzVerify      begsr

     C     rhkey         chain     rtehed                             7978

     C                   select
     *
     *    Route not found. Flag error.
     C                   when      *in79  and
417  C                             not *in78
     C                   eval      $prtn = '*ERROR  '
     C                   unlock    rtehed
650bAC                   eval      rhshpd = 0
650bAC                   eval      text10 = 'Rt Not Fnd'
650bAC                   eval      text30 = 'Route Not Found'
     *
     *    Route found. Not available for processing.
     C                   when      not *in79  and
417  C                             not *in78  and
     C                             rhiuse <> 0
     C                   eval      $prtn = '*ERROR  '
     C                   unlock    rtehed
     *
     *    Route found. Available for processing.
     C                   when      not *in79  and
417  C                             not *in78  and
     C                             rhiuse = 0
     C                   eval      $prtn = '*OK     '
     C                   unlock    rtehed
     *
417  *  Record locked, can not process.
417  C                   when      *in78
417  C                   eval      $prtn = '*ERROR  '
650bAC                   eval      text10 = 'Rte Locked'
650bAC                   eval      text30 = 'Route Locked'

     C                   endsl

650bAC                   exsr      zzGetText
     C                   endsr

650aA*----------------------------------------------------------------
650aA*  zzWrtDDLOG   Write DDLOG record
650aA*----------------------------------------------------------------
650aA
650aAC     zzWrtDDLOG    begsr

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

     C**                 exsr      zzWrtRteLog

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

     *----------------------------------------------------------------
     *  zzzCHKIUSE2   Call CHKIUSE2
     *----------------------------------------------------------------

     C     zzzCHKIUSE2   begsr

     C                   call      'CHKIUSE2'
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm      'CHKIUSE'     $ppgm            20
     C                   parm      ''            $puser           10
     C                   parm      ''            $psessid         40
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

      /free

        if %parms >= 5;
          $pFlag = 0;
        endif;

        if %parms >= 6;
          $pSubFlag = 0;
        endif;

        if %parms >= 7;
          $pText10 = $iutext10;
        endif;

        if %parms >= 8;
          $pText30 = $iutext30;
        endif;

      /end-free
     C                   endsr
