      /copy qcopysrc,hspecs
     H dftactgrp(*NO)
     H actgrp(*CALLER)
     *----------------------------------------------------------------
     * Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETGCHIST   Get garbage collection history
     *  14 March 2016
     *  Dave Sommerville
     *
     *  Revisions
     *
700a *    04/07/16  DAS  7.00a
     *      - Added optional option for specific user id to use.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *  This program only collects GC information for GUI Tomcat
     *  servers. It is assumed those jobs a QP0ZSPWT that have
     *  a user id with DKT in it.
     *
     *  The PRTJVMJOB command with option *GCTABLE is used to
     *  retrieve the garbage collection data. This command only
     *  prints a report, which is copied to file qtemp/gcinfo.
     *
     *  Processing the records from the report assumes the following
     *  order of the records:
     *
     *    GC Cycle Number
     *    Current GC Cycle time
     *    Cycle start time
     *    Cycle end time
     *    Nursery Area Information
     *      Allocated space at start
     *      Allocated space at end
     *    Tenured Area
     *      Allocated space at start
     *      Allocated space at end
     *    Large Object Tenured Area
     *
     *  When we hit the 'Large Object Tenured Area' a record will
     *  be written to the GLOGCHIST file.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fglogchist uf a e           k disk
     Fgcinfo    if   f  100        disk    usropn

     *----------------------------------------------------------------
     *  User Space Prototype
     *----------------------------------------------------------------

     D  CrtUsrSpc      PR              *
     D   CrtSpcName                  20    const

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.qcmdexc
700aA /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

700aAD client          s             10
700aAD clientloc       s             10

     d alpha5          s              5
     d alpha7          s              7
     d i               s              5  0
     d cmd             s           3000    varying
     d currCycle       s                   like(gccycle)
     d currDur         s                   like(gcdur)
     d currEnd         s                   like(gcend)
     d currHeapEnd     s                   like(gcheapend)
     d currHeapEndM    s                   like(gcheapendm)
     d currHeapFre     s                   like(gcheapfre)
     d currHeapFreM    s                   like(gcheapfrem)
     d currHeapStr     s                   like(gcheapstr)
     d currHeapStrM    s                   like(gcheapstrm)
     d currJob         s                   like(gcjob)
     d currJobNbr      s                   like(gcjobnbr)
     d currJobUser     s                   like(gcjobuser)
     d currStart       s                   like(gcstart)
     d error           s               n
     d forever         s               n
     d heap            s               n
     d Jtypes          s              1    inz('*')
     d ListFormat      s              8
     d num7            s              7  0
     d NbrKeys         s             10i 0 inz(3)
