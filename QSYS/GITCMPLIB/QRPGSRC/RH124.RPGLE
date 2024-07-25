     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RH124     Open routes - Delete
     *  10 September 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
405 A*    09/10/97  DAS  4.05
     *      - Created
406 A*    09/18/97  RH   4.06
     *      - Reduce qty allocated in slot file.
     *
414 A*    05/18/00  DAS  4.14
     *      - Change status check of crossdock slot to 'XD' from 'A'.
     *
416 A*    09/13/01  DAS  4.16
     *      - Revised to only change status of RTEHED record to '9'
     *        instead of deleting record.
     *      - Added code to get today's date.
     *
520 A*    04/27/09  MLB  5.20
     *      - Enh: Added client custom code support to program.
     *      - Enh: Converted program to ILE.
520aA*    04/27/09  MLB  5.20a
     *      - Fix: Revised program delete records from Order Header/
     *        Detail Misc. files when route is deleted from Dakota.
     *
640 A*    05/21/11  MLB  6.40
     *      - Fix: Revised program to delete Order Detail - Pick Slot
     *        file when route is deleted from Dakota.
640aA*    05/12/12  DAS  6.40a
     *      - Added *DLTWEB command to be used for determining which
     *        type of message to use.
700aA*    07/01/15  LMC  7.00a
     *      - Enh: Added RTETRAILER to ZZDEL.
     *      - Enh: Added TTRTE to ZZDEL.
     *      - Enh: Added RTELM to ZZDEL.
     *      - Fix: RTESUM logic was orphaning records. Code was using
     *        chain, needs to delete all records for the route.
740 A*    09/16/20  KDE  7.40
     *      - Revised zzdel to call exordh to remove order audit
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Y.Hata
     *
YHT A*    04/27/09  MLB  YHT
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
YHTaA*    02/18/10  MLB  YHTa
     *      - Revised YHT mod to add ovrdbf file to Retalix
     *        Order Header, member ORDER for Regular orders
     *        and member POS for Will-Call orders.
YHTbA*    04/25/12  MLB  YHTb
     *      - Revised YHTa mod to remove all ovrdbf cmd processing
     *        and move it into program, HRH124. Additional checking
     *        will be added to add correct H&S/IDS/Retalix data files
     *        library if the files library is not in the library list.
     *        This is being done to fix terminal errors that occur when
     *        the Host data files library is not in the library list
     *        when pgm, HRH124 is called.
     *      - Added INFDS to file RTEHED to determine Dakota data files
     *        library to be used for determining Host data files library
     *        to clear flag on call to HRH124.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordano's
     *
JOR A*    02/18/10  MLB  JOR
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
JORaA*    02/18/10  MLB  JORa
     *      - Added Jordano's to YHTa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman's
     *
SLB A*    08/08/11  MLB  SLB
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
SLBaA*    08/08/10  MLB  SLBa
     *      - Added Silberman's to YHTa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foods
     *
GLZ A*    11/03/11  MLB  GLZ
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
GLZaA*    11/03/11  MLB  GLZa
     *      - Added Glazier's to YHTa mod.
GLZbA*    10/29/13  MLB  GLZb
     *      - Fix: Revised pgm to retrieve H&S customer number from
     *        ORDHM to be passed to pgm, HRH124 so that D=Dakota flag
     *        can be correctly cleared from OHORDHP file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Andrews Foodservice
     *
AFS A*    12/03/12  MLB  AFS
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
     *      - Added AFS to YHTa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite Foodservice
     *
BIR A*    12/03/12  MLB  BIR
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
     *      - Added BIR to YHTa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: MJ Kellner
     *
MJK A*    12/03/12  MLB  MJK
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
     *      - Added MJK to YHTa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Renzi Foodservice
     *
RNZ A*    12/03/12  MLB  RNZ
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
     *      - Added RNZ to YHTa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sofo Foodservice
     *
SOF A*    12/03/12  MLB  SOF
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
     *      - Added SOF to YHTa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIP A*    12/03/12  MLB  VIP
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
     *      - Added VIP to YHTa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
     *
HKW A*    09/20/13  MLB  HKW
     *      - Revised program to call pgm EOPDOOI in library WMS
     *        to clear data that the customer order was sent to
     *        TruckBuilder(r) for picking. HK uses Foodman software.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Menu Maker
     *
