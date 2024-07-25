      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
     *
     *
     * COMPILING. In order to compile this program you will need
     *            to use options which allow it to work correctly
     *            between machines. These options are---
     *
     *               COMMIT = *NONE
     *               RDB    = Machine name that you will connect to.
     *               DLYPRP = *YES
     *               SQLPKG = The name & library that you want to
     *                        use for the package. This will put the
     *                        package on the RDB machine that you
     *                        specify.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CW800       Catch Weight Log file
     *  07 March 2013
     *  Lynn McMahon
     *
650a *    03/07/13  LMC  6.50a
     *      - Created
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * More Notes
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

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
      *      *ADD              Add record to new CWLOG file
      *
      *      *CLEANUP          Cleanup - delete log records
      *
      *      *CHK4UPD          Mark previous log record obsolete
      *
      *      *UPDATE           Mark previous log record obsolete
      *
      *      *DELETE           Delete CWLOG records.
      *
      *      *GET              Get CWLOG record.
      *
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CWLOG
     D saveVer#        s                   like($cwver#)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.vfywhse
      /copy qcopysrc,p.cvtbar
      /copy qcopysrc,p.cvtdte

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D cwrec         e ds                  extname(CWLOG) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s                   like(cwwhse)

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D vfywhseCalled   s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D count           s              5p 0
     D DakotaCall      s               n
     D HostCall        s               n
     D CWFound         s               n
     D CWChanged       s               n

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
     d AAAInit         pr
     d AAAClose        pr
     d Add             pr
     d CleanUpCW       pr
     d DeleteCW        pr
     d FillDS          pr
     d FillRec         pr
     d GetCurrStamp    pr
     d GetCWInfo       pr
     d UpdateCW        pr
     d Chk4Update      pr
     d VfyAdd          pr
     d VfyFldWhse      pr             1  0
     d VfyFldCWSeq     pr             1  0

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  erfld1                 1     20
     D  erfld2                21     40
     D  erflvl                41     42p 0
     D  erclvl                43     44p 0
     *
     D  erqty1                 1      4p 0
     D  erqty2                 5      8p 0
     D  eruom                  9     13
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------


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

      /free
         $cwlog  = $pdata;
         $preturn = '*OK';
         $pmessage = ' ';
      /end-free

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See which system is calling the program.

      /free
        if %subst($psubcmd:1:1) = '%';
          DakotaCall = *on;
          HostCall   = *off;
          %subst($psubcmd:1:1) = '*';
        else;
          HostCall   = *on;
          DakotaCall = *off;
        endif;

         // Make sure the file exist on client box
         exec sql select count(*)
                  into :count
                  from systables
                  where name = 'CWLOG';

         If sqlstt <> sqlSuccess or count =0;
           $preturn = '*NOFILE';
           $pmessage = 'CWLOG file does not exist';
           return;
         endif;

         // See if we are just opening or closing program.

         select;

           when $psubcmd = '*OPEN';
             return;

           when $psubcmd = '*CLOSE';
             aaaclose();
             *inlr = *on;
             return;

         endsl;

         // Otherwise, do some initialization and move on.

         aaainit();
         error = *off;

         // Do what user has requested.

         select;


           when $psubcmd = '*ADD';
             VfyAdd();
             if not error;
               Add();
             endif;

           when $psubcmd = '*CLEANUP';
             CleanUpCW();

           when $psubcmd = '*CHK4UPD';
             Chk4Update();
             // was the catch weight changed?
             if cwchanged;
               UpdateCW();
               if not error;
                 Add();
               endif;
             endif;

           when $psubcmd = '*DELETE';
             DeleteCW();

           when $psubcmd = '*GET';
             GetCwInfo();

           when $psubcmd = '*UPDATE';
             UpdateCW();
             // now add the new log record
             if not error;
               Add();
             endif;


           other;
             error = *on;
             $preturn = 'INVLDSBCMD';
             $pmessage = 'Invalid subcommand '
                       + '(' + %trim($psubcmd) + ') '
                       + 'sent to ' + %trim(#pgm);

         endsl;

       // We are finished so get out

       $pdata = $cwlog;
       return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);
         $preturn = 'U:' + #status;
         $pmessage = 'U:'
                   + %trim(#pgm)
                   + '('
                   + %trim(%editc(#stmt:'Z'))
                   + ')-'
                   + #pgmmsg;
         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AAAInit      Pre-subcommand initialization.
     *----------------------------------------------------------------

     p AAAInit         b
     d AAAInit         pi

      /free

      /end-free
     p AAAInit         e

     *----------------------------------------------------------------
     *  AAAClose     Close Called Programs.
     *----------------------------------------------------------------

     p AAAClose        b
     d AAAClose        pi

      /free

         if vfyWhseCalled;
           vfyWhse('*CLOSE': '*NONE': $vwhse: $vdesc:
                   $vreturn: $vmessage: $vmsgk);
         endif;

      /end-free
     p AAAClose        e

     *----------------------------------------------------------------
     *  Add       Add CWLOG record
     *----------------------------------------------------------------

     p Add             b
     d Add             pi

      /free
         error = *off;


         // Initialize record fields

         clear cwrec;
         FillRec();

         GetCurrStamp();

         cwaddts = CurrStampSys;
         cwadduc = CurrStampUC;
         cwaddpgm = $cwaddpgm;
         cwaddemp = $cwaddemp;
         cwaddusr = $cwaddusr;
         cwaddjob = $cwaddjob;
         cwaddnbr = $cwaddnbr;

         cwchgts = cwaddts;
         cwchguc = cwadduc;
         cwchgpgm = cwaddpgm;
         cwchgemp = cwaddemp;
         cwchgusr = cwaddusr;
         cwchgjob = cwaddjob;
         cwchgnbr = cwaddnbr;

         // Create record

         exec sql insert into cwlog values(:cwrec);

         if sqlstt <> sqlSuccess;
           error = *on;
           $preturn = 'ERRADDREC4';
           $pmessage = 'Error Adding rec '
                     + '('
                     + %trim(%editc(cwwhse:'Z'))
                     + '/'
                     + %trim(%editc(cwselord:'Z'))
                     + '/'
                     + %trim(%editc(cwselseq:'Z'))
                     + '/'
                     + %trim(cwitem)
                     + '/'
                     + %trim(%editc(cwsellbl#:'Z'))
                     + '/'
                     + %trim(%editc(cwselcseq:'Z'))
                     + ')'
                     + '-' + 'CWLOG';
         endif;

      /end-free
     p Add             e


     *----------------------------------------------------------------
     *  DeleteCW  Delete catch weight infomation records
     *----------------------------------------------------------------

     p DeleteCW        b
     d DeleteCW        pi

      /free
         error = *off;

         // Initialize record fields

         clear cwrec;
         FillRec();

         GetCurrStamp();

         cwstat = 'D';

         cwchgts = CurrStampSys;
         cwchguc = CurrStampUC;
         cwchgpgm = $cwaddpgm;
         cwchgemp = $cwaddemp;
         cwchgusr = $cwaddusr;
         cwchgjob = $cwaddjob;
         cwchgnbr = $cwaddnbr;

         // Update record

         exec sql update cwlog
                  set cwstat = :cwstat,
                      cwchgts  =:cwchgts,
                      cwchguc  =:cwchguc,
                      cwchgpgm =:cwchgpgm,
                      cwchgemp =:cwchgemp,
                      cwchgusr =:cwchgusr,
                      cwchgjob =:cwchgjob,
                      cwchgnbr =:cwchgnbr
                  where cwwhse = :cwWhse
                    and cwselord  = :cwselord
                    and cwselseq  = :cwselseq
                    and cwitem    = :cwitem
                    and cwsellbl# = :cwsellbl#
                    and cwselcseq = :cwselcseq
                    and cwstat    = ' ';

         if sqlstt <> sqlSuccess;
           error = *on;
           $preturn = 'ERRDLTREC';
           $pmessage = 'Error Deleting rec '
                     + '('
                     + %trim(%editc(cwwhse:'Z'))
                     + '/'
                     + %trim(%editc(cwselord:'Z'))
                     + '/'
                     + %trim(%editc(cwselseq:'Z'))
                     + '/'
                     + %trim(cwitem)
                     + '/'
                     + %trim(%editc(cwsellbl#:'Z'))
                     + '/'
                     + %trim(%editc(cwselcseq:'Z'))
                     + ')'
                     + '-' + 'CWLOG';
         endif;



      /end-free
     p DeleteCW        e



     *----------------------------------------------------------------
     *  CleanUpCW  Cleanup - delete the cwlog records from file
     *----------------------------------------------------------------

     p CleanupCW       b
     d CleanUpCW       pi

      /free
         error = *off;

         // Initialize record fields

         clear cwrec;
         FillRec();

         // Update record

         exec sql Delete from cwlog
                  where cwwhse = :cwWhse
                    and cwselord  = :cwselord
                    and cwselseq  = :cwselseq
                    and cwitem    = :cwitem
                    and cwsellbl# = :cwsellbl#
                    and cwselcseq = :cwselcseq;

         if sqlstt <> sqlSuccess;
           error = *on;
           $preturn = 'ERRDLTREC';
           $pmessage = 'Error Deleting rec '
                     + '('
                     + %trim(%editc(cwwhse:'Z'))
                     + '/'
                     + %trim(%editc(cwselord:'Z'))
                     + '/'
                     + %trim(%editc(cwselseq:'Z'))
                     + '/'
                     + %trim(cwitem)
                     + '/'
                     + %trim(%editc(cwsellbl#:'Z'))
                     + '/'
                     + %trim(%editc(cwselcseq:'Z'))
                     + ')'
                     + '-' + 'CWLOG';
         endif;



      /end-free
     p CleanUpCW       e

     *----------------------------------------------------------------
     *  FillDS   Move record fields into data structure fields
     *----------------------------------------------------------------

     p FillDS          b
     d FillDS          pi

      /free

        $cwWhse    = cwWhse;
        $cwSelOrd  = cwSelOrd;
        $cwSelSeq  = cwSelSeq;
        $cwItem    = cwItem;
        $cwSelLbl# = cwSelLbl#;
        $cwSelTrn# = cwSelTrn#;
        $cwSelCSeq = cwSelCSeq;
        $cwscan    = cwscan;
        $cwentflg  = cwentflg;
        $cwWgtlbs  = cwWgtlbs;
        $cwstat    = cwstat;
        $cwaddts   = cwaddts;
        $cwadduc   = cwadduc;
        $cwaddpgm  = cwaddpgm;
        $cwaddemp  = cwaddemp;
        $cwaddusr  = cwaddusr;
        $cwaddjob  = cwaddjob;
        $cwaddnbr  = cwaddnbr;

        $cwchgts  = cwchgts;
        $cwchguc  = cwchguc;
        $cwchgpgm = cwchgpgm;
        $cwchgemp = cwchgemp;
        $cwchgusr = cwchgusr;
        $cwchgjob = cwchgjob;
        $cwchgnbr = cwchgnbr;

      /end-free
     p FillDS          e

     *----------------------------------------------------------------
     *  FillRec      Fill record fields
     *----------------------------------------------------------------

     p FillRec         b
     d FillRec         pi

      /free

        cwwhse    = $cwWhse;
        cwSelOrd  = $cwSelOrd;
        cwSelSeq  = $cwSelSeq;
        cwitem    = $cwItem;
        cwSelLbl# = $cwSelLbl#;
        cwSelTrn# = $cwSelTrn#;
        cwSelCSeq = $cwSelCSeq;
        cwscan    = $cwscan;
        cwentflg  = $cwentflg;
        cwWgtLbs  = $cwwgtlbs;
        cwstat    = ' ';

      /end-free
     p FillRec         e

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

     *----------------------------------------------------------------
     *  GetCWInfo    Get CWLOG records
     *----------------------------------------------------------------

     p GetCWInfo       b
     d GetCWInfo       pi

      /free

         exec sql select * into :cwrec
                  from CWLOG
                  where cwwhse = :$cwwhse
                    and cwselord  = :$cwselord
                    and cwselseq  = :$cwselseq
                    and cwitem    = :$cwitem
                    and cwsellbl# = :$cwsellbl#
                    and cwselcseq = :$cwselcseq;

         if sqlstt = sqlSuccess;
           CWFound = *on;
         else;
           CWFound = *off;
         endif;

      /end-free
     p GetCWInfo       e

     *----------------------------------------------------------------
     *  UpdateCW  Mark previous log record obsolete
     *----------------------------------------------------------------

     p UpdateCW        b
     d UpdateCW        pi

      /free
         error = *off;


         // Initialize record fields

         clear cwrec;
         FillRec();

         GetCurrStamp();

         cwstat = 'O';

         cwchgts = CurrStampSys;
         cwchguc = CurrStampUC;
         cwchgpgm = $cwaddpgm;
         cwchgemp = $cwaddemp;
         cwchgusr = $cwaddusr;
         cwchgjob = $cwaddjob;
         cwchgnbr = $cwaddnbr;

         // Update record

         exec sql update cwlog
                  set cwstat = :cwstat,
                      cwchgts  =:cwchgts,
                      cwchguc  =:cwchguc,
                      cwchgpgm =:cwchgpgm,
                      cwchgemp =:cwchgemp,
                      cwchgusr =:cwchgusr,
                      cwchgjob =:cwchgjob,
                      cwchgnbr =:cwchgnbr
                  where cwwhse = :cwWhse
                    and cwselord  = :cwselord
                    and cwselseq  = :cwselseq
                    and cwitem    = :cwitem
                    and cwsellbl# = :cwsellbl#
                    and cwselcseq = :cwselcseq
                    and cwstat    = ' ';

         if sqlstt <> sqlSuccess;
           error = *on;
           $preturn = 'ERRUPDREC';
           $pmessage = 'Error Updating rec '
                     + '('
                     + %trim(%editc(cwwhse:'Z'))
                     + '/'
                     + %trim(%editc(cwselord:'Z'))
                     + '/'
                     + %trim(%editc(cwselseq:'Z'))
                     + '/'
                     + %trim(cwitem)
                     + '/'
                     + %trim(%editc(cwsellbl#:'Z'))
                     + '/'
                     + %trim(%editc(cwselcseq:'Z'))
                     + ')'
                     + '-' + 'CWLOG';
         endif;

      /end-free
     p UpdateCW        e

     *----------------------------------------------------------------
     *  Chk4Update  check to see if the catch weight send is different
     *----------------------------------------------------------------

     p Chk4Update      b
     d Chk4Update      pi

      /free
         error = *off;


         // Initialize record fields

         clear cwrec;
         FillRec();

         // Check to see if weight is changed

         exec sql select * into :cwrec
                  from cwlog
                  where cwwhse = :cwWhse
                    and cwselord  = :cwselord
                    and cwselseq  = :cwselseq
                    and cwitem    = :cwitem
                    and cwsellbl# = :cwsellbl#
                    and cwselcseq = :cwselcseq
                    and cwwgtlbs  = :cwwgtlbs;

         if sqlstt = sqlSuccess;
           cwchanged = *off;
         else;
           cwchanged = *on;
         endif;

      /end-free
     p Chk4Update      e

     *----------------------------------------------------------------
     *  VfyAdd       Verify information for add
     *----------------------------------------------------------------

     p VfyAdd          b
     d VfyAdd          pi

      /free

         // Validate Fields

         if VfyFldWhse() < 0;
           return;
         endif;

         if VfyFldCWSeq() < 0;
           return;
         endif;

      /end-free

     p VfyAdd          e

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Field Verification Routines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  vfyFldCWSeq   Verify CW Seq# sent
     *----------------------------------------------------------------

     p VfyFldCWSeq     b
     d VfyFldCWSeq     pi             1  0

      /free

         if $cwselcseq = 0;
           error = *on;
           $preturn  = 'CWSEQ#';
           $pmessage = 'Error: CW Seq# cannot be zero';
           return -1;
         endif;

         return 0;
      /end-free

     p VfyFldCWSeq     e


     *----------------------------------------------------------------
     *  vfyFldWhse    Verify warehouse
     *----------------------------------------------------------------

     p VfyFldWhse      b
     d VfyFldWhse      pi             1  0

      /free

         vfyWhseCalled = *on;
         vfyWhse('*VERIFY': '*NONE': $cwWhse: $vdesc:
                 $vreturn: $vmessage: $vmsgk);

         select;

           when %error;
             error = *on;
             $preturn  = 'CALLERROR';
             $pmessage = 'Error occured on call to VFYWHSE/'
                       + %trim($vcommand) + ' from ' + #pgm;
             return -1;

           when $vreturn <> '*OK';
             error = *on;
             $preturn = $vreturn;
             $pmessage = $vmessage;
             return -1;

         endsl;

         return 0;
      /end-free

     p VfyFldWhse      e