700aAd singleUser      s               n
     d SpacePtr        s               *
     d Status          s             10
     d UserSpace       s             20    inz('GETGCHIST QTEMP')
     d UseStatus       s             10

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  API Data Structures
     *----------------------------------------------------------------

     DKeys             DS
     D*                                             Active job status
     D Key1                          10i 0 inz(101)
     D*                                             Job queue name
     D Key2                          10i 0 inz(1004)
     D*                                             Submitter's job name
     D Key3                          10i 0 inz(1904)

     DQUSLH            DS
     D*                                             Qus Ljob Header
     D QUSJN00                 1     10             inz('*ALL')
     D*                                             Job Name
     D QUSUN00                11     20             inz('*ALL')
     D*                                             User Name
     D QUSJNBR00              21     26             inz('*ALL')
     D*                                             Job Number

     DQUSL020001       DS                           based(ListPoint)
     D*                                             Qus JOBL0200
     D QUSJNU00                1     10
     D*                                             Job Name Used
     D QUSUNU00               11     20
     D*                                             User Name Used
     D QUSJNBRU00             21     26
     D*                                             Job Number Used
     D QUSIJI00               27     42
     D*                                             Internal Job Id
     D QUSTATUS01             43     52
     D*                                             Status
     D QUSJT01                53     53
     D*                                             Job Type
     D QUSJS00                54     54
     D*                                             Job Subtype
     D QUSERVED18             55     56
     D*                                             Reserved
     D QUSJIS                 57     57
     D*                                             Job Info Status
     D QUSRSV205              58     60
     D*                                             Reserved2
     D QUSNBRFR               61     64B 0
     D*                                             Number Fields Rtnd
     d KeyData                65    180

     DQUSKFI           DS            16
     D QUSLFIR01                      9B 0 overlay(QUSKFI:00001)
     D QUSKF00                        9B 0 overlay(QUSKFI:00005)
     D QUST0D01                       1    overlay(QUSKFI:00009)
     D QUSERVED33                     3    overlay(QUSKFI:00010)
     D QUSLD01                        9B 0 overlay(QUSKFI:00013)

     DQUSH0300         DS                  Based(GenDsPoint)
     D*                                             Qus Generic Header 0300
     D QUSUA00                 1     64
     D*                                             User Area
     D QUSSGH00               65     68B 0
     D*                                             Size Generic Header
     D QUSSRL00               69     72
     D*                                             Structure Release Level
     D QUSFN00                73     80
     D*                                             Format Name
     D QUSAU00                81     90
     D*                                             Api Used
     D QUSDTC00               91    103
     D*                                             Date Time Created
     D QUSIS00               104    104
     D*                                             Information Status
     D QUSSUS00              105    108B 0
     D*                                             Size User Space
     D QUSOIP00              109    112B 0
     D*                                             Offset Input Parameter
     D QUSSIP00              113    116B 0
     D*                                             Size Input Parameter
     D QUSOHS00              117    120B 0
     D*                                             Offset Header Section
     D QUSSHS00              121    124B 0
     D*                                             Size Header Section
     D QUSOLD00              125    128B 0
     D*                                             Offset List Data
     D QUSSLD00              129    132B 0
     D*                                             Size List Data
     D QUSNBRLE00            133    136B 0
     D*                                             Number List Entries
     D QUSSEE00              137    140B 0
     D*                                             Size Each Entry
     D QUSSIDLE00            141    144B 0
     D*                                             CCSID List Ent
     D QUSCID00              145    146
     D*                                             Country ID
     D QUSLID00              147    149
     D*                                             Language ID
     D QUSSLI00              150    150
     D*                                             Subset List Indicator
     D QUSRSV1               151    192
     D*                                             Reserved 1
     D QUSEPN                193    448
     D*                                             Entry Point Name
     D QUSRSV2               449    576
     D*                                             Reserved 2

     *----------------------------------------------------------------
     *  Standard API Error Data Structures
     *----------------------------------------------------------------

     DQUSEC            DS           116
     D QUSBPRV                 1      4B 0          inz(116)
     D QUSBAVL                 5      8B 0

     *----------------------------------------------------------------
     *  GCINFO file definition
     *----------------------------------------------------------------

     igcinfo    NS
     i                                  1    1  gciCtl
     i                                  2  100  gciRec

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pJobUser    Optionl. Only look at jobs for this user.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

700aAC     *entry        plist
700aAC                   parm                    $pJobUser        10

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  See if parameter was sent it

700aA /free
700aA    if %parms >= 1 and $pJobUser <> '';
700aA      singleUser = *on;
700aA    else;
700aA      singleUser = *off;
700aA    endif;
700aA /end-free

     *  Get client

      /free
         getclient(client: clientLoc);
      /end-free

     *  Create user space for file list information.

     C                   Eval      SpacePtr = CrtUsrSpc(UserSpace)

     *  Call API to list all 'BFC' jobs to user space.

     C                   eval      QusJN00 = 'QP0ZSPWT'

     C                   Call      'QUSLJOB'
     C                   Parm                    UserSpace
     C                   Parm      'JOBL0200'    ListFormat
     C                   Parm                    QusLH
     C                   Parm      '*ACTIVE'     Status
     C                   Parm                    QusEc
     C                   Parm                    Jtypes
     C                   Parm                    NbrKeys
     C                   Parm                    Keys

     *  Load general data structure.

     C                   eval      GenDsPoint = SpacePtr

     *  If List API was complete or partially complete

     C                   if        QuSIS00 = 'C' OR
     C                             QuSIS00 = 'P'
     C                   exsr      ProcessJobs
     C                   endif

     *  Bye, bye.

     C     bottom        tag
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  ProcessJobs - Process active jobs.
     *----------------------------------------------------------------

      /free
       begsr ProcessJobs;

         // Load the list data structure.

         ListPoint = GenDsPoint + QusOLD00;

         // Loop through list entries

         for i = 1 to QusNbrLE00;

           // Only work with jobs that have 'DKT' in the user name