GMM A*    08/10/19  MLB  GMM
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
     *      - Added GMM to YHTa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SGC Foodservice
     *
SGC A*    07/13/17  MLB  SGC
     *      - Revised program to call HRH124 to clear flag
     *        from Retalix customer order header that order
     *        was sent to Dakota for picking.
SGCaA*    07/13/17  MLB  SGCa
     *      - Added SGC to YHTa mod.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        CHAIN INDICATOR
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frtehed    uf   e           k disk
     F                                     rename(rhrec:record)
YHTbAF                                     infds(file1ds)
     Frtesum    uf   e           k disk
     Fordh3     uf   e           k disk
520aAFordhm     uf   e           k disk
     Fordd      uf   e           k disk
520aAForddm     uf   e           k disk
640 AFordds     uf   e           k disk
     Fcrossdk1  uf   e           k disk
406 AFslot4     uf   e           k disk
     F                                     rename(slrec:slrec4)
700aAFrtetraileruf   e           k disk
700aAFttrte     uf   e           k disk
700aAFrtelm     uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D msg             s             50    dim(1) ctdata perrcd(1)
520 A*----------------------------------------------------------------
520 A*  Customer id
520 A*
     D @getcl          c                   const('GETCLIENT')
520 A*
YHT A /copy qcopysrc,id#yhata
JOR A /copy qcopysrc,id#jordano
SLB A /copy qcopysrc,id#Silberm
GLZ A /copy qcopysrc,id#glazier
AFS A /copy qcopysrc,id#andrews
BIR A /copy qcopysrc,id#birite
MJK A /copy qcopysrc,id#mjkelln
RNZ A /copy qcopysrc,id#renzi
SOF A /copy qcopysrc,id#sofo
VIP A /copy qcopysrc,id#vip
HKW A /copy qcopysrc,id#hkw
GMM A /copy qcopysrc,id#gmm
SGC A /copy qcopysrc,id#sgc
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $prte                 22     26
     D  $prtid                27     31
     D  $ptruk                32     41
     D  $pstat                42     42
     D  $ptype                43     43
YHT A*----------------------------------------------------------------
YHT A*  Called Program parameters
YHT A*
YHT AD $lparm          ds
YHT AD  $lcmd                  1      8
YHT AD  $lprg                  9     18
YHT AD  $luky                 19     68
YHT AD  $lrtn                 69     76
YHT AD  $lerm                 77    136
YHT AD  $lmsg                 77     80
YHT A*
YHT A*   Redefine key
YHT A*
YHT AD  $lcmpn                19     21
YHT AD  $ldivn                22     24
YHT AD  $ldptn                25     27
YHT AD  $lcusn                28     37
YHT AD  $lornr                38     44  0
YHTbAD  $lrhtype              45     45
YHTbAD  $lbfcflib             46     55
YHT A*
YHT AD                 ds
YHT AD  $ocmpn                 1      3
YHT AD  $odivn                 4      6
YHT AD  $odptn                 7      9
YHT AD  $owhsn                10     12
YHT AD  $omemo                13     15
YHT AD  ohmisc                 1     20
416 A*----------------------------------------------------------------
416 A*  Called programs
416 A*
     D @cvtdt          c                   const('CVTDTE')
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
HKW AD foodman         c                   const('WMS/EOPDOOI')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  ertnum                 1      4p 0
     D  erdesc                 5     24
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D $msgf           s             10
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Working variables
     *
740 DD*error           s              1
     D forevr          s              1
     D today           s              8  0
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

YHTbA*----------------------------------------------------------------
YHTba*  File info data structures
YHTbA*----------------------------------------------------------------
YHTbA
YHTbA /COPY *libl/qcopysrc,C#file1ds
740 A
740 A*----------------------------------------------------------------
740 A*  Prototypes
740 A*----------------------------------------------------------------
740 A /copy qcopysrc,p.exordh
740 A
740 A*----------------------------------------------------------------
740 A*  Standard variables
740 A*----------------------------------------------------------------
740 A
740 AD/copy qcopysrc,c#stdvar
GLZbA
GLZbA*----------------------------------------------------------------
GLZbA*  Retalix Order Header Misc. /copy mbrs.
GLZbA
GLZbA /copy qcopysrc,ordhm1_vip
GLZbA /copy qcopysrc,ordhm2_vip
GLZbA /copy qcopysrc,ordhm3_vip
GLZbA /copy qcopysrc,ordhm4_vip
GLZbA /copy qcopysrc,ordhm5_vip

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Not used
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for delete.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *OK      - Record deleted successfully.
     *                         Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C     fileky        chain     record                             79
     C                   if        not *in79
     C                   exsr      zzdel
     C                   if        error = '0'
416 D**                   DELETRECORD
416 AC                   eval      rhstat = '9'
416 AC                   eval      rhstsd = today
416 AC                   time                    rhstst
416 AC                   update    record
     C                   exsr      zzok
     C                   endif
     C                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   endif
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
520 A*
520 A* Get client id.
520 A*
520 AC                   call      @getcl
520 AC                   parm                    client           10
520 AC                   parm                    cliloc           10
520 A*
     *
     C                   eval      forevr = *off
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR7975  Error while deleting record.
     *
     C     zm75          begsr
     C                   eval      #msgid = 'PIR7975'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR9803  Deleted record successfully.
     *
     C     zm9803        begsr
     C                   eval      #msgid = 'PIR9803'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDEL    Delete corresponding records.
     *
     C     zzdel         begsr
     C                   eval      error = *off
     *
     *   Delete RTESUM record.
     *
700aDC*    fileky        chain     rtesum                             7978
700aMC     fileky        setll     rtesum
700aAC                   dow       forevr = forevr
700aAC     fileky        reade     rtesum                               7879
700aAC                   if        *in79
700aAC                   leave
700aAC                   endif
700aA*
700aA*     If record is locked then send message back and abort.
700aA*
     C                   if        *in78
     C                   eval      error = *on
640aAC                   if        $pcmd = '*DLTWEB'
640aAC                   eval      $pmsg = 'Error getting RTESUM record'
640aAC                   eval      $prtn = '*ERROR  '
640aAC                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
640aAC                   endif
     C                   goto      enddel
     C                   else
     C                   delete    rsrec                                77
     C                   endif
700a C                   enddo
700aA*
700aA*   Delete RTETRAILER record.
700aA*
700aAC     fileky        chain     rtetrailer                         7978
700aAC                   if        *in78
700aAC                   eval      error = *on
700aAC                   if        $pcmd = '*DLTWEB'
700aAC                   eval      $pmsg = 'Error getting RTETRAILER record'
700aAC                   eval      $prtn = '*ERROR  '
700aAC                   else
700aAC                   exsr      zm75
700aAC                   eval      $prtn = '*PGMQ   '
700aAC                   endif
700aAC                   goto      enddel
700aAC                   else
700aAc                   if        %found(rtetrailer)
700aAC                   delete    rttrec                               77
700aAc                   endif
700aAC                   endif
700aA*
700aA*   Delete TTRTE record.
700aA*
700aAC     fileky        chain     ttrte                              7978
700aAC                   if        *in78
700aAC                   eval      error = *on
700aAC                   if        $pcmd = '*DLTWEB'
700aAC                   eval      $pmsg = 'Error getting TTRTE record'
700aAC                   eval      $prtn = '*ERROR  '
700aAC                   else
700aAC                   exsr      zm75
700aAC                   eval      $prtn = '*PGMQ   '
700aAC                   endif
700aAC                   goto      enddel
700aAC                   else
700aAc                   if        %found(ttrte)
700aAC                   delete    ttrrec                               77
700aAc                   endif
700aAC                   endif
700aA*
700aA*   Delete RTELM record.
700aA*
700aAC     fileky        chain     rtelm                              7978
700aAC                   if        *in78
700aAC                   eval      error = *on
700aAC                   if        $pcmd = '*DLTWEB'
700aAC                   eval      $pmsg = 'Error getting RTELM record'
700aAC                   eval      $prtn = '*ERROR  '
700aAC                   else
700aAC                   exsr      zm75
700aAC                   eval      $prtn = '*PGMQ   '
700aAC                   endif
700aAC                   goto      enddel
700aAC                   else
700aAc                   if        %found(rtelm)
700aAC                   delete    rlrec                                77
700aAc                   endif
700aAC                   endif
     *
     *   Delete order header records.
     *
     C     fileky        setll     ordh3
     C                   dow       forevr = forevr
     C     fileky        reade     ordh3                                7879
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     If record is locked then send message back and abort.
     *
     C                   if        *in78