700aA      if singleUser;
             if qusunu00 <> $pJobUser;
                ListPoint += QusSEE00;
                iter;
             endif;
700aA      else;
             if %scan('DKT': qusunu00) = 0;
                ListPoint += QusSEE00;
                iter;
             endif;
700aA      endif;

           // Delete temporary file

           cmd = 'dltf file(qtemp/gcinfo)';

           monitor;
             qcmdexc(%trim(cmd): %len(%trim(cmd)));
           on-error *all;
             error = *on;
           endmon;

           // Create temporary file

           cmd = 'crtpf file(qtemp/gcinfo) rcdlen(100) size(10000 5000 6)';

           monitor;
             qcmdexc(%trim(cmd): %len(%trim(cmd)));
           on-error *all;
             error = *on;
           endmon;

           // Run GC report

           cmd = 'prtjvmjob '
               + 'option(*GCTABLE) '
               + 'job('
               +       %trim(qusjnbru00) + '/'
               +       %trim(qusunu00) + '/'
               +       %trim(qusjnu00)
               +     ')';

           monitor;
             qcmdexc(%trim(cmd): %len(%trim(cmd)));
           on-error *all;
             error = *on;
           endmon;

           // Copy spool file to temp file

           cmd = 'cpysplf '
               + 'file(qpjvawrkvm) '
               + 'tofile(qtemp/gcinfo) '
               + 'job('
               +       %trim(#jobnbr) + '/'
               +       %trim(#user) + '/'
               +       %trim(#job)
               +     ') '
               + 'splnbr(*LAST)';

           monitor;
             qcmdexc(%trim(cmd): %len(%trim(cmd)));
           on-error *all;
             error = *on;
           endmon;

           // Extract data from report

           exsr ProcessRpt;

           // Point to next entry and loop

           ListPoint += QusSEE00;

         endfor;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ProcessRpt - Process active jobs.
     *----------------------------------------------------------------

      /free
       begsr ProcessRpt;

         open gcinfo;
         if %error();
           leavesr;
         endif;

         currCycle = 0;
         currJob = qusjnu00;
         currJobNbr = qusjnbru00;
         currJobUser = qusunu00;

         dow forever = forever;

           read gcinfo;
           if %eof(gcinfo);
             leave;
           endif;

           // See if we are starting new cycle

           if %scan('GC Cycle Number': gciRec: 3) > 0;

             currCycle = 0;
             currDur   = 0;
             currStart = '';
             currEnd   = '';
             currHeapStr = 0;
             currHeapEnd = 0;
             currHeapFre = 0;
             heap = *off;
             monitor;
               alpha5 = %subst(gcirec: 35: 5);
               currCycle = %dec(alpha5: 5: 0);
             on-error;
             endmon;
             iter;

           endif;

           // Skip record if not working within a cycle.

           if currCycle < 1;
             iter;
           endif;

           // Look for Large Object Tenured Area
           // Nothing to process after this, so write record.

           if %scan('Large Object Tenured Area': gciRec: 3) > 0;
             exsr WriteRec;
             currCycle = 0;
             iter;
           endif;

           // Look for duration

           if %scan('Current GC cycle time': gciRec: 5) > 0;
             monitor;
               alpha5 = %subst(gcirec: 56: 5);
               currDur = %dec(alpha5: 5: 0);
             on-error;
             endmon;
             iter;
           endif;

           // Look for start time

           if %scan('Cycle start time': gciRec: 5) > 0;
             currStart = %subst(gcirec: 47: 21);
             iter;
           endif;

           // Look for end time

           if %scan('Cycle end time': gciRec: 5) > 0;
             currEnd = %subst(gcirec: 47: 21);
             iter;
           endif;

           // Look for sections to grab heap info from

           if %scan('Nursery Area Information': gciRec: 3) > 0
             or  %scan('Tenured Area': gciRec: 3) > 0;
             heap = *on;
             iter;
           endif;

           // Look for Starting Heap

           if heap and %scan('Allocated space at start': gciRec: 5) > 0;
             monitor;
               alpha7 = %subst(gcirec: 55: 7);
               num7 = %dec(alpha7: 7: 0);
             on-error;
               num7 = 0;
             endmon;
             currHeapStr += num7;
             iter;
           endif;

           // Look for Ending Heap
           // This should be last record of Heap section, so set heap flag off

           if heap and %scan('Allocated space at end': gciRec: 5) > 0;
             monitor;
               alpha7 = %subst(gcirec: 55: 7);
               num7 = %dec(alpha7: 7: 0);
             on-error;
               num7 = 0;
             endmon;
             currHeapEnd += num7;
             heap = *off;
             iter;
           endif;

         enddo;

         // Close file

         close gcinfo;
         if %error();
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WriteRec - Write record to GLOGCHIST file
     *----------------------------------------------------------------

      /free
       begsr WriteRec;

         // Nothing to do if record already exists

         chain(n) (client: currJobUser: currJob: currJobNbr: currStart)
            glogchist;
         if %found(glogchist);
           leavesr;
         endif;

         // Otherwise, add record

         gcclient = client;
         gcjobuser = currJobUser;
         gcjob     = currJob;
         gcjobnbr  = currJobNbr;
         gccycle   = currCycle;
         gcdur     = currDur;
         gcstart   = currStart;
         gcend     = currEnd;
         gcheapstr = currHeapStr;
         gcheapend = currHeapEnd;
         gcheapfre = currHeapStr - currHeapEnd;
         eval(h) gcheapstrm = gcheapstr/1024;
         eval(h) gcheapendm = gcheapend/1024;
         eval(h) gcheapfrem = gcheapfre/1024;

         write(e) gcrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  CrtUsrSpc Procedure
     *
     *    Create extendable user space, return pointer to it.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     P  CrtUsrSpc      B                   export
     d  CrtUsrSpc      PI              *
     d   CrtSpcName                  20    const

      * Local Variables
     D PasSpcName      DS            20
     D  SLib                  11     20
     D ChgAttrDs       DS            13
     D  NumberAttr                    9B 0 inz(1)
     D  KeyAttr                       9B 0 inz(3)
     D  DataSize                      9B 0 inz(1)
     D  AttrData                      1    inz('1')
     D ListPtr         S               *
     D SpaceAttr       S             10    inz
     D SpaceAuth       S             10    INZ('*CHANGE')
     D SpaceLen        S              9B 0 INZ(4096)
     D SpaceReplc      S             10    INZ('*YES')
     D SpaceText       S             50
     D SpaceValue      S              1

      * Create the user space
     c                   move      CrtSpcName    PasSpcName
     C                   CALL      'QUSCRTUS'
     C                   PARM                    PasSpcName
     C                   PARM                    SpaceAttr
     C                   PARM                    SpaceLen
     C                   PARM                    SpaceValue
     C                   PARM                    SpaceAuth
     C                   PARM                    SpaceText
     C                   PARM      '*NO'         SpaceReplc
     C                   PARM                    QusEc
      * Get pointer to user space
     C                   CALL      'QUSPTRUS'
     C                   PARM                    PasSpcName
     C                   PARM                    ListPtr
      * Change user space to be extendable
     C                   CALL      'QUSCUSAT'
     C                   PARM                    Slib
     C                   PARM                    PasSpcName
     C                   PARM                    ChgAttrDs
     C                   PARM                    QusEc

     c                   return    ListPtr
     P  CrtUsrSpc      E