640aAC                   if        $pcmd = '*DLTWEB'
640aAC                   eval      $pmsg = 'ORDH3 record locked'
640aAC                   eval      $prtn = '*ERROR  '
640aAC                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
640aAC                   endif
     C                   eval      error = *on
     C                   goto      enddel
     C                   endif
740 A
740 A*    Delete order audit  ORDHEXA
740 A
740 A /free
740 A    ohaaudflg = '';
740 A    ohaaudid = 0;
740 A    ohaaudcmp = '';
740 A    ohaaudby = 0;
740 A    exWhse = ohwhse;
740 A    monitor;
740 A      exordh ('*DELETE': exRtnCode: exRtnMsg: exWhse: ohord:
740 A              ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby);
740 A    on-error;
740 A    endmon;
740 A /end-free
     *
     *     Delete corresponding order detail records.
     *
     C     odkey         setll     ordd
     C                   dow       forevr = forevr
     C     odkey         reade     ordd                                 7677
     C                   if        *in77
     C                   leave
     C                   endif
     *
     *         If record is locked then send message back and abort.
     *
     C                   if        *in76
640aAC                   if        $pcmd = '*DLTWEB'
640aAC                   eval      $pmsg = 'ORDD record locked'
640aAC                   eval      $prtn = '*ERROR  '
640aAC                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
640aAC                   endif
     C                   eval      error = *on
     C                   goto      enddel
     C                   endif
     *
     *        Otherwise, delete order detail record.
     *
     C                   delete    odrec                                75
     *
405 D*R                   ENDDO
     *
     *     Delete corresponding crossdock records.
     *
406 D*R         ODKEY     SETLLCROSSDK1
406 MC     cdkey         setll     crossdk1
     C                   dow       forevr = forevr
406 D*R         ODKEY     READECROSSDK1               7677
406 MC     cdkey         reade     crossdk1                             7677
     C                   if        *in77
     C                   leave
     C                   endif
     *
     *         If record is locked then send message back and abort.
     *
     C                   if        *in76
640aAC                   if        $pcmd = '*DLTWEB'
640aAC                   eval      $pmsg = 'CROSSDK1 record locked'
640aAC                   eval      $prtn = '*ERROR  '
640aAC                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
640aAC                   endif
     C                   eval      error = *on
     C                   goto      enddel
     C                   endif
406 A*
406 A*        Otherwise, reduce allocated qty in slot.
406 A*
406 AC     keysl4        chain     slot4                              75
406 AC                   if        not *in75  and
414 MC                             slstat = 'XD'
414 D**         SLSTAT    ANDEQ'A '
406 A* Pre-allocate product in case receiving is done before picking.
406 AC                   eval      slalc1 = slalc1 - odqor1
406 AC                   sub       odqor2        slalc2
406 AC                   sub       odqor3        slalc3
406 AC                   update    slrec4
406 AC                   endif
     *
     *        Then, delete order cross dock record.
     *
     C                   delete    cdrec                                75
     *
     C                   enddo
405 AC                   enddo
520aA*
520aA*     Remove all order detail misc. records.
520aA*
520aAC     odkey         setll     orddm
520aAC                   dow       forevr = forevr
520aAC     odkey         reade     orddm
520aAC                   if        %eof(orddm)
520aAC                   leave
520aAC                   endif
520aAC
520aAC                   delete(e) omrec
520aAC                   enddo
640 A*
640 A*     Remove all order detail misc. records.
640 A*
640 AC     odkey         setll     ordds
640 AC                   dow       forevr = forevr
640 AC     odkey         reade     ordds
640 AC                   if        %eof(ordds)
640 AC                   leave
640 AC                   endif
640 AC
640 AC                   delete(e) osrec
640 AC                   enddo
     *
     *     Otherwise, delete order header record.
     *
     C                   delete    ohrec                                75
520aAC
520aAC     ohmkey        chain     ordhm
520aAC                   if        %found(ordhm)
520aAC                   delete(e) hmrec
520aAC                   endif
YHT A*
HKW AC                   select
HKW DC*                  if        client = yhata
HKW MC                   when      client = yhata
JOR AC                             or client = Jordanos
SLB AC                             or client = Silberman
GLZ AC                             or client = Glazier
AFS AC                             or client = Andrews
BIR AC                             or client = Birite
MJK AC                             or client = MJKellner
RNZ AC                             or client = Renzi
SOF AC                             or client = Sofofoods
SGC AC                             or client = SGC
VIP AC                             or client = VIP
GMM AC                             or client = MenuMaker
YHT AC                   exsr      zzresetrtx
HKW A*
HKW AC                   when      client = Hearnkirkwood
HKW AC                   exsr      zzresetfdman
HKW DC*                  endif
HKW MC                   endsl
     *
     C                   enddo
     *
     C     enddel        endsr
YHT A*
YHT A*----------------------------------------------------------------
YHT A*
YHT A*  ZZRESETRTX    Call HRH124 to clear Retalix Order flag.
YHT A*
YHT AC     zzresetrtx    begsr
YHT A*
GLZbAC                   if        %found(ordhm)
GLZbA*
GLZbAC                   eval      viphm1_base = hmmsc1
GLZbAC                   eval      viphm2_base = hmmsc2
GLZbAC                   eval      viphm3_base = hmmsc3
GLZbAC                   eval      viphm4_base = hmmsc4
GLZbAC                   eval      viphm5_base = hmmsc5
GLZbA*
GLZbAC                   else
GLZbA*
GLZbAC                   eval      viphm1_base = ' '
GLZbAC                   eval      viphm1_hmdted = 0
GLZbAC                   eval      viphm1_hmdtes = 0
GLZbAC                   eval      viphm2_base = ' '
GLZbAC                   eval      viphm3_base = ' '
GLZbAC                   eval      viphm4_base = ' '
GLZbAC                   eval      viphm5_base = ' '
GLZbAC                   endif
GLZbA*
YHT AC                   eval      $lcmd  = '*CLRBFC '
YHT AC                   eval      $lcmpn = $ocmpn
YHT AC                   eval      $ldivn = $odivn
YHT AC                   eval      $ldptn = $odptn
GLZbA*
GLZbAC                   if        ohcust = 0
GLZbAC                   eval      $lcusn = viphm2_ohcusn
GLZbAC                   else
GLZbA*
YHT AC                   evalr     $lcusn = %trimr(%editc(ohcust:'Z'))
GLZbAC                   endif
GLZbA*
YHT AC                   eval      $lornr = ohcord
YHTbAC                   eval      $lrhtype = rhtype
YHTbAC                   eval      $lbfcflib = f1library
YHT A*
YHT AC                   call      'HRH124'
YHT AC                   parm                    $lparm
YHT A*
YHT AC     endrtx        endsr
YHT A*
HKW A*----------------------------------------------------------------
HKW A*
HKW A*  ZZRESETFDMAN    Call EOPDOOI to clear Foodman flags.
HKW A*
HKW AC     zzresetfdman  begsr
HKW A*
HKW AC                   select
HKW AC                   when      f1library = 'PIRF'
HKW A*      Reset Production order.
HKW AC                   eval      $fdenv = 'P'
HKW AC                   other
HKW A*      Reset Test order.
HKW AC                   eval      $fdenv = 'T'
HKW AC                   endsl
HKW AC                   evalr     $fdord = %subst(%editc(ohcord:'Z'):2:6)
HKW A*
HKW AC                   call      foodman
HKW AC                   parm                    $fdenv            1
HKW AC                   parm                    $fdord            6
HKW AC                   parm      ' '           $fdrtn            1
HKW A*
HKW AC     endfdman      endsr
HKW A*
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
520aA*
520aA*  Define full key for ORDHM file.
520aA*
520aAC     ohmkey        klist
520aAC                   kfld                    ohwhse
520aAC                   kfld                    ohord
     *
     *  Define partial key for ORDD and CROSSDK1 files.
     *
     C     odkey         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
406 A*
406 A*  Define key for CROSSDK1 file.
406 A*
406 AC     cdkey         klist
406 AC                   kfld                    ohwhse
406 AC                   kfld                    ohord
406 AC                   kfld                    odseq
     *
406 A* SLOT4 file
406 A*
406 AC     keysl4        klist
406 AC                   kfld                    cdwhse
406 AC                   kfld                    cdwhdp
406 AC                   kfld                    oditem
406 AC                   kfld                    cdslot
416 A*
416 A*  Convert today's date into century format.
416 A*
416 AC                   eval      $cvcmd = '*CURCMD '
416 AC                   call      @cvtdt
416 AC                   parm                    $cvtdt
416 AC                   eval      today = $cvd8o
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
     C                   movea     $prte         $md(7)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Route
