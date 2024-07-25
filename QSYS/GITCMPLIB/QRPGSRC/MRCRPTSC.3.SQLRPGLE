     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H option(*srcstmt:*nodebugio)
     H bnddir('QC2LE')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  MRCRPTSCH  MRC Report Schedule Processor
     *  02 August 2018
     *  Kenneth Elder
     *
     *    08/02/18  KDE  7.20
     *      - Created
720a *    11/04/18  KDE  7.20a
     *      - Generate and Pass PDF Header/Footer
720b *    11/22/18  KDE  7.20b
     *      - Use special lookup code for specific Reports and Parms within
     *        that report
720c *    11/30/18  KDE  7.20c
     *      - Use / instead of - for special formatted TimeStamp fields
     *      - Special logic for R30700.
720d *    12/06/18  KDE  7.20d
     *      - Change how schedule entry deletes are found using sequel
720e *    12/07/18  RBD  7.20e
     *      - Add user report description to email subject.
720f *    12/14/18  KDE  7.20f
     *      - Fix PM runtime issue as 12 Noon passes
720g *    01/02/19  RBD  7.20g
     *      - Before writing new schedule entry delete any bfcmrcrse
     *        records for the same report and sequence where stat=U.
     *      - If current time +2 min >= seschtime do not write a new
     *        schedule entry.
     *      - Bump days to 365 to purge old records. Also changed
     *        purge to be based on add date rather than update date.
     *      - Only update process t/s for status U recs.
     *      - Added special code for virtual slots only parm in slot
     *        listing.
730a *    01/16/19  KDE  7.30a
     *      - Correct problem with MonthToDate routine that calculating
     *        Ending date correct
730b *    01/17/19  RBD  7.30b
     *      - Reinstate schEntryFound code starred out by 720g.
730c *    01/21/19  KDE  7.30c
     *      - Make several misc. changes for reports called directly
     *        from iSeries via rpg or cl
730d *    01/24/19  DAS  7.30d
     *     - Revised ForceCase logig. It was converting parms like
     *       OHRTE to ohrte.
     *     - Created FixCase subprocedure to be called instead of
     *       multiple calls to ForceCase. FixCase will call ForceCase.
     *
730e *    01/30/19  RBD  7.30e
     *     - New bfcmrcrse fields: output format, report name, url,
     *       email to addys, email subject and database source.
     *
730f *    02/04/19  DAS  7.30f
     *     - Added &r0 and &calcula to FixCase.
     *
730g *    02/13/19  RBD  7.30g
     *     - Added logic to prevent rerunning scheduled report if
     *       time is changed and the report has already ran today.
     *
730h *    02/14/19  KDE  7.30h
     *     - Added override for BFCREPORTS.R02500 to use special html file
     *
730i *    02/20/19  KDE  7.30i
     *     - Add override to checkbox parms for R23800
     *
730j *    02/26/19  KDE/RBD  7.30j
     *     - When field PIRTRAN/PTEMP# is subtotaled in a report, program
     *       RPTGETQ changes the # to P_, as P_ is the equivalent of #
     *       in MRC.  Then this program changes the P_ to %23 because %23
     *       is the equivalent of # in a url.  So if another field ending
     *       in # is used in a subtotal simply mimic this same logic.
     *
730k *    04/12/19  KDE      7.30k
     *     --  Before taking this mod forward MAKE SURE YOU REPLACE all
     *     --  PM280xx and M280xx in Mods and PIRSQL libraries.  Some
     *     --  options changes positions in *MRCRPT option record
     *     - Add options OPINCLD, OPINCLDT, OPRPTDIR, OPDYSARC, OPDYSPUR
     *       to options record and logic to go along with these changes
     *
730l *    04/16/19  KDE      7.30l
     *     - Mimic mod 7.30j for field LBIEMP# as subtotal in report R32300
     *     - Add logic for current minus 2 days for date
     *
730m *    04/29/19  KDE      7.30m
     *     - Mod 730k missed places where dirBase should have been set
     *
730n *    05/08/19  KDE      7.30n
     *     - Mod 730k and removed days archive and days purge.  Now
     *       handled in M29300 when defining ifs directory to purge
     *
730o *    06/25/19  KDE  7.30O
     *     - Add month ago data variables
     *
730p *    07/11/19  KDE  7.30p
     *     - Add mod for Report R323xx to build and pass a custom timestamp
     *       using the import date and time from Route Header. Greco wanted
     *       the ability to run for a date/time range.
     *     - Also add ending date of today for the *MINUS dates
     *     - Also add ending date for today plus '9' dates
730q *    07/16/19  KDE  7.30q
     *     - Add ability to call Report Work File Build prior to running report
730r *    09/05/19  KDE      7.30r
     *     - Mimic mod 7.30j for field SXLBL# as subtotal in report R20300
     *       and SXTRN# as subtotal in report R20300
     *     - Also manipulate Time Stamp for certain reports
730s *    09/12/19  KDE      7.30s
     *     - Remove warehouse from BFCMRCRCFG file since global file
     *     - Be sure to bring across latest BFCMRCRCFG file, and pgms
     *       R29901 or later and update glomenuitm, RPTPRM, and RPTGETQ
730t *    09/30/19  KDE      7.30t
     *     - Escape > sign for URL to %3E
730u *    12/11/19  KDE      7.30u
     *     - Change R32300 to run work file build.  This mod require
     *       R32304 or higher in MRC. Also requires files BFCMRCRCFG,
     *       GLORPTQ, GLORPTQT, and GLORPTV refreshed from DEV2.  Objects
     *       RPG UPDSUM011, file SUM011, CMD UPDSUM011, RPG R32300 and
     *       RPTGETQ should all be taken as part of this mod as well
730v *    12/17/19  KDE      7.30v
     *     - Change to override R007<>1 to blank for R28100
730w *    01/03/20  KDE      7.30w
     *     - Change All Available Data date range to include thru
     *       point in time.  It was cutting off as of yesterday
740  *    01/28/20  KDE      7.40
     *     - When field CWEXCP/CXLBL# is subtotaled in a report, program
     *       RPTGETQ changes the # to P_, as P_ is the equivalent of #
     *       in MRC.  Then this program changes the P_ to %23 because %23
     *       is the equivalent of # in a url.  So if another field ending
     *       in # is used in a subtotal simply mimic this same logic.
     *       Do same for field CWEXCP CXTRN#.
740a *    01/28/20  KDE      7.40a
     *     - Add logic for new version of R315xx starting at version 2
     *       where it will use a timestamp for the time range as well as
     *       the date.
740b *    03/20/20  KDE      7.40b
     *     - Escape < sign for URL to %3C
740c *    04/09/20  KDE      7.40c
     *     - Corrected issue where TimestampDate sub-procedure was getting
     *       index error on %replace
740d *    05/19/20  KDE      7.40d
     *     - Corrected timestamp value for R20300
740e *    05/20/20  KDE      7.40e
     *     - Replicate changes for R31500 time change for R20300
740f *    05/29/20  KDE      7.40f
     *     - Setup work file build for R358xx (Empty Pick Slot w/Ovf)
740g *    07/10/20  KDE      7.40g
     *     - Replicate R20300 timestamp changes for R36700
740h *    08/19/20  KDE      7.40h
     *     - Make parm override changes for report R28800.
740i *    08/26/20  KDE      7.40i
     *     - Pass blank parm for Returns when calling build work file
     *       for R323xx.  Returns were dropped as selection but blank passed
740j *    12/07/20  KDE  7.40j
     *      - Flip checkbox value for R002, report R04100 from 1 to Y,
     *        and 0 to N
750a *    03/11/21  KDE  7.50a
     *      - Add exception for R007 and R008 for report R06405 Expired Items
750b *    06/07/21  KDE      7.50b
     *     - Enh: Fix to run with RPTOVRDTL for OUTQ only.  Other parms
     *       not currently used.
750c *    10/25/21  KDE      7.50c
     *     - Enh: Use *YESTERDAY and *DYESTERDAY for yesterday
750d *    12/30/21  KDE      7.50d
     *     - Enh: Use outfmt 15 for excel for Slot Listing beyond version R08916
760  *    08/17/22  KDE      7.60
     *     - Enh: Ignore certain scheduled jobs unless called manually.  We are
     *       using these jobs to understand what email addresses at certain times
     *       of a day to send error reports for interfaces
760a *    08/22/22  KDE      7.60a
     *     - Enh: Add several reports to the Build Work File routine
     *     - Enh: Add preprocess routine for Reports ran via direct
     *       calls to build a work file when necessary
760b *    11/29/22  KDE      7.60b
     *     - Enh: If subject is passed use that in email
760c *    12/28/22  KDE      7.60c
     *     - Enh: Flip checkbox value from 1 and 0 to Y and N for
     *       "Omit Zero Employee"
760d *    01/06/23  KDE      7.60d
     *     - Enh: Ignore R42600 unless called manually.
760e *    01/11/23  KDE      7.60e
     *     - Enh: Change to write only first 500 bytes of URL to BFCNRCRSE
770a *    03/28/23  KDE      7.70a
     *     - Enh: Add code to build work file for report R42900
770b *    06/28/23  KDE      7.70b
     *     - Fix: Fix URL outfmt for report R089xx.  Requires type 15 vs. 13 for excel
770c *    06/29/23  KDE      7.70c
     *     - Enh: Change subject for Interface Error emails
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
ADFa *    05/10/21  RH   ADFa
     *      - Print four copies of R30200(Truck Map)
     *----------------------------------------------------------------
     *  Client Custom Revisions: Panos
PANa *    04/19/22  KDE  PANa
     *     - Enh: Add hardcode to generate CSV file for scheduled R203xx
     *       (Selection Exceptions) to specific IFS directory
PANb *    05/02/22  KDE  PANb
     *     - Enh: Add warehouse to end of CSV file
PANc *    07/05/22  KDE  PANc
     *     - Enh: Look for only UCI3 type in GLOUCICD.  Causing dups
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertrams
SBRa *    02/22/21  KDE  SBRa
     *      - Print three copies of R30200(Truck Map)
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore
SFPa *    01/25/21  KDE  SFPa
     *      - Print Route Notes (R369xx) to additional printer
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sunrise
SUNa *    09/29/21  KDE  SUNa
     *      - Pass drawer for Truck Map on printer override
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcmrcrcfgif   e           k disk
     Fbfcmrcrprmif   e           k disk
     Fbfcmrcrse uf a e           k disk
750bAfrptovrdtl if   e           k disk
750bAfreports   if   e           k disk
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      *copy qcopysrc,c#stdsql

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D serec         E Ds                  Extname(Bfcmrcrse)
     d serecsql        ds           331
     d   s_bswhse                     3  0 overlay(serecsql)
     d   s_bsrptpgm                  20    overlay(serecsql:*next)
     d   s_bsschseq                   3  0 overlay(serecsql:*next)
     d   s_bsvalue                  300    overlay(serecsql:*next)
     d   s_secount                    5  0 overlay(serecsql:*next)

ADFaA*----------------------------------------------------------------
ADFaA*  Customer id
ADFaA*----------------------------------------------------------------
ADFaA
ADFaA /copy qcopysrc,id#ADF
PANaA /copy qcopysrc,id#PAN
SBRaA /copy qcopysrc,id#SBR
SUNaA /copy qcopysrc,id#SUN
SFPaA /copy qcopysrc,id#SFP

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     d pWhse           s              3  0
     d pRptPGm         s             20
720a d whsDesc         s             30
720a d dateDesc        s             20
720a d pdfHeadWhse     s             50
720a d pdfHeadTitle    s             60
720a d pdfDateTime     s             40
720a d pdfFoot         s             75
     d beginFmt        s              5  0
730uAd calcula005      s              8
730uAd calcula006      s              8
730uAd calcula014      s              2
730uAd calcula015      s              2
730uAd calcula016      s              2
730uAd calcula017      s              2
     d endFmt          s              5  0
730pAd fromDt          s              8
730pAd fromHr          s              2
730pAd fromMin         s              2
730pAd toDt            s              8
730pAd toHr            s              2
730pAd toMin           s              2
     d closeScheduler  s               n
     d currrptpgm      s             20
     d cmdToRun        s           3000
     d dateLength      s              3  0
     d dateprm         s               n
     d filepath        s            100a
     d emailSubject    s            100a
     d emailBody       s           5000a
ADFaAd iCopies         s              2  0
     d jobtest         s             10
     d outfmt          s              2
750bAd nextQ           s             10
720gAd numDays         s              4  0
720oAd numMonths       s              4  0
SUNaAd pDrawer         s              7
     d PrinterQ        s             10
     d pRptOrtp        s              1
     d parmName        s             10
     d parmValue       s             45
     d parmEnd         s              5  0
     D Returncode      S             10I 0
730qAd rptTimeStamp    s             26
     d sellevl         s              4
     d selq#           s              5  0
     d wkatyp          s              1
     d preturn         s             10
     d pgmdesc         s             30
     d pgmselection    s            350
     d levelselection  s            150
     d nonHtmlDate     s            100
     d nonHtmlDPRM     s            100
     D NullString      C                   -1
770cAd stgBatId        s             11
770cAd stgType         s             10
     D Success         C                   0
     d scriptDir       s            256
     d rptDir          s            256
730kAd dirBase         s            256
     d rptnam          s            100
     d gsCmd           s            100
     d pStmf           s            100
     D sqlSuccess      c                   '00000'
PANaAd ifsPath         s            200a
PANaAd sqlWhere        s           1000
PANaAd rptWTD          s               n
PANaAd rptpWTD         s               n
     D SqlStmt         s           2000    inz(' ')
     d oURL            s           3000
760eAd oURLSE          s            500
     d oEMAIL          s           1000
     d oEMAILYN        s              1
     d oport           s              5
     d pos             s              3  0
     d schEntryFound   s               n
     d wkschseq        s              3  0
     d wkday           s              1  0
     d wkschtime       s              5
     d sndmsgid        s              7
     d sndmsgfile      s             20
     d sndmsgdata      s           1000
     d weekday         s              3
     d $time_a         s              8a
     d currentTime     s              5
720gAd curTimPlus2     s              5
720gAd curTimPlus2USA  s               t
     d currentTS       s               z
720dAd workTS          s               z
750bAd wkDevd          s             10
750bAd wkOutq          s             10
     d lowerCase       c                   'abcdefghijklmnopqrstuvwxyz'
     d upperCase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     d selcount        s              3  0
730aAd upURL           s           3000
750aAd r008hold        s              5

      *  Client Name Data Area
     dpirclient        ds            10    DTAARA('PIRCLIENT')

     d selDS           ds                  inz
     d  selArray                           dim(50)
     d   selTable                     1    overlay(selArray:*next)
     d   selOrder                     4    overlay(selArray:*next)
     d   selPrompt                   45    overlay(selArray:*next)
     d   selValue                    45    overlay(selArray:*next)

730qA *  Hold Parameters and values for Build Work Files when necessary
730qAd wrkfds          ds                  inz
730qAd  wrkfa                              dim(50)
730qAd   wrkfparmn                   10    overlay(wrkfa:*next)
730qAd   wrkfparmv                  300    overlay(wrkfa:*next)

     *----------------------------------------------------------------
     * Date Variables
     *----------------------------------------------------------------

     d Yesterday       s               d   DatFmt( *mdy )
     d dyYear          s              3  0
     d BeginTimeStamp  s           3000
     d EndTimeStamp    s           3000
     d DateBeginYear   s               d   DatFmt( *iso )
     d DateBeginWeek   s               d   DatFmt( *iso )
     d DateBeginMonth  s               d   DatFmt( *iso )
     d DateBeginQtr    s               d   DatFmt( *iso )
     d DateEndQtr      s               d   DatFmt( *iso )
     d BeginYYMMDD     s              6  0
     d EndYYMMDD       s              6  0
     d BeginCCYYMMDD   s              8  0
     d EndCCYYMMDD     s              8  0
     d DateString      s           3000
730oAd DateStringB     s           3000
730oAd DateHeadBE      s              1
     d wkDate          s           3000
     d workDays        s              3p 0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

      * Insert required HTML escape sequences
     d htmlEscapes     pr          3000
     d  dateStr                    3000

      * Reverse HTML Escape Sequences
     d reverseHTML     pr          3000
     d  dateStr                    3000

720cA * Replace -'s with /'s in TimeStamp (Begin and End)
720cAd TimeStampDate   pr          3000
720cAd  dateStr                    3000

      * get day of Week Sunday=0, Saturday=6
     D DayOfWeek       pr            10i 0
     D   dt                            d   value datfmt(*iso)

      * set landscape and ghost command
     D rptOrtp         pr

730dA * ensure proper case for MRC URL
730dAD FixCase         pr

      * ensure proper case for MRC URL
     D forceCase       pr
     D   searchStr                   10    value
730dAD   case                         1    const

      * determine if interactive or batch
     D IsIntJob        PR             1N
     D Msg             S             50A

      * execute iSeries commands within RPG
     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)

      * must use QCMDEXC to call Program Message
     D Execute         PR                  ExtPgm('QCMDEXC')
     D     CmdStr                   200    Options(*VarSize) const
     D     CmdLen                    15  5 Const

730qA * Determine if Report Work Build is necessary
730qAD WrkFileReq      pr              n
730qA * Save Work File Parms
730qAD SaveWrkFParms   pr
730qA * Build call string to create Work File for Report
730qAD BldWrkFCallStr  pr
730qA * Build direct call parms to build work file
760aAD extParms        pr

    *----------------------------------------------------------------
    * Prototypes
    *----------------------------------------------------------------

     D mrcRptSch       PR                  EXTPGM('MRCRPTSCH')
     D  iWhse                         3  0
     D  iRptNam                      20
     D  iUrl                       3000
     d  iEmail                     1000
     d  iPrinter                     10
     d  iOrient                       1

     D MrcRptSch       PI
     D  iWhse                         3  0
     D  iRptNam                      20
     D  iUrl                       3000
     d  iEmail                     1000
     d  iPrinter                     10
     d  iOrient                       1

     *  Ensure last chance output queue exists
     D mrcHoldQ        PR                  EXTPGM('MRCHOLDQ')

     *  Sets strings and calls Java process to execute MRC Report
     D mrcJavaCl       PR                  EXTPGM('MRCJAVACL')
     D  outFormat                     2
     D  reportName                  100
     d  url                        3000
     d  emailyn                       1
     d  emailTo                    1000
     d  ipaddr                       15
     d  ipport                        5
     d  emailSubJect                100a
     d  emailBody                  5000a
     d  filepath                    100a
     d  dbsrc                        30a

     *  Call CL to convert PDF to PCL file and print if defined to print
     D mrcPrntPDF      PR                  EXTPGM('MRCPRNTPDF')
     D  reportName                  100
     D  printQ                       10
     d  rptOrt                        1
     d  gCmd                        100
     d  psCmd                       100
SUNaAd  iDrawer                       7

     *  Call CL to check whether job already submitted
     D chkactmrcs      PR                  EXTPGM('CHKACTMRCS')
     D  iWhse                         3  0
     D  jobtest                      10
     d  iReturn                      10

     *  Call CL to send program message
     D sndmsgcl        PR                  EXTPGM('SNDMSGCL')
     D  sndmsgid                      7
     D  sndmsgfile                   20
     d  sndmsgdata                 1000

      *  used to pause/sleep process for specific period of seconds
     D sleep           pr            10u 0 extproc('sleep')
     D   Interval                    10u 0 value

     *----------------------------------------------------------------
     *  *MRCRPT  -  MRC Report Scheduling Options
     *
     * Fields
     *
     *    OPIP    -  IP address for Tomcat Server
     *    OPPORT  -  IP Port for Tomcat Server
     *    OPDPRT  -  Default Printer (Used when one not supplied)
     *    OPGSDV  -  Ghostscript Device
     *    OPMUSR  -  Mrc User.  Found on iSeries and in MRC Spring Context
     *    OPDBSRC -  MRC Datasource for Report Calling to Use
     *    OPINCLDD-  Include Date in IFS filename
     *    OPINCLDT-  Include time in IFS filename
     *    OPRTDIR -  Include report name in IFS directory Structure
     *
     *----------------------------------------------------------------
     *
     * Data structure
     *

     D opdata          ds
     D  opip                   1     15
     D  opport                16     20  0
     D  opdprt                21     30
730kMD  opgsdv                31     39
730kMD  opmusr                40     49
730kMd  opcpre                50     52
730kMd  opjobd                53     62
730kMd  opdbsrc               63     92
730kAd  opincldd              93     93
730kAd  opincldt              94     94
730kAd  oprptdir              95     95

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *     iRpt - Incoming Report Name.  "SCHEDULER" means to submit and
      *            process scheduled jobs.  Otherwise ondemand report
      *     iUrl - For ondemand only.  Parms with values.  &R001=50000&CALCULA001=1
      *            This url will be checked for any characters that require HTML escape codes
      *     iEmail-Email(s).  Only for ondemand.  If blank no email is sent
      *     iPrinter-Onedemand only.  Output sent to this printer only if PDF format
      *
      *    Returned Parameters
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

ADFaA
ADFaA* Get client id.
ADFaA
ADFaAC                   call      'GETCLIENT'
ADFaAC                   parm                    client           10
ADFaAC                   parm                    clientloc        10

      /free

        // if interactive then check everything to
        // submit.  If OK then submit
        if isIntJob and iRptNam='SCHEDULER';
          chain (iwhse:'*MRCRPT') options;
          if not %found(options) or opcpre=*blanks;
             sndmsgid='CPF9898';
             sndmsgfile='QCPFMSG';
             sndmsgdata =
                        'MRC Report Scheduler (' + %trim(jobtest) +
                        ') requires customer prefix *MRCRPT option';
             sndmsgcl(sndmsgid:sndmsgfile:sndmsgdata);
          else;
             jobtest = %trim(opcpre) + 'RPTSCH';
             cmdToRun = 'DLTOBJ OBJ(QTEMP/CHKACTMRCS) OBJTYPE(*USRSPC)';
             returnCode = goCmd(%trim(cmdToRun));
             chkactmrcs(iWhse:jobtest:pReturn);
             if pReturn = '*EXIST';
                sndmsgid='CPF9898';
                sndmsgfile='QCPFMSG';
                sndmsgdata =
                           'MRC Report Scheduler (' + %trim(jobtest) +
                           ') already running';
                sndmsgcl(sndmsgid:sndmsgfile:sndmsgdata);
             else;
                // Submit job to run using QSYSNOMAX to run in QSYSWRK
                if opjobd=*blanks;
                   opjobd='*USRPRF';
                endif;
                cmdToRun = 'SBMJOB CMD(CALL PGM(MRCRPTSCH) PARM(X' + sq +
                           %char(iWhse) + 'F' + sq + ' ' + sq + 'SCHEDULER' + sq
                           + ' ' + sq + ' ' + sq + ' ' + sq + ' ' + sq + ' ' +
                           sq + ' ' + sq + ' ' + sq + ' ' + sq + ')) ' +
                           'JOBD(' + %trim(opjobd)  + ') ' +
                           'JOB(' + %trim(jobtest)  + ') ' +
                           'JOBQ(QSYSNOMAX)';
                Execute(%trim(cmdToRun):%len(%trim(cmdToRun)));
                if returnCode <> Success;
                   sndmsgid='CPF9898';
                   sndmsgfile='QCPFMSG';
                   sndmsgdata =
                              'MRC Report Scheduler (' + %trim(jobtest) +
                              ') not submitted';
                   sndmsgcl(sndmsgid:sndmsgfile:sndmsgdata);
                else;
                   // send success message
                   sndmsgid='CPF9898';
                   sndmsgfile='QCPFMSG';
                   sndmsgdata =
                              'MRC Report Scheduler (' + %trim(jobtest) +
                              ') submitted succesfully';
                   sndmsgcl(sndmsgid:sndmsgfile:sndmsgdata);
                endif;
             endif;
          endif;
          *inlr = *on;
          return;
        else;
          // if *END sent as parm then write record to End Scheduler
          if iRptNam = '*END';
             sewhse=*zeros;
             serptpgm='*END';
             seschseq=*zeros;
             seday=0;
             seaddts=%timestamp();
             seprcts=%timestamp();
             sestat='U';
             write bfserec;
             *inlr=*on;
             return;
          endif;

          // Get Client name to use in Batchreports directory path
          in pirclient;
          // get MRC Reporting options record
          chain (iwhse:'*MRCRPT') options;
          scriptDir = '/batchscripts';
          if %trim(pirclient) <> '';
             dirBase = '/batchreports/' + %trim(pirClient);
          else;
             dirBase = '/batchreports';
          endif;

          // determine whether ondemand or scheduler call
          iRptNam = %xlate(lowercase:uppercase:iRptNam);
          select;
             when iRptNam <> 'SCHEDULER';     // On-Demand
                pWhse = iWhse;
                pRptPgm = %trim(iRptNam);
                oEmail = %trim(iEmail);
                // For on demand reports send email to system user
                // if none passed.
                PrinterQ=%trim(iPrinter);
                exsr processReport;
                *inlr = *on;
             other;
                // When SCHEDULER is passed we are wanting to process
                // report requests per the Scheduler.  This job will
                // call routine rptScheduler.  Before calling this routine
                // a time of 5 minutes ago will be set.  When it enters the
                // routine it will look for any scheduled entries from five
                // minutes ago till now and loop through each of those reports
                // and process to completion.  It will change the previous time
                // ran to current plus one minute.  Next time it wakes up it
                // will process everything from previous update time to now.
                dow 1=1;
                   exsr rptScheduler;
                   if closeScheduler;
                      exec sql delete from BFCMRCRSE
                           where serptpgm='*END';
                      leave;
                   endif;
                   sleep(30);
                   // get MRC Reporting options record in case of change between report runs
                   chain (iwhse:'*MRCRPT') options;
                enddo;
                *inlr = *on;
          endsl;
        endif;
      /end-free

     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  bldEmailBody  -  Loop through email and build body for email
     *        that represents the Data Selection and Report Level
     *        selection
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      /free
       begsr bldEmailBody;

         // loop through URL and build email body string to pass into
         // Java program that runs report and sends email

         clear selDS;
         selCount=0;
         pos=1;
         pgmSelection='---  Data Selection ---';
         levelSelection='--- Report Levels Selected ---';
         dow %scan('&':ourl:pos) > *zeros;
            parmName=*blanks;
            parmValue=*blanks;
            select;
               when %subst(ourl:%scan('&':ourl:pos)+1:2)='D_' or
                    %subst(ourl:%scan('&':ourl:pos)+1:2)='S_' or
                    %subst(ourl:%scan('&':ourl:pos)+1:2)='G_';
                    parmEnd = %scan('=':ourl:%scan('&':ourl:pos)+1);
                    if parmEnd = *zeros;
                       // if no additonal parm located end parmname ends
                       // at end of url
                       parmEnd = %len(%trim(ourl));
                       parmname = %subst(ourl:%scan('&':ourl:pos)+3:
                                      parmEnd - %scan('&':ourl:pos)-3);
                    else;
                       // if another parm found then parmname ends 1 short
                       // of next &
                       parmname = %subst(ourl:%scan('&':ourl:pos)+3:
                                  parmEnd - %scan('&':ourl:pos)-3);
                    endif;
                    // now get Parm Value passed in
                    if %scan('&':ourl:parmEnd) > *zeros;
                       parmValue = %subst(ourl:parmEnd+1:
                                   %scan('&':ourl:parmEnd) - (parmEnd+1));
                       pos = parmEnd;
                    else;
                       parmValue = %subst(ourl:parmEnd+1:
                                   %len(%trim(ourl)) - parmEnd);
                       pos = %len(%trim(ourl));
                    endif;
                // Report Parm  R999
               when %subst(ourl:%scan('&':ourl:pos)+1:1)='R';
                    parmEnd = %scan('=':ourl:%scan('&':ourl:pos)+1);
                    if parmEnd = *zeros;
                       // if no additonal parm located end parmname ends
                       // at end of url
                       parmEnd = %len(%trim(ourl));
                       parmname = %subst(ourl:%scan('&':ourl:pos)+1:
                                      parmEnd - %scan('&':ourl:pos)-1);
                    else;
                       // if another parm found then parmname ends 1 short
                       // of next &
                       parmname = %subst(ourl:%scan('&':ourl:pos)+1:
                                  parmEnd - %scan('&':ourl:pos)-1);
                    endif;
                    // now get Parm Value passed in
                    if %scan('&':ourl:parmEnd) > *zeros;
                       parmValue = %subst(ourl:parmEnd+1:
                                   %scan('&':ourl:parmEnd) - (parmEnd+1));
                       pos = parmEnd;
                    else;
                       parmValue = %subst(ourl:parmEnd+1:
                                   %len(%trim(ourl)) - parmEnd);
                       pos = %len(%trim(ourl));
                    endif;
               // Calcula999 parm
               when %subst(ourl:%scan('&':ourl:pos)+1:6)='CALCUL';
                    parmEnd = %scan('=':ourl:%scan('&':ourl:pos)+1);
                    if parmEnd = *zeros;
                       // if no additonal parm located end parmname ends
                       // at end of url
                       parmEnd = %len(%trim(ourl));
                       parmname = %subst(ourl:%scan('&':ourl:pos)+1:
                                      parmEnd - %scan('&':ourl:pos)-1);
                    else;
                       // if another parm found then parmname ends 1 short
                       // of next &
                       parmname = %subst(ourl:%scan('&':ourl:pos)+1:
                                  parmEnd - %scan('&':ourl:pos)-1);
                    endif;
                    // now get Parm Value passed in
                    if %scan('&':ourl:parmEnd) > *zeros;
                       parmValue = %subst(ourl:parmEnd+1:
                                   %scan('&':ourl:parmEnd) - (parmEnd+1));
                       pos = parmEnd;
                    else;
                       parmValue = %subst(ourl:parmEnd+1:
                                   %len(%trim(ourl)) - parmEnd);
                       pos = %len(%trim(ourl));
                    endif;
               other;
                 // progress through URL in case & used for unexpected parm
                 pos = %scan('&':ourl:pos) +1;
            endsl;
750a        // Set Expiration correctly for Expired Items parm
750aA       if prptpgm='BFCREPORTS.R06400';
750aA         if %trim(parmName)='R007' and %trim(parmValue)='0';
750aA            parmValue='O';
750aA         endif;
750aA         if %trim(parmName)='R008' and %trim(parmValue)='0';
750aA            parmName='R007';
750aA            parmValue='E';
750aA         endif;
750aA       endif;
            // Now get Selection Prompt to add to respective list
            if parmName <> *blanks and parmValue <> *blanks;
730sD          // setll (pwhse:prptpgm) bfcmrcrcfg;
730sD          // reade (pwhse:prptpgm) bfcmrcrcfg;
730sM          setll (prptpgm) bfcmrcrcfg;
730sM          reade (prptpgm) bfcmrcrcfg;
               if %eof(bfcmrcrcfg) or not %equal(bfcmrcrcfg);
                  // If no program definition is found then force
                  // everything to Data Selection section and
                  // force everything to order appearing in url
                  selCount = selcount + 1;
                  selTable(selCount) = 'S';
                  selOrder(selCount) = '1';
                  selPrompt(selCount) = %trim(parmname);
                  // Use Parm Name for Prompt since not defined
                  DateString=%trim(parmValue);
                  selValue(selCount) = %trim(reverseHTML(DateString));
               else;
                 dow not %eof(bfcmrcrcfg) and %equal(bfcmrcrcfg);
                    if %scan(%trim(parmname):bftpdata) > *zeros or
                       (%scan(%trim(parmname):bfdtarry) > *zeros and
                        %subst(parmname:1:6)='CALCUL');
                       wkatyp=*blanks;
                       selLevl = %subst(bftpdata:23:4);
                       monitor;
                         selq# = %dec(%subst(bftpdata:27:5):5:0);
                       on-error;
                         selq#=*zeros;
                       endmon;
                       exec sql select hiatyp into :wkatyp
                                from glorptq
                                  where hilevl=:selLevl and
                                        hiseq#=:selq#;
                       selCount = selCount + 1;
                       if bfmrctbl = 'S';
                          if wkatyp='2';
                             if %trim(parmValue) = '0' or
                                %trim(parmValue) = 'N';
                                // If checkbox (wkatyp='2') and value is
                                // off the ignore checkbox
                                selCount = selCount - 1;
                                leave;
                             else;
                                selValue(selCount) = *blanks;
                             endif;
                          else;
                             DateString = %trim(ParmValue);
                             selValue(selCount) = reverseHTML(DateString);
                          endif;
                          selTable(selCount) = 'S';
                          selOrder(selCount) = %trim(bfscrord);
                          selPrompt(selCount) = %trim(bfPrompt);
                          leave;
                       else;
                          selTable(selCount) = bfmrctbl;
                          selOrder(selCount) = %trim(bfscrord);
                          selPrompt(selCount) = %trim(bfPrompt);
                          selValue(selCount)=*blanks;
                          leave;
                       endif;
                    endif;
730sD               // reade (pwhse:prptpgm) bfcmrcrcfg;
730sM               reade (prptpgm) bfcmrcrcfg;
                 enddo;
               endif;
            endif;
         enddo;

         // Sort URL Selection elements so they appear in email body in same order as screen
      /end-free
     C                   sorta     %subarr(selOrder:1:selCount)
      /free

         // Create Program Selection and Report Level section from sorted array
         selCount=1;
770cA    stgBatid=*blanks;
         dow selPrompt(selCount) <> *blanks;
            if selTable(selCount) <> 'S';        // Report Level Entry
               LevelSelection = %trim(LevelSelection) + cr +
                              %trim(selPrompt(selCount));
            else;
               pgmSelection = %trim(pgmSelection) + cr +
                              %trim(selPrompt(selCount)) + '  '  +
                              %trim(selValue(selCount));
770cA          if %scan('BFCREPORTS.R426':emailSubject) >0;
770cA            if %trim(selPrompt(selCount)) = 'Batch Id';
770cA              stgBatId = %trim(selValue(selCount));
770cA            endif;
770cA          endif;
            endif;
            selCount = selCount + 1;
         enddo;

         emailBody = %trim(pgmSelection) + cr + cr + %trim(levelSelection);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  buildParms - Build parms required by Java integration to call
     *               MRC Report
     *----------------------------------------------------------------

      /free
         begsr buildparms;

730pA       // clear some work fields
730pA       fromDt=*blanks;
730pA       fromHr=*blanks;
730pA       fromMin=*blanks;
730pA       toDt=*blanks;
730pA       toHr=*blanks;
730pA       toMin=*blanks;
730qA       clear wrkFa;    // Clear Work File Parm Array
            // get current version of program
            exec sql select gmipgm,gmidesc into :currrptpgm,:pgmdesc
                       from glomenuitm
                      where gmiid = :pRptPgm
                      order by gmipgm desc
                       fetch first row only;

720a        pdfHeadTitle = %trim(pgmDesc);
720a        exec sql select whdesc into :whsDesc
720a                  from warehs where whcode=:pWhse;
720a        pdfHeadWhse = %char(pWhse) + ' - ' + %trim(whsDesc);
720a        $time_a = %char(%time():*USA);
720a        pdfDateTime = %trim(%char(%date():*mdy)) +
720a                      '  ' + $time_a;
720a        pdfFoot = %trim(currrptpgm);
720a        if %scan('.':pdfFoot) > 0;
720a           %subst(pdffoot:%scan('.':pdfFoot):1) = '_';
720a        endif;
           // Build Report Name to be stored on IFS
720eA      chain (sewhse:serptpgm:seschseq:'M':'BSSEQNAME')
720eA                bfcmrcrprm;
720eA      if %found(bfcmrcrprm);
720eA        emailSubject = %trim(bsvalue) + ' - ' + %trim(currrptpgm);
720eA      else;
             emailSubject = %trim(currrptpgm) + ' - ' + %trim(pgmdesc);
720eA      endif;
           pos = %scan('.':currrptpgm);
           if pos <>0;
              rptnam = %trim(%subst(currrptpgm:pos+1:%len(currrptpgm)-pos-1));
              select;
               when opincldd='Y' and opincldt='Y';
                 rptnam = %trim(rptnam) + %char(%timestamp());
               when opincldd='Y';
                 rptnam = %trim(rptnam) + %char(%date():*iso);
               when opincldt='Y';
                 rptnam = %trim(rptnam) + %char(%time():*eur);
              endsl;
           endif;

            // loop through the BFC Developer defined data to determine
            // proper values to populate and include in the report URL
            setll (pWhse:pRptPgm:wkschseq) bfcmrcrprm;
            reade (pWhse:pRptPgm:wkschseq) bfcmrcrprm;

            // soft code ip and ip port from option record *MRCRPT
            oURL = 'http://' + %trim(opip) + ':' + %char(opport) +
                   '/mrcjava/servlet/';
            oURL = %trim(oURL) + %trim(currrptpgm) + 's?run=1';
            dow not %eof(bfcmrcrprm) and %equal(bfcmrcrprm);
               select;
                  when bsmrctbl='S';    // Selection parms
                    exsr determineIfDate;
                    if not datePrm;
                       if %trim(bsmrcprm) = 'PRINTER';
                          printerq = %trim(bsValue);
                       else;
720bA                     exsr spcParmCode;
                          // non date and non printer parms
                          if %trim(bsvalue) <> *blanks or
750aA                        (bsrptpgm='BFCREPORTS.R06400' and
750aA                         %trim(bsmrcprm)='R007');
730qA                       // if Report Work Required build call string
730qA                       if WrkFileReq;
730qA                          SaveWrkFParms();
730qA                       endif;
730qA                       // move to endtimestamp to match parm
730qA                       endtimestamp = %trim(bsvalue);
730qA                       oURL = %trim(oURL) + '&' + %trim(bsmrcprm) +
730qA                           '=' + %trim(htmlEscapes(endtimestamp));
750aA                       // for report R06405 and greater look for
750aA                       // Zero Expiration parm
750aA                       if bsrptpgm='BFCREPORTS.R06400' and
750aA                          %trim(bsmrcprm)='R007';
750aA                          endtimestamp = %trim(r008hold);
750aA                          oURL = %trim(oURL) + '&' + 'R008' +
750aA                              '=' + %trim(htmlEscapes(endtimestamp));
750aA                       endif;
                          endif;
                       endif;
                    else;
                       // Generate date portion of URL
                       exsr generateDateParms;
                    endif;
                  when bsmrctbl='T';    // Include Levels
                    if %trim(bsvalue) = 'Y';
730jA                  if %trim(bsmrcprm) = 'S_PTEMPP_';
730jA                    bsmrcprm = 'S_PTEMP%23';
730jA                  endif;
730lA                  if %trim(bsmrcprm) = 'S_LBOEMPP_';
730lA                    bsmrcprm = 'S_LBOEMP%23';
730lA                  endif;
730rA                  if %trim(bsmrcprm) = 'S_SXLBLP_';
730rA                    bsmrcprm = 'S_SXLBL%23';
730rA                  endif;
730rA                  if %trim(bsmrcprm) = 'S_SXTRNP_';
730rA                    bsmrcprm = 'S_SXTRN%23';
730rA                  endif;
740 A                  if %trim(bsmrcprm) = 'S_CXLBLP_';
740 A                    bsmrcprm = 'S_CXLBL%23';
740 A                  endif;
740 A                  if %trim(bsmrcprm) = 'S_CXTRNP_';
740 A                    bsmrcprm = 'S_CXTRN%23';
740 A                  endif;
                       oURL = %trim(oURL) + '&' + %trim(bsmrcprm) + '=1';
                    endif;
                  when bsmrctbl='E';    // Email(s)
                    if %trim(bsvalue) <> *blanks;
                       oEMAILYN = 'Y';
                    else;
                       oEMAILYN = 'N';
                    endif;
                    oEMAIL = %trim(bsvalue);
                  when bsmrctbl='O';    // Report Output Format
                    bsmrcprm = %xlate(uppercase:lowercase:bsmrcprm);
                    oURL = %trim(oURL) + '&' + %trim(bsmrcprm) +
                           '=' + %trim(bsvalue);
                    outfmt = %trim(bsvalue);
                  when bsmrctbl='X';    // Scheduled Time
                  when bsmrctbl='D';    // Days Scheduled
730pA             when bsmrctbl='Y';    // End of definition
730pA                if bsrptpgm='BFCREPORTS.R32300';
730qA                   // When Report Work File is required the we will build
730qA                   // the call string below and process the work File before
730qA                   // running the report
730qA                   BldWrkFCallStr();
730pA                   endTimeStamp =
730pA                          fromDt + '(' + fromHr + ':' + fromMin + ')' +
730pA                          '   -- to --   ' +
730pA                          toDt + '(' + toHr + ':' + toMin + ')';
730pA                   oURL = %trim(oURL) + '&CALCULA010=' +
730pA                          %trim(htmlEscapes(endTimeStamp));
730pA                endif;
740eA                if bsrptpgm='BFCREPORTS.R31500';
740eA                   endTimeStamp =
740eA                          %subst(fromDt:5:2) + '/' +
                               %subst(fromDt:7:2) + '(' +
                               fromHr + ':' + FromMin + ')' + ' - ' +
740eA                          %subst(toDt:5:2) + '/' +
                               %subst(toDt:7:2) + '(' +
                               toHr + ':' + toMin + ')';
740eA                   oURL = %trim(oURL) + '&CALCULA010=' +
                               htmlEscapes(endTimeStamp);
740eA                   // Build date/Time ranges and headings from other parms
740eA                   endTimeStamp = '&CALCULA005=' +
740eA                   fromDt + fromHr + fromMin + '00';
740eA                   oURL = %trim(oURL) + htmlEscapes(endTimeStamp);
740eA                   endTimeStamp = '&CALCULA006=' +
740eA                   toDt + toHr + toMin + '59';
740eA                   oURL = %trim(oURL) + htmlEscapes(endTimeStamp);
740fA                endif;
730pA                if bsrptpgm='BFCREPORTS.R33200';
730qA                   // When Report Work File is required we will build
730qA                   // the call string below and process the work File before
730qA                   // running the report
730qA                   BldWrkFCallStr();
730qA                endif;
740fA                if bsrptpgm='BFCREPORTS.R35800';
740fA                   // When Report Work File is required we will build
740fA                   // the call string below and process the work File before
740fA                   // running the report
740fA                   BldWrkFCallStr();
740fA                endif;
760cA                if bsrptpgm='BFCREPORTS.R40200';
760cA                   // When Report Work File is required we will build
760cA                   // the call string below and process the work File before
760cA                   // running the report
760cA                   BldWrkFCallStr();
760cA                endif;
770aA                if bsrptpgm='BFCREPORTS.R42900';
770aA                   // When Report Work File is required we will build
770aA                   // the call string below and process the work File before
770aA                   // running the report
770aA                   BldWrkFCallStr();
770aA                endif;
740gA                if bsrptpgm='BFCREPORTS.R20300' or
740gA                   bsrptpgm='BFCREPORTS.R36700';
740gA                   // Build date/Time ranges
740gA                   endTimeStamp = '&R001=' +
740gA                   %subst(fromDt:1:4) + '-' + %subst(fromDt:5:2) + '-' +
740gA                   %subst(fromDt:7:2) + '-' + fromHr + '.' + fromMin +
740gA                   '.00.000000';
740gA                   oURL = %trim(oURL) + htmlEscapes(endTimeStamp);
PANaA                   // Build SQL where clause to generate special
PANaA                   // IFS file for Panos for R203xx
PANaA                   if sqlWhere <> *blanks;
PANaA                     sqlWhere = %trim(sqlWhere) + ' and ';
PANaA                   endif;
PANaA                   sqlWhere = %trim(sqlWhere) + ' SXGDTS>=' + sq + sq +
PANaA                   %subst(fromDt:1:4) + '-' + %subst(fromDt:5:2) + '-' +
PANaA                   %subst(fromDt:7:2) + '-' + fromHr + '.' + fromMin +
PANaA                   '.00.000000' + sq + sq;
740gA                   endTimeStamp = '&R002=' +
740gA                   %subst(toDt:1:4) + '-' + %subst(toDt:5:2) + '-' +
740gA                   %subst(toDt:7:2) + '-' + toHr + '.' + toMin +
740gA                   '.00.000000';
740gA                   oURL = %trim(oURL) + htmlEscapes(endTimeStamp);
PANaA                   if sqlWhere <> *blanks;
PANaA                     sqlWhere = %trim(sqlWhere) + ' and ';
PANaA                   endif;
PANaA                   sqlWhere = %trim(sqlWhere) + ' SXGDTS<=' + sq + sq +
PANaA                   %subst(toDt:1:4) + '-' + %subst(toDt:5:2) + '-' +
PANaA                   %subst(toDt:7:2) + '-' + toHr + '.' + toMin +
PANaA                   '.59.999999' + sq + sq;
740gA                   endTimeStamp = %subst(fromDt:5:2) + '/' +
740gA                          %subst(fromDt:7:2) +
740gA                          '(' + fromHr + ':' + fromMin + ')' +
740gA                          '   -- to --   ' +
740gA                          %subst(toDt:5:2) + '/' + %subst(toDt:7:2) +
740gA                          '(' + toHr + ':' + toMin + ')';
740gA                   oURL = %trim(oURL) + '&CALCULA001=' +
740gA                          %trim(htmlEscapes(endTimeStamp));
740gA                endif;
               endsl;
               reade (pWhse:pRptPgm:wkschseq) bfcmrcrprm;
            enddo;

            // if no printer was defined (printerq) and no
            // email was defined force to default printer
            if printerq = *blanks and oemail = *blanks;
               // if options record has default printer send there
               if opdprt <> *blanks;
                  printerq = opdprt;
               endif;
            endif;

            // Process Report Request
            rptOrtp();
            exsr processReport;

         endsr;
      /end-free

     *----------------------------------------------------------------
     *  determineIfDate  -  Determine if this selection is a date field
     *                      Since user specifies generic date like
     *                      YESTERDAY we store all the beginning and
     *                      Ending date parms in Developer Config file
     *                      and populate here
     *----------------------------------------------------------------

      /free
         begsr determineIfDate;
            dateprm=*off;
            pRptOrtp = 'P';  // Default Orientation to Portrait
730sD       // setll (bswhse:bsrptpgm:bsmrctbl) bfcmrcrcfg;
730sD       // reade (bswhse:bsrptpgm:bsmrctbl) bfcmrcrcfg;
730sM       setll (bsrptpgm:bsmrctbl) bfcmrcrcfg;
730sM       reade (bsrptpgm:bsmrctbl) bfcmrcrcfg;
            dow not %eof(bfcmrcrcfg) and %equal(bfcmrcrcfg);
               // Since Orientation flag is stored on every Config record
               // and record existed save for URL Build time
               pRptOrtp = bfOrient;
               if pRptOrtp = *blanks;
                  pRptOrtp = 'L';
               endif;
               if %scan(%trim(bsmrcprm):bfdtarry) > 0;
                  dateprm = *on;
                  leavesr;
               endif;
730sD          // reade (bswhse:bsrptpgm:bsmrctbl) bfcmrcrcfg;
730sM          reade (bsrptpgm:bsmrctbl) bfcmrcrcfg;
            enddo;
         endsr;
      /end-free

     *------------------------------------------------------------------
     *  generateDateParms -  A single date parm is written in the user
     *                       schedule data.  When this is read logic
     *                       transfers here to read all dates and populate
     *                       the report url with all the correct begin/
     *                       end/date string variables
     *----------------------------------------------------------------

      /free
         begsr generateDateParms;
            exsr populateDates;
730sD       // setll (bswhse:bsrptpgm:bsmrctbl) bfcmrcrcfg;
730sD       // reade (bswhse:bsrptpgm:bsmrctbl) bfcmrcrcfg;
730sM       setll (bsrptpgm:bsmrctbl) bfcmrcrcfg;
730sM       reade (bsrptpgm:bsmrctbl) bfcmrcrcfg;
            dow not %eof(bfcmrcrcfg) and %equal(bfcmrcrcfg);
               if %scan(%trim(bsmrcprm):bfdtarry) > 0;
                  // loop through field bfdtarry for
                  // all date values.  This has 20 bytes
                  // per date parm.  It includes parm name,
                  // date type and whether begin, end or string
                  datelength = 1;
730oA             dateheadbe = 'B';
                  dow datelength <161;
                     bsmrcprm = %xlate(lowercase:uppercase:
                                 %subst(bfdtarry:datelength:10));
                     select;
                        when %subst(bfdtarry:datelength+10:9) = 'TS';
                          if %subst(bfdtarry:datelength+19:1) = 'B';  // Begin Timestamp
740gA                        if bsRptPgm <> 'BFCREPORTS.R36700' and
740gA                           bsRptPgm <> 'BFCREPORTS.R20300';
                               oURL = %trim(oURL) + '&' + %trim(bsmrcprm) +
                                   '=' + %trim(BeginTimeStamp);
730qA                          if WrkFileReq;
730qA                             bsValue=BeginTimeStamp;
730qA                             SaveWrkFParms();
730qA                          endif;
730pA                        else;
740gA                           FromDt = %trim(%char(BeginCCYYMMDD));
740gA                           if WrkFileReq;
740gA                              bsValue=%trim(%char(BeginCCYYMMDD));
730qA                              SaveWrkFParms();
730qA                           endif;
740gA                        endif;
                          else;
740gA                        if bsRptPgm <> 'BFCREPORTS.R36700' and
740gA                           bsRptPgm <> 'BFCREPORTS.R20300';
730oA                          dateHeadBE = 'E';
                               oURL = %trim(oURL) + '&' + %trim(bsmrcprm) +
                                   '=' + %trim(EndTimeStamp);
730qA                          if WrkFileReq;
730qA                             bsValue=EndTimeStamp;
730qA                             SaveWrkFParms();
730qA                          endif;
740gA                        else;
740gA                           ToDt = %trim(%char(EndCCYYMMDD));
740gA                           if WrkFileReq;
740gA                              bsValue=%trim(%char(EndCCYYMMDD));
740gA                              SaveWrkFParms();
740gA                           endif;
740gA                        endif;
                          endif;
                        when %subst(bfdtarry:datelength+10:9) = 'CY6';
                          if %subst(bfdtarry:datelength+19:1) = 'B';  // Begin YYMMDD
                             oURL = %trim(oURL) + '&' + %trim(bsmrcprm) +
                                 '=' + %trim(%char(BeginYYMMDD));
730qA                        if WrkFileReq;
730qA                           bsValue=%trim(%char(BeginYYMMDD));
730qA                           SaveWrkFParms();
730qA                        endif;
                          else;
730oA                        dateHeadBE = 'E';
                             oURL = %trim(oURL) + '&' + %trim(bsmrcprm) +
                                 '=' + %trim(%char(EndYYMMDD));
730qA                        if WrkFileReq;
730qA                           bsValue=%trim(%char(EndYYMMDD));
730qA                           SaveWrkFParms();
730qA                        endif;
                          endif;
                        when %subst(bfdtarry:datelength+10:9) = 'CY8';
                          if %subst(bfdtarry:datelength+19:1) = 'B';  // Begin CCYYMMDD
730pA                        if bsRptPgm <> 'BFCREPORTS.R32300' and
740aA                           bsRptPgm <> 'BFCREPORTS.R31500';
                                oURL = %trim(oURL) + '&' + %trim(bsmrcprm) +
                                    '=' + %trim(%char(BeginCCYYMMDD));
730qA                           if WrkFileReq;
730qA                              bsValue=%trim(%char(BeginCCYYMMDD));
730qA                              SaveWrkFParms();
730qA                           endif;
730pA                        else;
730pA                           FromDt = %trim(%char(BeginCCYYMMDD));
730qA                           if WrkFileReq;
730qA                              bsValue=%trim(%char(BeginCCYYMMDD));
730qA                              SaveWrkFParms();
730qA                           endif;
730pA                        endif;
                          else;
                             dateHeadBE = 'E';
730pA                        if bsRptPgm <> 'BFCREPORTS.R32300' and
740aA                           bsRptPgm <> 'BFCREPORTS.R31500';
                                oURL = %trim(oURL) + '&' + %trim(bsmrcprm) +
                                    '=' + %trim(%char(EndCCYYMMDD));
730qA                           if WrkFileReq;
730qA                              bsValue=%trim(%char(EndCCYYMMDD));
730qA                              SaveWrkFParms();
730qA                           endif;
730pA                        else;
730pA                           ToDt = %trim(%char(EndCCYYMMDD));
730qA                           if WrkFileReq;
730qA                              bsValue=%trim(%char(EndCCYYMMDD));
730qA                              SaveWrkFParms();
730qA                           endif;
730pA                        endif;
                          endif;
                        when %subst(bfdtarry:datelength+10:9) = 'PDT';  // Date String for Heading
730pA                      if bsRptPgm <> 'BFCREPORTS.R32300' and
740aA                           bsRptPgm <> 'BFCREPORTS.R31500' and
740eA                           bsRptPgm <> 'BFCREPORTS.R20300' and
740gA                           bsRptPgm <> 'BFCREPORTS.R36700';
730qD       //                oURL = %trim(oURL) + '&' + %trim(bsmrcprm) +
730qD       //                    '=' + %trim(DateString);
730oA                         if dateHeadBE = 'E';
730oA                            oURL = %trim(oURL) + '&' + %trim(bsmrcprm) +
730oA                                '=' + %trim(DateString);
730oA                         else;
730oA                            oURL = %trim(oURL) + '&' + %trim(bsmrcprm) +
730oA                                '=' + %trim(DateStringB);
730oA                         endif;
730pA                      endif;
                     endsl;
                     datelength = datelength + 20;
                  enddo;
                  leavesr;
               endif;
730sD          // reade (bswhse:bsrptpgm:bsmrctbl) bfcmrcrcfg;
730sM          reade (bsrptpgm:bsmrctbl) bfcmrcrcfg;
            enddo;
         endsr;
      /end-free

     *------------------------------------------------------------------
     *  rptScheduler  -  Routine to loop and process scheduled reports
     *      from MRC.  Wakes up every five minutes processing anything
     *      from the last update till current when it awakes
     *----------------------------------------------------------------

      /free
         begsr rptScheduler;

            // Ensure all current day scheduled reports are written to
            // the Scheduled Entries file
            exsr writeSchE;
            exsr processRpts;

         endsr;
      /end-free

     *------------------------------------------------------------------
     *  PopulateDates -  Calculate and Populate date fields based on
     *                   generic date that the user saved for this
     *                   scheduled report
     *----------------------------------------------------------------

      /free
         begsr populateDates;
            // get yesterday date and julian day of yeasterday
            Yesterday = %date - %days(1);
            dyYear = %dec(%subst(%char(Yesterday:*jul0):3:3):3:0);
            select;
              when %trim(bsvalue) = '*DTODAY';        // Today
                 // get calendar ytd beginning and ending dates
                 BeginTimeStamp = %char(%Date():*ISO) + ' 00:00:00';

                 // do html escape codes for special characters
720cA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 EndTimeStamp = %char(%Date():*ISO) +
                                     ' 23:59:59';

                 // do html escape codes for special characters
720cA            EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 BeginYYMMDD = %dec(%char(%Date():*YMD0):6:0);
                 EndYYMMDD = %dec(%char(%Date():*YMD0):6:0);
                 BeginCCYYMMDD = %dec(%char(%Date():*ISO0):8:0);
                 EndCCYYMMDD = %dec(%char(%Date():*ISO0):8:0);
                 DateString =  %char(%Date():*mdy) +
                               ' thru ' +
                               %char(%Date():*mdy);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
              when %trim(bsvalue) = '*YESTERDAY'      // Yesterday
750cA              or %trim(bsvalue) = '*DYESTERDAY';     // Yesterday
                 // get calendar ytd beginning and ending dates
                 BeginTimeStamp = %char(Yesterday:*ISO) + ' 00:00:00';

                 // do html escape codes for special characters
720cA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 EndTimeStamp = %char(Yesterday:*ISO) +
                                     ' 23:59:59';

                 // do html escape codes for special characters
720cA            EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 BeginYYMMDD = %dec(%char(Yesterday:*YMD0):6:0);
                 EndYYMMDD = %dec(%char(Yesterday:*YMD0):6:0);
                 BeginCCYYMMDD = %dec(%char(Yesterday:*ISO0):8:0);
                 EndCCYYMMDD = %dec(%char(Yesterday:*ISO0):8:0);
                 DateString =  %char(Yesterday:*mdy) +
                               ' thru ' +
                               %char(Yesterday:*mdy);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
              when %trim(bsvalue) = '*RWTD';        // Week to Date - Sun-Sat
PANaA            rptWTD = *on;
                 // get Sunday date for current week
                 if DayofWeek(Yesterday) = 0;   // Sunday
                    DateBeginWeek = Yesterday;
                    BeginTimeStamp = %char(Yesterday
                                        :*ISO) +
                                        ' 00:00:00';
                    EndTimeStamp = %char(Yesterday:*ISO) +
                                        ' 23:59:59';
                 else;
                    DateBeginWeek = Yesterday -
                                        %days(DayofWeek(Yesterday));
                    BeginTimeStamp = %char(Yesterday -
                                        %days(DayofWeek(Yesterday)):*ISO) +
                                        ' 00:00:00';
                    EndTimeStamp = %char(Yesterday -
                                        %days(DayofWeek(Yesterday)):*ISO) +
                                        ' 23:59:59';
                 endif;

                 // do html escape codes for special characters
720cA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 // do html escape codes for special characters
720cA            EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 BeginYYMMDD = %dec(%char(DateBeginWeek:*YMD0):6:0);
                 EndYYMMDD = %dec(%char(Yesterday:*YMD0):6:0);
                 BeginCCYYMMDD = %dec(%char(DateBeginWeek:*ISO0):8:0);
                 EndCCYYMMDD = %dec(%char(Yesterday:*ISO0):8:0);
                 DateString =  %char(DateBeginWeek:*mdy) +
                               ' thru ' +
                               %char(Yesterday);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
              when %trim(bsvalue) = '*RPWTD';   // Week to Date - Sun-Sat - Prv Year
                 // get this date last year
PANaA            rptpWTD = *on;
                 Yesterday = Yesterday - %Years(1);
                 if DayofWeek(Yesterday) = 0;   // Sunday
                    DateBeginWeek = Yesterday;
                    BeginTimeStamp = %char(Yesterday
                                        :*ISO) +
                                        ' 00:00:00';
                    EndTimeStamp = %char(Yesterday:*ISO) +
                                        ' 23:59:59';
                 else;
                    DateBeginWeek = Yesterday -
                                        %days(DayofWeek(Yesterday));
                    BeginTimeStamp = %char(Yesterday -
                                        %days(DayofWeek(Yesterday)):*ISO) +
                                        ' 00:00:00';
                    EndTimeStamp = %char(Yesterday -
                                        %days(DayofWeek(Yesterday)):*ISO) +
                                        ' 23:59:59';
                 endif;

                 // do html escape codes for special characters
720cA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 // do html escape codes for special characters
720cA            EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 BeginYYMMDD = %dec(%char(DateBeginWeek:*YMD0):6:0);
                 EndYYMMDD = %dec(%char(Yesterday:*YMD0):6:0);
                 BeginCCYYMMDD = %dec(%char(DateBeginWeek:*ISO0):8:0);
                 EndCCYYMMDD = %dec(%char(Yesterday:*ISO0):8:0);
                 DateString =  %char(DateBeginWeek:*mdy) +
                               ' thru ' +
                               %char(Yesterday);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
              when %trim(bsvalue) = '*R7DAYS';      // Last 7 days
                 // get Sunday date for current week
                 DateBeginWeek = Yesterday - %Days(6);
                 BeginTimeStamp = %char(Yesterday -
                                        %Days(6):*ISO) +
                                        ' 00:00:00';
                 EndTimeStamp = %char(Yesterday:*ISO) +
                                        ' 23:59:59';

                 // do html escape codes for special characters
720cA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 // do html escape codes for special characters
720cA            EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 BeginYYMMDD = %dec(%char(DateBeginWeek:*YMD0):6:0);
                 EndYYMMDD = %dec(%char(Yesterday:*YMD0):6:0);
                 BeginCCYYMMDD = %dec(%char(DateBeginWeek:*ISO0):8:0);
                 EndCCYYMMDD = %dec(%char(Yesterday:*ISO0):8:0);
                 DateString =  %char(DateBeginWeek:*mdy) +
                               ' thru ' +
                               %char(Yesterday);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
              when %trim(bsvalue) = '*RMTD';        // Month to Date
                 // Beginning and Ending Month Dates fpr Yesterday
                 Workdays = %subdt(Yesterday:*days);
                 DateBeginMonth = Yesterday - %Days(WorkDays - 1);
                 BeginTimeStamp = %char(DateBeginMonth
                                     :*ISO) +
                                     ' 00:00:00';
                 EndTimeStamp = %char(DateBeginMonth + %Months(1)
                                   - %Days(1):*ISO) +
                                     ' 23:59:59';

                 // do html escape codes for special characters
720cA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 // do html escape codes for special characters
720cA            EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 BeginYYMMDD = %dec(%char(DateBeginMonth:*YMD0):6:0);
730aD            //EndYYMMDD = %dec(%char(Yesterday + %Months(1)
730aA            EndYYMMDD = %dec(%char(DateBeginMonth + %Months(1)
                                   - %Days(1):*YMD0):6:0);
                 BeginCCYYMMDD = %dec(%char(DateBeginMonth:*ISO0):8:0);
730aD            //EndCCYYMMDD = %dec(%char(Yesterday + %Months(1)
730aA            EndCCYYMMDD = %dec(%char(DateBeginMonth + %Months(1)
                                   - %Days(1):*ISO0):8:0);
                 DateString =  %char(DateBeginMonth:*mdy) +
                               ' thru ' +
730aD                          //%char(Yesterday + %months(1)
730aA                          %char(DateBeginMonth + %months(1)
730aD                              //- %Days(1));
730aA                              - %Days(1):*mdy);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
              when %trim(bsvalue) = '*RPMTD';        // Month to Date Previous
                 Yesterday = Yesterday - %Years(1);
                 // Beginning and Ending Month Dates fpr Yesterday
                 Workdays = %subdt(Yesterday:*days);
                 DateBeginMonth = Yesterday - %Days(WorkDays - 1);
                 BeginTimeStamp = %char(DateBeginMonth
                                     :*ISO) +
                                     ' 00:00:00';
                 EndTimeStamp = %char(DateBeginMonth + %Months(1)
                                   - %Days(1):*ISO) +
                                     ' 23:59:59';

                 // do html escape codes for special characters
720cA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 // do html escape codes for special characters
720cA            EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 BeginYYMMDD = %dec(%char(DateBeginMonth:*YMD0):6:0);
730aD            //EndYYMMDD = %dec(%char(Yesterday + %Months(1)
730aA            EndYYMMDD = %dec(%char(DateBeginMonth + %Months(1)
                                   - %Days(1):*YMD0):6:0);
                 BeginCCYYMMDD = %dec(%char(DateBeginMonth:*ISO0):8:0);
730aD            //EndCCYYMMDD = %dec(%char(Yesterday + %Months(1)
730aA            EndCCYYMMDD = %dec(%char(DateBeginMonth + %Months(1)
                                   - %Days(1):*ISO0):8:0);
                 DateString =  %char(DateBeginMonth:*mdy) +
                               ' thru ' +
730aD                          //%char(Yesterday + %months(1)
730aA                          %char(DateBeginMonth + %months(1)
730aD                              //- %Days(1));
730aA                              - %Days(1):*mdy);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
              when %trim(bsvalue) = '*RQTD';        // Quarter to Date
                 // Beginning and Ending Quarter Dates from Yesterday
                 select;
                   when %subdt(Yesterday:*months) >=1 and
                        %subdt(Yesterday:*months) <= 3;
                      DateBeginQtr = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-01' + '-01');
                      DateEndQtr   = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-03' + '-31');
                   when %subdt(Yesterday:*months) >=4 and
                        %subdt(Yesterday:*months) <= 6;
                      DateBeginQtr = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-04' + '-01');
                      DateEndQtr   = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-06' + '-30');
                   when %subdt(Yesterday:*months) >=7 and
                        %subdt(Yesterday:*months) <= 9;
                      DateBeginQtr = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-07' + '-01');
                      DateEndQtr   = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-09' + '-30');
                   when %subdt(Yesterday:*months) >=10 and
                        %subdt(Yesterday:*months) <= 12;
                      DateBeginQtr = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-10' + '-01');
                      DateEndQtr   = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-12' + '-31');
                 endsl;
                 BeginTimeStamp = %char(DateBeginQtr
                                     :*ISO) +
                                     ' 00:00:00';
                 EndTimeStamp = %char(DateEndQtr
                                     :*ISO) +
                                     ' 23:59:59';

                 // do html escape codes for special characters
720cA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 // do html escape codes for special characters
720cA            EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 BeginYYMMDD = %dec(%char(DateBeginQtr:*YMD0):6:0);
                 EndYYMMDD = %dec(%char(DateEndQtr
                                     :*YMD0):6:0);
                 BeginCCYYMMDD = %dec(%char(DateBeginQtr:*ISO0):8:0);
                 EndCCYYMMDD = %dec(%char(DateEndQtr
                                     :*YMD0):8:0);
                 DateString =  %char(DateBeginQtr:*mdy) +
                               ' thru ' +
                               %char(DateEndQtr:*mdy);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
              when %trim(bsvalue) = '*RPQTD';        // Quarter to Date Previous
                 Yesterday = Yesterday - %Years(1);
                 // Beginning and Ending Quarter Dates from Yesterday
                 select;
                   when %subdt(Yesterday:*months) >=1 and
                        %subdt(Yesterday:*months) <= 3;
                      DateBeginQtr = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-01' + '-01');
                      DateEndQtr   = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-03' + '-31');
                   when %subdt(Yesterday:*months) >=4 and
                        %subdt(Yesterday:*months) <= 6;
                      DateBeginQtr = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-04' + '-01');
                      DateEndQtr   = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-06' + '-30');
                   when %subdt(Yesterday:*months) >=7 and
                        %subdt(Yesterday:*months) <= 9;
                      DateBeginQtr = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-07' + '-01');
                      DateEndQtr   = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-09' + '-30');
                   when %subdt(Yesterday:*months) >=10 and
                        %subdt(Yesterday:*months) <= 12;
                      DateBeginQtr = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-10' + '-01');
                      DateEndQtr   = %date(%char(%subdt(Yesterday:*Years)) +
                                     '-12' + '-31');
                 endsl;
                 BeginTimeStamp = %char(DateBeginQtr
                                     :*ISO) +
                                     ' 00:00:00';
                 EndTimeStamp = %char(DateEndQtr
                                     :*ISO) +
                                     ' 23:59:59';

                 // do html escape codes for special characters
720cA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 // do html escape codes for special characters
720cA            EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 BeginYYMMDD = %dec(%char(DateBeginQtr:*YMD0):6:0);
                 EndYYMMDD = %dec(%char(DateEndQtr
                                     :*YMD0):6:0);
                 BeginCCYYMMDD = %dec(%char(DateBeginQtr:*ISO0):8:0);
                 EndCCYYMMDD = %dec(%char(DateEndQtr
                                     :*YMD0):8:0);
                 DateString =  %char(DateBeginQtr:*mdy) +
                               ' thru ' +
                               %char(DateEndQtr);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
              when %trim(bsvalue) = '*RYTD';        // Year to Date
                 // get calendar ytd beginning and ending dates
                 BeginTimeStamp = %char(Yesterday -
                                     %days(dyYear-1):*ISO) +
                                     ' 00:00:00';

                 // do html escape codes for special characters
720cA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 EndTimeStamp = %char(Yesterday:*ISO) +
                                     ' 23:59:59';

                 // do html escape codes for special characters
720cA            EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 DateBeginYear = Yesterday - %days(dyYear-1);
                 BeginYYMMDD = %dec(%char(DateBeginYear:*YMD0):6:0);
                 EndYYMMDD = %dec(%char(Yesterday:*YMD0):6:0);
                 BeginCCYYMMDD = %dec(%char(DateBeginYear:*ISO0):8:0);
                 EndCCYYMMDD = %dec(%char(Yesterday:*ISO0):8:0);
                 DateString =  %char(DateBeginYear:*mdy) +
                               ' thru ' +
                               %char(Yesterday);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
              when %trim(bsvalue) = '*RPYTD';        // Year to Date Previous
                 Yesterday = Yesterday - %Years(1);
                 // get calendar ytd beginning and ending dates
                 BeginTimeStamp = %char(Yesterday -
                                     %days(dyYear-1):*ISO) +
                                     ' 00:00:00';

                 // do html escape codes for special characters
720cA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 EndTimeStamp = %char(Yesterday:*ISO) +
                                     ' 23:59:59';

                 // do html escape codes for special characters
720cA            EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 DateBeginYear = Yesterday - %days(dyYear-1);
                 BeginYYMMDD = %dec(%char(DateBeginYear:*YMD0):6:0);
                 EndYYMMDD = %dec(%char(Yesterday:*YMD0):6:0);
                 BeginCCYYMMDD = %dec(%char(DateBeginYear:*ISO0):8:0);
                 EndCCYYMMDD = %dec(%char(Yesterday:*ISO0):8:0);
                 DateString =  %char(DateBeginYear:*mdy) +
                               ' thru ' +
                               %char(Yesterday);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);

720gA         when %trim(bsvalue) = '*TODATE';        // To Date (all data)
                 // Get all data
                 BeginTimeStamp = '2000-01-01 00:00:00';

                 // do html escape codes for special characters
                 BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

730wD            //EndTimeStamp = %char(Yesterday:*ISO) +
730wA            EndTimeStamp = %char(%date():*ISO) +
                                     ' 23:59:59';

                 // do html escape codes for special characters
                 EndTimeStamp = TimeStampDate(EndTimeStamp);
                 EndTimeStamp = htmlEscapes(EndTimeStamp);

                 DateBeginYear = Yesterday - %days(dyYear-1);
                 BeginYYMMDD = 000101;
730wD            //EndYYMMDD = %dec(%char(Yesterday:*YMD0):6:0);
730wA            EndYYMMDD = %dec(%char(%date():*YMD0):6:0);
                 BeginCCYYMMDD = 20000101;
730wD            //EndCCYYMMDD = %dec(%char(Yesterday:*ISO0):8:0);
730wA            EndCCYYMMDD = %dec(%char(%date():*ISO0):8:0);
                 DateString =  '01/01/00' +
                               ' thru ' +
730wD                          //%char(Yesterday);
730wA                          %char(%date());
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
720gA         when %subst(%trim(bsvalue):1:6) = '*TODAY';      // Today plus number
                 // trim number of days
                 monitor;
                   numDays = %dec(%subst(%trim(bsvalue):7:
                                    %len(%trim(bsValue))-6):4:0);
                 on-error;
                   numDays = 7;
                 endmon;
                 // Today plus seven days into future
                 BeginTimeStamp = %char(%date() + %days(numDays):*ISO);

                 // do html escape codes for special characters
                 BeginTimeStamp = TimeStampDate(BeginTimeStamp);
                 BeginTimeStamp = htmlEscapes(BeginTimeStamp);

                 DateBeginYear = Yesterday - %days(dyYear-1);
                 BeginYYMMDD = %dec(%char(%date() + %days(numDays):*YMD0):6:0);
                BeginCCYYMMDD = %dec(%char(%date() + %days(numDays):*ISO0):8:0);
                 DateString =  %char(%date() + %days(numDays):*mdy);
                 // do html escape codes for special characters
                 DateString = htmlEscapes(DateString);
720oA         when %subst(%trim(bsvalue):1:6) = '*MONTH';      // Month Ago date calcs
720oA            // trim number of months
720oA            monitor;
720oA              numMonths = %dec(%subst(%trim(bsvalue):7:
720oA                          %len(%trim(bsValue))-6):4:0);
720oA            on-error;
720oA              numMonths = 1;
720oA            endmon;
720oA            // Today minus number of months for past month date
720oA            BeginTimeStamp = %char(%date() - %months(numMonths):*ISO);
720oA            EndTimeStamp = %char(%date():*ISO);
720oA
720oA            // do html escape codes for special characters
720oA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
720oA            BeginTimeStamp = htmlEscapes(BeginTimeStamp);
720oA
720oA            // do html escape codes for special characters
720oA            EndTimeStamp = TimeStampDate(EndTimeStamp);
720oA            EndTimeStamp = htmlEscapes(EndTimeStamp);
720oA
720oA            DateBeginYear = Yesterday - %days(dyYear-1);
720oA         BeginYYMMDD = %dec(%char(%date() - %months(numMonths):*YMD0):6:0);
720oA       BeginCCYYMMDD = %dec(%char(%date() - %months(numMonths):*ISO0):8:0);
720oA         EndYYMMDD = %dec(%char(%date():*YMD0):6:0);
720oA         EndCCYYMMDD = %dec(%char(%date():*ISO0):8:0);
720oA            DateString =  %char(%date() - %months(numMonths):*mdy) +
720oA                          ' thru ' +
720oA                          %char(%date():*mdy);
720oA            // do html escape codes for special characters
720oA            DateString = htmlEscapes(DateString);
720oA            DateStringB =  %char(%date() - %months(numMonths):*mdy);
720lA         when %subst(%trim(bsvalue):1:6) = '*MINUS';      // Today minus number days
720lA            // trim number of days
720lA            monitor;
720lA              numDays = %dec(%subst(%trim(bsvalue):7:
720lA                               %len(%trim(bsValue))-6):4:0);
720lA            on-error;
720lA              numDays = 2;
720lA            endmon;
720lA            // Today minus "X" days into past
720lA            BeginTimeStamp = %char(%date() - %days(numDays):*ISO);
720pA            EndTimeStamp = %char(%date():*ISO);
720lA
720lA            // do html escape codes for special characters
720lA            BeginTimeStamp = TimeStampDate(BeginTimeStamp);
720lA            BeginTimeStamp = htmlEscapes(BeginTimeStamp);
720oA
720pA            // do html escape codes for special characters
720pA            EndTimeStamp = TimeStampDate(EndTimeStamp);
720pA            EndTimeStamp = htmlEscapes(EndTimeStamp);
720lA
720lA            DateBeginYear = Yesterday - %days(dyYear-1);
720lA            BeginYYMMDD = %dec(%char(%date() - %days(numDays):*YMD0):6:0);
720lA           BeginCCYYMMDD = %dec(%char(%date() - %days(numDays):*ISO0):8:0);
720pA           EndYYMMDD = %dec(%char(%date():*YMD0):6:0);
720pA           EndCCYYMMDD = %dec(%char(%date():*ISO0):8:0);
720lA            DateString =  %char(%date() - %days(numDays):*mdy) +
720pA                          ' thru ' +
720pA                          %char(%date():*mdy);
720lA            // do html escape codes for special characters
720lA            DateString = htmlEscapes(DateString);
            endsl;
         endsr;
      /end-free

     *----------------------------------------------------------------
     *  processReport   Process Report Request
     *----------------------------------------------------------------

      /free
       begsr processReport;

        oport = %char(opport);          // come from Options record
        currrptpgm=*blanks;
        pgmdesc=*blanks;
        if iRptNam <> 'SCHEDULER';      // OnDemand Request vs. Scheduled Request
           // get current version of program
           exec sql select gmipgm,gmidesc into :currrptpgm,:pgmdesc
                      from glomenuitm
                     where gmiid = :iRptNam
                     order by gmipgm desc
                      fetch first row only;
           // Build Report Name to be stored on IFS
           pos = %scan('.':currrptpgm);
           if pos <>0;
              rptnam = %trim(%subst(currrptpgm:pos+1:%len(currrptpgm)-pos-1));
              select;
               when opincldd='Y' and opincldt='Y';
                 rptnam = %trim(rptnam) + %char(%timestamp());
               when opincldd='Y';
                 rptnam = %trim(rptnam) + %char(%date():*iso);
               when opincldt='Y';
                 rptnam = %trim(rptnam) + %char(%time():*eur);
              endsl;
           else;
              //  if not found in glomenuitm then put passed report
              // into both report name and description fields
              select;
               when opincldd='Y' and opincldt='Y';
                 rptnam = %trim(irptnam) + %char(%timestamp());
               when opincldd='Y';
                 rptnam = %trim(irptnam) + %char(%date():*iso);
               when opincldt='Y';
                 rptnam = %trim(irptnam) + %char(%time():*eur);
              endsl;
              currrptpgm=iRptNam;
              pgmdesc = iRptNam;
           endif;
730cA      pdfHeadTitle = %trim(pgmDesc);
730cA      exec sql select whdesc into :whsDesc
730cA                from warehs where whcode=:pWhse;
730cA      pdfHeadWhse = %char(pWhse) + ' - ' + %trim(whsDesc);
730cA      $time_a = %char(%time():*USA);
730cA      pdfDateTime = %trim(%char(%date():*mdy)) +
730cA                   '  ' + $time_a;
730cA      pdfFoot = %trim(currrptpgm);
730cA      if %scan('.':pdfFoot) > 0;
730cA         %subst(pdffoot:%scan('.':pdfFoot):1) = '_';
730cA      endif;
730cD      //chain (sewhse:serptpgm:seschseq:'M':'BSSEQNAME')
730cD      //          bfcmrcrprm;
730cD      //if %found(bfcmrcrprm);
730cD      //  emailSubject = %trim(bsvalue) + ' - ' + %trim(currrptpgm);
730cD      //else;
             emailSubject = %trim(currrptpgm) + ' - ' + %trim(pgmdesc);
730cD      //endif;
           oURL = 'http://' + %trim(opip) + ':' + %char(opport) +
                  '/mrcjava/servlet/';
           oURL = %trim(oURL) + %trim(currrptpgm) + 's?run=1';
           ourl = %trim(ourl) + %trim(htmlEscapes(iUrl));
760aA      // call routine to capture parms if work file required
760aA      // for thewse direct called reports.  Report scheduler
760aA      // handles in buildParms routine for scheduled reports
760aA      extParms();
           if oemail <> *blanks;
              oemailyn='Y';
           else;
              oemailyn='N';
           endif;
           prptortp = %trim(iOrient);
           if prptortp=*blanks;        // if orientation not sent print landscape
              prptortp = 'L';
           endif;
           RptOrTp();
           // determine Output format per the passed URL for OnDemand Call
           // Make sure all Report Level and Output Format are parms are proper case
           // otherwise, MRC ignores
730dA      FixCase();
730dD      //forceCase('d_');
730dD      //forceCase('D_');
730dD      //forceCase('S_');
730dD      //forceCase('s_');
730dD      //forceCase('g_');
730dD      //forceCase('G_');
730dD      //forceCase('&o');
730dD      //forceCase('&O');
           if %scan('&outfmt=':ourl) <> *zeros;
              // now find either the end of the url or next character after hitting numbers
              if %scan('&outfmt=':ourl)+9 > %len(%trim(ourl));
                 // Outfmt must be 1 character long
                 outfmt = %subst(ourl:%scan('&outfmt=':ourl)+8:1);
              else;
                 // look for numeric characters after &outfmt= and use as outfmt
                 beginFmt = %scan('&outfmt=':ourl)+8;
                 endFmt = beginFmt;
                 dow endFmt < %len(%trim(ourl)) and %subst(ourl:endfmt:1)
                           >= '0' and %subst(ourl:endfmt:1) <'9';
                    endFmt = endFmt + 1;
                 enddo;
                 if endfmt > beginfmt;
                    outfmt = %subst(ourl:beginfmt:endfmt-beginfmt);
                 else;
                    outfmt = '11';   // default to pdf if value invalid
                 endif;
              endif;
           else;
              // since no format was sent we will default to PDF
              outfmt='11';
           endif;
        endif;

        // Ensure all R999 and CALCULA999 are upper case in URL
        // MRC Report ignores parms unles caps.  Report levels must also be caps
730fA   // This is now done within FixCase().
730fD   //pos = %scan('&r0':ourl);
730fD   //dow pos > 0;
730fD   //   ourl = %replace('&R0':ourl:pos);
730fD   //   pos = %scan('&r0':ourl);
730fD   //enddo;
730fD   //pos = %scan('&calcula':ourl);
730fD   //dow pos > 0;
730fD   //   ourl = %replace('&CALCULA':ourl:pos);
730fD   //   pos = %scan('&calcula':ourl);
730fD   //enddo;
        // Make sure all Report Level and Output Format are parms are proper case
        // otherwise, MRC ignores
730dA   FixCase();
730dD   //forceCase('d_');
730dD   //forceCase('D_');
730dD   //forceCase('S_');
730dD   //forceCase('s_');
730dD   //forceCase('g_');
730dD   //forceCase('G_');
730dD   //forceCase('&o');
730dD   //forceCase('&O');
730hA   // when Excel pass in rptPage for report BFCREPORTS.R025xx
730hA   // special html file exist for this report
730hA   if Outfmt = '13';
730hA      if %subst(%trim(rptnam):1:4) = 'R025';
730hA         oUrl = %trim(oUrl) + '&rptPage=' +
730hA                %subst(%trim(rptnam):1:6) + 'e.html';
730hA      endif;
750dA      monitor;
750dA      if %subst(%trim(rptnam):1:6) > 'R08916'
750dA         and %subst(%trim(rptnam):1:4) = 'R089';
750dA         Outfmt = '15';
750dA      endif;
750dA      on-error;
750dA      endmon;
730dA   endif;
720a    // when PDF pass Header and Footer
720a    if Outfmt = '11';
720a       endtimestamp=%trim(pdfHeadWhse);
720a       endtimestamp=htmlEscapes(endtimestamp);
720a       pdfHeadWhse = %trim(endTimeStamp);
720a       endtimestamp=%trim(pdfHeadTitle);
720a       endtimestamp=htmlEscapes(endtimestamp);
720a       pdfHeadTitle = %trim(endTimeStamp);
720a       endtimestamp=%trim(pdfDateTime);
720a       endtimestamp=htmlEscapes(endtimestamp);
720a       pdfDateTime = %trim(endTimeStamp);
720a       endtimestamp=%trim(pdfFoot);
720a       endtimestamp=htmlEscapes(endtimestamp);
720a       pdfFoot = %trim(endTimeStamp);
720a       oUrl = %trim(oUrl) + '&pdfHeadWhse=' + %trim(pdfHeadWhse) +
720a              '&pdfHeadTitle=' + %trim(pdfHeadTitle) +
720a              '&pdfHeadDateTime=' + %trim(pdfDateTime) +
720a              '&pdfFoot=' + %trim(pdfFoot);
720a    endif;
730kA   // if setting selected to include report name in directory the insert
730kA   // before Java call
730kA   rptDir = dirBase;
730kA   if oprptDir = 'Y';
730kA      pos = %scan('.':bfRptPgm);  // get base report id from BFCMRCRCFG
730kA      if pos <>0;
730kA         rptDir = %trim(dirBase) + '/' +
730kA                  %trim(%subst(bfRptPgm:pos+1:%len(bfRptPgm)-pos-1));
730kA      endif;
730kA   endif;
770b   // Fix URL for Slot Listing to run using type 15 vs. 13
770bA   monitor;
770bA   if %subst(%trim(rptnam):1:6) > 'R08916'
770bA      and %subst(%trim(rptnam):1:4) = 'R089';
770bA     pos = %scan('outfmt=13':oUrl);
770bA     oUrl = %replace('outfmt=15':oUrl:pos);
770bA   endif;
770bA   on-error;
770bA   endmon;
       // call Java process to run scheduled Report
        filepath = %trim(rptDir);
        exsr bldEmailBody;
770c    // Write different subject for Interface errors
770cA   if %scan('BFCREPORTS.R426':emailSubject) > 0;
770cA     emailSubject = 'Interface Errors';
770cA     exec sql select sbtype into :stgtype
770cA                from stgBatch
770cA          where sbwhse=:iWhse and sbbatid=:stgbatid;
770cA     if sqlstt='00000' and stgBatId<>*blanks;
770cA       emailSubject = %trim(emailSubject) + '-' + stgtype;
770cA     endif;
770cA   endif;
        mrcJavaCl(outfmt:
                rptnam:
                oURL:
                oemailYN:
                oemail:
                opip:
                oport:
                emailSubject:
                emailBody:
                filepath:
                opdbsrc);

PANaA      // if Panos and R203xx then generate CSV and store in
PANaA      // sepecific directory on IFS
PANaA      if client = Panos and %scan('R203':rptnam)>0 and weekday='SUN'
PANaA                        and (rptWTD or rptpWTD);
PANaA        // generate csv file for date range and store to specific
PANaA        // path on IFS
PANaA        ifsPath  = '/PANOS/SelectionExceptions/' + %trim(rptnam) + '.csv';
PANaA        cmdToRun = 'SQL2CSV SQLSTMT(' + sq
PANaA                 + 'select SXTRN# as trannum,'
PANaA                 + 'SXLBL# as lblnum,'
PANaA                 + 'LBDISP as SlotDisplay,'
PANbM                 + 'rmvsplc(SXITEM) as item,'
PANbM                 + 'rmvsplc(ITDESC) as ItemDescription,'
PANbM                 + 'rmvsplc(ITPDSC) as PackDescription,'
PANaA                 + 'LBUCOD as UOM,'
PANaA                 + 'ITUM1 as NormalUOM,'
PANaA                 + 'ITUM2 as UOM2,'
PANaA                 + 'ITUMQ2 as U2Qty,'
PANaA                 + 'char(SXGDTS) as GeneratedDateStamp,'
PANaA                 + '(SXGEMP ||' + sq + sq + '-' + sq + sq + '|| '
PANaA                 + 'trim(upper(USLNAM)) || ' + sq + sq + ', ' + sq + sq
PANaA                 + ' || trim(upper(USFNAM))) ' + 'as GeneratedEmployee,'
PANaA                 + 'SXGBY as GeneratedUser,'
PANaA                 + 'LBOQTY as Picked,'
PANaA                 + 'LBOQTYS as Shorted,'
PANaA                 + 'SXERID as ErrorId,'
PANbM                 + '(IFSLTMTH || ' + sq + sq +'=' + sq + sq + ' || + '
PANbA                 + ' rmvsplc(GUCDSC))'
PANaA                 + ' as SelMethod,'
PANbA                 + 'SXWHSE as Whse '
PANaA                 + 'from voexcp inner join label on SXLBL#=LBLBL# inner '
PANaA                 + 'join PIRITEM on sxitem=ititem inner join ITEMFLD on '
PANaA                 + 'sxwhse=ifwhse and sxitem=ifitem inner join GLOUCICD '
PANaA                 + 'on ifsltmth=guccde inner join PIRUSER on sxgemp'
PANaA                 + '=USEMP# inner join LABELDO on sxwhse=lbowhse and '
PANaA                 + 'sxlbl#=lbolbl# where ' + %trim(sqlWhere)
PANcA                 + ' and guctyp=' + sq + sq + 'UCI3' + sq + sq
PANaA                 + ' order by sxwhse,sxtrn#,sxitem,sxlbl#' + sq
PANaA                 + ') TOCSV(' + sq + %trim(ifsPath) + sq + ')'
PANaA                 + ' COLHDRS(*FLDNAM)';
PANaA        returnCode = goCmd(%trim(cmdToRun));
PANaA      endif;
        // If PDF format and printer provider send copy to printer
        if outfmt='11' and PrinterQ<>*blanks;
SUNaA      pDrawer = *blanks;
SUNaA      // if Sunrise and Truck Map use Drawer 2, otherwise make blank
SUNaA      if client = Sunrise and %scan('R302':rptnam)>0;
SUNaA        pDrawer = '2';
SUNaA      endif;
           mrcPrntPDF(rptnam:
                      PrinterQ:
                      prptOrtp:
                      gsCmd:
                      pStmf:
SUNaA                 pDrawer);
SBRaA
SBRaA      // Print total of 3 copies of Truck Map
SBRaA      if client = sBertram and %scan('R302':rptnam)>0;
SBRaA        // print first copy above and now two more for total of 3
SBRaA        icopies=2;
SBRaA        dow icopies > 0;
SBRaA          cmdToRun = 'PRTSTMF STMF(' + sq + %trim(pStmf) + sq +
SBRaA                     ') OUTQ(' + %trim(PrinterQ) + ')';
SBRaA          returnCode = goCmd(%trim(cmdToRun));
SBRaA          icopies = icopies - 1;
SBRaA        enddo;
SBRaA      endif;
SBRaA
ADFaA      // Print total of 4 copies of Truck Map
ADFaA      if client = AandDF and %scan('R302':rptnam)>0;
ADFaA        // print first copy above and now three more for total of 4
ADFaA        icopies=3;
ADFaA        dow icopies > 0;
ADFaA          cmdToRun = 'PRTSTMF STMF(' + sq + %trim(pStmf) + sq +
ADFaA                     ') OUTQ(' + %trim(PrinterQ) + ')';
ADFaA          returnCode = goCmd(%trim(cmdToRun));
ADFaA          icopies = icopies - 1;
ADFaA        enddo;
ADFaA      endif;
ADFaA
SFPaA      if client = seashore and %scan('R369':rptnam)>0;
SFPaA        PrinterQ = 'SFPSHIPOPS';
SFPaA        cmdToRun = 'PRTSTMF STMF(' + sq + %trim(pStmf) + sq +
SFPaA                   ') OUTQ(' + %trim(PrinterQ) + ')';
SFPaA        returnCode = goCmd(%trim(cmdToRun));
SFPaA      endif;
750bA
750bA   // At some point I need to take this code to A&D Foods as
750bA   // well as Bertrams and use RPTOVRDTL to eliminate the
750bA   // custom exceptions above.
750bA   if %scan('R302':rptnam)>0;
750bA     // now delete the one time records if they exist.
750bA     exec sql delete from rptovrdtl
750bA         where rdprf='R30200' and rdone='Y';
750bA         // When one time override do not print other definitions
750bA     if sqlstt='00000';
750bA       leavesr;
750bA     endif;
750bA     // if device coming from Reports file it was already sent via PS313
750bA     chain ('R30200') reports;
750bA     if %found(reports);
750bA       if rpscrn='1';
750bA         leavesr;
750bA       endif;
750bA      endif;
750bA     // If it was not a one time override loop through overrides and print
750bA     // to respective queues
750bA     nextQ = *blanks;
750bA     setll ('R30200') rptovrdtl;
750bA     dow forever = forever;
750bA       reade ('R30200') rptovrdtl;
750bA       if not %equal(rptovrdtl) or %eof(rptovrdtl);
750bA         leave;
750bA       endif;
750bA       if rdone<>'Y' and rdATP='Y';
750bA         select;
750bA           when rddev=PrinterQ or rdoQ=PrinterQ;
750bA             // Since first copy is printed with queue from PS313
750bA             // we will flip PrinterQ on first equal so we could
750bA             // have multiple entries and print multiple copies
750bA             // since the PRTSTMF command is not doing other parms
750bA             PrinterQ = 'QPRINT';
750bA             iter;
750bA           when rddev<>*blanks and %subst(rddev:1:1)<>'*'
750bA                     and %trim(rddev)<>%trim(PrinterQ);
750bA             nextQ = rddev;
750bA           when rdoQ<>*blanks and %subst(rdoQ:1:1)<>'*'
750bA                     and %trim(rdoQ)<>%trim(PrinterQ);
750bA             nextQ = rdoQ;
750bA           other;
750bA             iter;
750bA         endsl;
750bA       endif;
750bA       cmdToRun = 'PRTSTMF STMF(' + sq + %trim(pStmf) + sq +
750bA                  ') OUTQ(' + %trim(nextQ) + ')';
750bA       returnCode = goCmd(%trim(cmdToRun));
750bA     enddo;
750bA   endif;
        endif;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  processRpts - Process Unscheduled Entries
     *----------------------------------------------------------------

      /free
         begsr processRpts;

            // Set 3 character value for day
            select;
              when DayofWeek(%date()) = 0;
                weekday = 'SUN';
              when DayofWeek(%date()) = 1;
                weekday = 'MON';
              when DayofWeek(%date()) = 2;
                weekday = 'TUE';
              when DayofWeek(%date()) = 3;
                weekday = 'WED';
              when DayofWeek(%date()) = 4;
                weekday = 'THU';
              when DayofWeek(%date()) = 5;
                weekday = 'FRI';
              when DayofWeek(%date()) = 6;
                weekday = 'SAT';
            endsl;

            // setup current time
            $time_a = %char(%time():*USA);
720fD       // if %scan('PM':$time_a) > 0;
720fM       if %scan('PM':$time_a) > 0 and %subst($time_a:1:2)<>'12';
               currentTime = %subst($time_a:1:5);
               %subst(currentTime:1:2) =
                       %char(%dec(%subst(currentTime:1:2):2:0) + 12);
            else;
               currentTime = %subst($time_a:1:5);
            endif;
            if %scan('AM':$time_a) >0 and %subst($time_a:1:2)='12';
               %subst(currentTime:1:2) = '00';
            endif;
            // Loop through unprocessed Schedule Entries and process
            // any that have passed their time
720 A       sqlstmt = 'select *' +
720 A                 ' from BFCMRCRSE ' +
720 A                 'where sestat=' + sq + 'U' + sq +
720 A                 ' order by seday,seschtime';
720 A       exec sql PREPARE sp FROM :SqlStmt;
720 A       exec sql DECLARE schP SCROLL CURSOR FOR sp;
720 A       exec sql OPEN schP;
720 A
720 A       exec sql fetch first from schP into :serec;
            closeScheduler=*off;
            dow sqlStt = '00000';
               if serptpgm = '*END';
                  closeScheduler = *on;
                  leave;
               endif;
               if seday <= DayofWeek(%date());
                  if (seday = DayofWeek(%date()) and seschtime <= currentTime)
                     or (seday < DayofWeek(%date()));
                     pWhse = seWhse;
                     pRptPGm = seRptPgm;
                     wkschseq=seschseq;
                     wkday=seday;
                     wkschtime=seschtime;
PANaA                sqlWhere = *blanks;
PANaA                rptWTD = *off;
PANaA                rptpWTD = *off;
                     exsr buildParms;
                     currentTS = %timestamp();
760eA                ourlse=%subst(ourl:1:500);
                     exec sql update BFCMRCRSE set sestat='P',
                                               seprcts    = :currentTS,
730eA                                          seoutfmt   = :outfmt,
730eA                                          serptnam   = :rptnam,
760eD                                       //   seurl      = :ourl,
760eM                                          seurl      = :ourlse,
730eA                                          seemailto  = :oemail,
730eA                                          seemailsub = :emailsubject,
730eA                                          sedbsrc    = :opdbsrc
                        where sewhse=:sewhse and serptpgm=:serptpgm
                          and seschseq=:seschseq and seday=:seday
                          and seschtime=:seschtime
720gA                     and sestat='U';
                  endif;
               endif;
720 A          exec sql fetch next from schP into :serec;
            enddo;
720 A       exec sql CLOSE schP;

            // Purge processed Schedule Entries older
720gM       // than 365 days
720dD       //Yesterday = %date - %days(10);
720gD       //workTS = %timestamp() - %days(10);
720gM       workTS = %timestamp() - %days(365);
            exec sql delete from BFCMRCRSE
720dD            //where seprcts < :yesterday and sestat='P';
720gD            //where seprcts < :workTS and sestat='P';
720gM            where seaddts < :workTS and sestat='P';
        endsr;
      /end-free

720bA*----------------------------------------------------------------
720bA*  spcParmCode  -  Populate blank parms that need additional processing
720bA*----------------------------------------------------------------

      /free
         begsr spcParmCode;
           // Reports and Parms with special code override
           select;
              // This report requires a batch id to run.  The report
              // is scheduled with no id and the override below gets
              // the latest batch and runs report for that batch
              when bsrptpgm='BFCREPORTS.R17800' and bsmrcprm='R001'
                   and %trim(bsvalue)='';
                 exec sql select cxbatch into :bsvalue
                    from IT981IDX
                     order by cxaddts desc
                     fetch first row only;
                 if %trim(bsvalue)='';
                    bsValue = '99999999999';
                 endif;
740hA         when bsrptpgm='BFCREPORTS.R28800' and bsmrcprm='R009';
740hA           // Flip 1 and 0 for checkbox to blank for 1 and REXI for 0
740hA           if %trim(bsvalue)='1';
740hA              bsvalue=' ';
740hA           else;
740hA             bsvalue='REXI';
740hA           endif;
740jA         when bsrptpgm='BFCREPORTS.R04100' and bsmrcprm='R002';
740jA           // Flip 1 and 0 for checkbox to N for 1 and Y for 0
740jA           // Checkbox says "Include items without slot" which
740jA           // means the 1 means checked and that should include
740jA           // all items, unchecked includes only items with slot
740jA           if %trim(bsvalue)='1';
740jA              bsvalue='N';
740jA           else;
740jA             bsvalue='Y';
740jA           endif;
750aA         when bsrptpgm='BFCREPORTS.R06400' and bsmrcprm='R007';
750aA           // Flip values for R007 and R008 based on selection
750aA           // code for R007 from report Scheduler
750aA           select;
750aA             when %trim(bsvalue)='O';
750aA               bsvalue='0';
750aA               r008Hold=' ';
750aA             when %trim(bsvalue)='E';
750aA               bsvalue=' ';
750aA               r008Hold='0';
750aA             other;
750aA               bsvalue=' ';
750aA               r008Hold=' ';
750aA           endsl;
740hA         when bsrptpgm='BFCREPORTS.R28800' and bsmrcprm='R003';
740hA           // Flip 1 and 0 for checkbox to Y for 1 and blank for 0
740hA           if %trim(bsvalue)='1';
740hA              bsvalue='Y';
740hA           else;
740hA             bsvalue=*blanks;
740hA           endif;
720cA         when bsrptpgm='BFCREPORTS.R30700' and bsmrcprm='R001';
720cA           // Flip 1 and 0 for checkbox to Y for 1 and blank for N
720cA           if %trim(bsvalue)='1';
720cA              bsvalue='Y';
720cA           else;
720cA             bsvalue=*blanks;
720cA           endif;
730vA         when bsrptpgm='BFCREPORTS.R28100' and bsmrcprm='R007';
730vA           // Flip 1 and 0 for checkbox to Y for 1 and blank for N
730vA           if %trim(bsvalue)='1';
730vA              bsvalue='1';
730vA           else;
730vA             bsvalue=*blanks;
730vA           endif;
730vA         when bsrptpgm='BFCREPORTS.R28200' and bsmrcprm='R007';
730vA           // Flip 1 and 0 for checkbox to Y for 1 and blank for N
730vA           if %trim(bsvalue)='1';
730vA              bsvalue='1';
730vA           else;
730vA             bsvalue=*blanks;
730vA           endif;
730vA         when bsrptpgm='BFCREPORTS.R28300' and bsmrcprm='R007';
730vA           // Flip 1 and 0 for checkbox to Y for 1 and blank for N
730vA           if %trim(bsvalue)='1';
730vA              bsvalue='1';
730vA           else;
730vA             bsvalue=*blanks;
730vA           endif;
720gA         when bsrptpgm='BFCREPORTS.R08900' and bsmrcprm='R006';
720gA           // Flip 1 and 0 for checkbox to Y for 1 and N for 0
720gA           // Virtual Slots Only
720gA           if %trim(bsvalue)='1';
720gD              //bsvalue='Y';
720gM              bsvalue='V';
720gA           else;
720gD             //bsvalue='N';
720gM             bsvalue=*blank;
720gA           endif;
760cA         when bsrptpgm='BFCREPORTS.R40200' and bsmrcprm='CALCULA009';
760cA           // Flip 1 and 0 for checkbox to Y for 1 and N for 0
760cA           // Omit Zero Employee
760cA           if %trim(bsvalue)='1';
760cM              bsvalue='Y';
760cA           else;
760cM             bsvalue='N';
760cA           endif;
730iA         when bsrptpgm='BFCREPORTS.R23800' and bsmrcprm='R005';
730iA           // Flip 1 and 0 for checkbox to 0 for 1 and blank for 0
730iA           // Exclude Duplicate Scans
730iA           if %trim(bsvalue)='1';
730iM              bsvalue='0';
730iA           else;
730iM             bsvalue=*blank;
730iA           endif;
730iA         when bsrptpgm='BFCREPORTS.R23800' and bsmrcprm='R006';
730iA           // Flip 1 and 0 for checkbox to I for 1 and blank for 0
730iA           // Exclude Invalid Barcode Scans
730iA           if %trim(bsvalue)='2';
730iM              bsvalue='I';
730iA           else;
730iM             bsvalue=*blank;
730iA           endif;
730pA         // Save Time range values for Picking Label Selection Report
730pA         when (bsrptpgm='BFCREPORTS.R32300'
740aA               or bsrptpgm='BFCREPORTS.R31500')
730pA               and bsmrcprm='CALCULA014';
730pA           FromHr = %trim(bsvalue);
730pA           bsvalue=*blanks;
740eA         when bsrptpgm='BFCREPORTS.R20300'
740eA               and bsmrcprm='CALCULA002';
740eA           FromHr = %trim(bsvalue);
740eA           bsvalue=*blanks;
740gA         when bsrptpgm='BFCREPORTS.R36700'
740gA               and bsmrcprm='CALCULA003';
740gA           FromHr = %trim(bsvalue);
740gA           bsvalue=*blanks;
730pA         when (bsrptpgm='BFCREPORTS.R32300'
740aA               or bsrptpgm='BFCREPORTS.R31500')
730pA               and bsmrcprm='CALCULA015';
730pA           FromMin = %trim(bsvalue);
730pA           bsvalue=*blanks;
740eA         when bsrptpgm='BFCREPORTS.R20300'
740eA               and bsmrcprm='CALCULA003';
740eA           FromMin = %trim(bsvalue);
740eA           bsvalue=*blanks;
740gA         when bsrptpgm='BFCREPORTS.R36700'
740gA               and bsmrcprm='CALCULA004';
740gA           FromMin = %trim(bsvalue);
740gA           bsvalue=*blanks;
730pA         when (bsrptpgm='BFCREPORTS.R32300'
740aA               or bsrptpgm='BFCREPORTS.R31500')
730pA               and bsmrcprm='CALCULA016';
730pA           ToHr = %trim(bsvalue);
730pA           bsvalue=*blanks;
740eA         when bsrptpgm='BFCREPORTS.R20300'
740eA               and bsmrcprm='CALCULA004';
740eA           ToHr = %trim(bsvalue);
740eA           bsvalue=*blanks;
740gA         when bsrptpgm='BFCREPORTS.R36700'
740gA               and bsmrcprm='CALCULA005';
740gA           ToHr = %trim(bsvalue);
740gA           bsvalue=*blanks;
730pA         when (bsrptpgm='BFCREPORTS.R32300'
740aA               or bsrptpgm='BFCREPORTS.R31500')
730pA               and bsmrcprm='CALCULA017';
730pA           ToMin = %trim(bsvalue);
730pA           bsvalue=*blanks;
740eA         when bsrptpgm='BFCREPORTS.R20300'
740eA               and bsmrcprm='CALCULA005';
740eA           ToMin = %trim(bsvalue);
740eA           bsvalue=*blanks;
740gA         when bsrptpgm='BFCREPORTS.R36700'
740gA               and bsmrcprm='CALCULA006';
740gA           ToMin = %trim(bsvalue);
740gA           bsvalue=*blanks;
           endsl;
720bA    endsr;
      /end-free

     *----------------------------------------------------------------
     *  Write Scheduled Entries to be processed for the Day
     *----------------------------------------------------------------

      /free
         begsr writeSchE;

            // Set 3 character value for day
            select;
              when DayofWeek(%date()) = 0;
                weekday = 'SUN';
              when DayofWeek(%date()) = 1;
                weekday = 'MON';
              when DayofWeek(%date()) = 2;
                weekday = 'TUE';
              when DayofWeek(%date()) = 3;
                weekday = 'WED';
              when DayofWeek(%date()) = 4;
                weekday = 'THU';
              when DayofWeek(%date()) = 5;
                weekday = 'FRI';
              when DayofWeek(%date()) = 6;
                weekday = 'SAT';
            endsl;
            // Generate Schedule Entries.  This will write any scheduled
            // entries from BFCMRCRPRM with days equal to today
            // These entries are written as unprocessed and then inside
            // a loop down below each of these jobs will be ran as their
            // time comes and goes
720 A       sqlstmt = 'select bswhse,bsrptpgm,bsschseq,bsvalue,count(*)' +
720 A                 ' from BFCMRCRPRM ' +
720 A                 'where bsmrctbl=' + sq + 'D' + sq + ' and ' +
720 A                 ' bsmrcprm = ' + sq + %trim(WeekDay) + sq + ' and ' +
720 A                 ' bsvalue = ' + sq + 'Y' + sq +
720 A                 ' group by bswhse,bsrptpgm,bsschseq,bsvalue';
720 A       exec sql PREPARE se FROM :SqlStmt;
720 A       exec sql DECLARE schE SCROLL CURSOR FOR se;
720 A       exec sql OPEN schE;
720 A
720 A       exec sql fetch first from schE into :serecsql;
            dow sqlStt = '00000';
               // check each entry for today to see if it has
               // already been scheduled.  If so then ignore,
               // otherwise write new entry as unprocessed
720gA          clear bfserec;
               setll (s_bswhse:s_bsrptpgm:s_bsschseq) bfcmrcrse;
               reade (s_bswhse:s_bsrptpgm:s_bsschseq) bfcmrcrse;
               schEntryFound = *off;
               dow not %eof(bfcmrcrse) and %equal(bfcmrcrse);
                  chain (s_bswhse:s_bsrptpgm:s_bsschseq:'X':'SCHTIME')
                            bfcmrcrprm;
                  if %found(bfcmrcrprm);
                     if %date(seaddts) = %date() and
730gD                 //seday = DayofWeek(%date()) and seschtime = %trim(bsvalue);
730gM                 seday = DayofWeek(%date());
                      schEntryFound = *on;
                      leave;
                     endif;

                  endif;
                  reade (s_bswhse:s_bsrptpgm:s_bsschseq) bfcmrcrse;
               enddo;
730gD          //unlock bfcmrcrse;

720gA          // If report scheduled earlier today do not write new entry
720gA          curTimPlus2USA = %time() + %minutes(2);
720gA          curTimPlus2 = %subst(%char(curTimPlus2USA):1:5);
720gA          %subst(curTimPlus2:3:1) = ':';
720gA          if curTimPlus2 <= '00:02';
720gA            curTimPlus2 = '23:59';
720gA          endif;
720gA          %subst(curTimPlus2:3:1) = ':';
720gA          if curTimPlus2 >= seschtime and seschtime >'00:00'
720gA                        and schEntryFound = *on;
730gA              unlock bfcmrcrse;
720gA          else;

               // Release or add new Schedule entry based on loop above
730bA            if schEntryFound;
730gA              if sestat = 'U' and seschtime <> %trim(bsvalue);
730gA                seschtime = %trim(bsvalue);
730gA                update bfserec;
730gA              else;
730gA                unlock bfcmrcrse;
730gA              endif;
730bA            else;
                  clear bfserec;
                  sewhse=s_bswhse;
                  serptpgm=s_bsrptpgm;
                  seschseq=s_bsschseq;
                  seday=DayofWeek(%date());
                  // get correct scheduled time for this scheduled entry
                  chain (s_bswhse:s_bsrptpgm:s_bsschseq:'X':'SCHTIME')
                            bfcmrcrprm;
                  if %found(bfcmrcrprm);
                     seschtime=%trim(bsvalue);   // gets schedule time from chain above
                     seaddts=%timestamp();
                     sestat='U';
                    // only create schedule entry if currently marked as Active
                     chain (s_bswhse:s_bsrptpgm:s_bsschseq:'M':'STATUS')
                               bfcmrcrprm;
                     if %found(bfcmrcrprm) and %trim(bsvalue)='A';

720gA                // Delete matching schedule entries
720gA                exec sql delete from BFCMRCRSE
720gA                         where sewhse   = :bswhse
720gA                           and serptpgm = :bsrptpgm
720gA                           and seschseq = :bsschseq
720gA                           and sestat   = 'U';

760 A                   if seRptPgm <> 'BFCREPORTS.R40700'
760dA                      and seRptPgm <> 'BFCREPORTS.R42600';
                          write bfserec;
760 A                   endif;
                     endif;
                  else;
                     // if no schedule time found do not submit
                  endif;
730bA          endif;
               endif;
720 A          exec sql fetch next from schE into :serecsql;
            enddo;
720 A       exec sql CLOSE schE;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  htmlEscapes    Apply HTML escape characters to url strings
     *----------------------------------------------------------------

     p htmlEscapes     b
     d htmlEscapes     pi          3000
     d  dateStr                    3000

     *  Local variables
     d  wkDate         s           3000
     d  wkDatelen      s             15  0
     d  datestrlen     s             15  0

      /free

                 wkDate = dateStr;

                 // Escape ' ' to forward slash
                 pos=1;
                 dow %scan('-':%trim(dateStr))>*zeros;
                    pos = %scan('-':%trim(dateStr));
                    WkDate = %subst(dateStr:1:pos-1) +
720aM                        '%2D' +
                             %subst(dateStr:pos+1:
                             %len(%trim(dateStr))+2);
                    dateStr = %trim(wkdate);
                 enddo;

                 // Escape forward slash
                 pos=1;
                 dow %scan('/':%trim(dateStr))>*zeros;
                    datestrlen = %len(%trim(datestr));
                    wkdatelen = %len(%trim(wkdate));
                    pos = %scan('/':%trim(dateStr));
                    WkDate = %subst(dateStr:1:pos-1) +
                             '%2F' +
                             %subst(dateStr:pos+1:
                             %len(%trim(dateStr))+2);
                    dateStr = %trim(wkdate);
                 enddo;

                 // Escape spaces
                 pos=1;
                 dow %scan(' ':%trim(dateStr))>*zeros;
                    pos = %scan(' ':%trim(dateStr));
                    WkDate = %subst(dateStr:1:pos-1) +
                             '%20' +
                             %subst(dateStr:pos+1:
                             %len(%trim(dateStr))+2);
                    dateStr = %trim(wkdate);
                 enddo;

                 // Escape colons
                 pos=1;
                 dow %scan(':':%trim(dateStr))>*zeros;
                    pos = %scan(':':%trim(dateStr));
                    WkDate = %subst(dateStr:1:pos-1) +
                             '%3A' +
                             %subst(dateStr:pos+1:
                             %len(%trim(dateStr))+2);
                    dateStr = %trim(wkdate);
                 enddo;

730tA            // Escape greater than signs >
730tA            pos=1;
730tA            dow %scan('>':%trim(dateStr))>*zeros;
730tA               pos = %scan('>':%trim(dateStr));
730tA               WkDate = %subst(dateStr:1:pos-1) +
730tA                        '%3E' +
730tA                        %subst(dateStr:pos+1:
730tA                        %len(%trim(dateStr))+2);
730tA               dateStr = %trim(wkdate);
730tA            enddo;

740bA            // Escape greater than signs <
740bA            pos=1;
740bA            dow %scan('<':%trim(dateStr))>*zeros;
740bA               pos = %scan('<':%trim(dateStr));
740bA               WkDate = %subst(dateStr:1:pos-1) +
740bA                        '%3C' +
740bA                        %subst(dateStr:pos+1:
740bA                        %len(%trim(dateStr))+2);
740bA               dateStr = %trim(wkdate);
740bA            enddo;

760cA            // Escape percent sign %
760cA            pos=1;
760cA            dow %scan('% ':dateStr)>*zeros;
760cA               pos = %scan('% ':dateStr);
760cA               WkDate = %subst(dateStr:1:pos-1) +
760cA                        '%25' +
760cA                        %subst(dateStr:pos+1:
760cA                        %len(%trim(dateStr))+2);
760cA               dateStr = %trim(wkdate);
760cA            enddo;

         return %trim(wkDate);

      /end-free

     p htmlEscapes     e

     *----------------------------------------------------------------
     *  reverseHtml    Reverse HTML escape sequences for Date Range Parm
     *----------------------------------------------------------------

     p reverseHTML     b
     d reverseHTML     pi          3000
     d  dateStr                    3000

     *  Local variables
     d  wkDate         s           3000
     d  rpos           s              5  0

      /free

                 wkDate = dateStr;

                 // Escape '%2D' to forward '-'
                 rpos=1;
                 dow %scan('%2D':%trim(dateStr))>*zeros;
                    rpos = %scan('%2D':%trim(dateStr));
                    WkDate = %subst(dateStr:1:rpos-1) +
                             '-' +
                             %subst(dateStr:rpos+3:
                             %len(%trim(dateStr))+4);
                    dateStr = %trim(wkdate);
                 enddo;

                 // Escape '%2F' to forward slash
                 rpos=1;
                 dow %scan('%2F':%trim(dateStr))>*zeros;
                    rpos = %scan('%2F':%trim(dateStr));
                    WkDate = %subst(dateStr:1:rpos-1) +
                             '/' +
                             %subst(dateStr:rpos+3:
                             %len(%trim(dateStr))+4);
                    dateStr = %trim(wkdate);
                 enddo;

                 // Escape spaces
                 rpos=1;
                 dow %scan('%20':%trim(dateStr))>*zeros;
                    rpos = %scan('%20':%trim(dateStr));
                    WkDate = %subst(dateStr:1:rpos-1) +
                             ' ' +
                             %subst(dateStr:rpos+3:
                             %len(%trim(dateStr))+4);
                    dateStr = %trim(wkdate);
                 enddo;

                 // Escape colons
                 rpos=1;
                 dow %scan('%3A':%trim(dateStr))>*zeros;
                    rpos = %scan('%3A':%trim(dateStr));
                    WkDate = %subst(dateStr:1:rpos-1) +
                             ':' +
                             %subst(dateStr:rpos+3:
                             %len(%trim(dateStr))+4);
                    dateStr = %trim(wkdate);
                 enddo;

         return %trim(wkDate);

      /end-free

     p reverseHTML     e

     *----------------------------------------------------------------*
     * Procedure:  DayOfWeek
     * Purpose:  Determine the day of week for a particular date
     * Parameters:
     *    I: dt   -- date
     * Returns:
     *    0..6    -- 0=Sunday, 1=Monday, 2=Tuesday, etc.
     * Notes:
     *    January 5, 1800 is a Sunday.  This procedure only works for
     *    dates later than 1800-01-05.
     *----------------------------------------------------------------*

     P DayOfWeek       b
     D DayOfWeek       pi            10i 0
     D   dt                            d   value datfmt(*iso)
      /free
        return %rem (%diff (dt: d'1800-01-05': *days): 7);
      /end-free
     P DayOfWeek       e

     *----------------------------------------------------------------*
     * Procedure:  rptOrtp
     * Purpose:  Determine proper orientation for MRC Report
     * Parameters:
     *    None
     * Returns:
     *    1 Char  -- 0=Portrait, 2=Landscape
     * Notes:
     *    Locates flag in Report XML file in MRC object directory
     *----------------------------------------------------------------*

     P rptOrtp         b
     D rptOrtp         pi
      /free
        // Make sure file path includes base and report directory if desired
730mA   if %scan(%trim(dirBase):rptDir) = 0;
730mA      rptDir = dirBase;
           if oprptDir = 'Y';
              pos = %scan('.':bfRptPgm);  // get base report id from BFCMRCRCFG
              if pos <>0;
                 rptDir = %trim(dirBase) + '/' +
                       %trim(%subst(bfRptPgm:pos+1:%len(bfRptPgm)-pos-1));
              endif;
           endif;
730mA   endif;
        // Build Ghostscript parm
        // if printer passed is found in Printer definition
        // file we should use the ghostscript command in that record
        exec sql select gsdev into :opgsdv
                  from bfcmrcrgsc
                  where gswhse=:pWhse and gsPrinter=:PrinterQ;
        // if ghostscript device is not found in printer file
        // then use default in system setup parms
        if opgsdv = *blanks;
           opgsdv = 'ljet4';
        endif;

        if pRptOrTp = 'L';
           // Landscape calls special Ghostscript
           gsCmd = 'cd ' + %trim(scriptDir) + '; pdf2psl.sh ' +
                   %trim(rptDir) + '/PDF/' + %trim(rptNam) + ' ' +
                   %trim(opgsdv);
        else;
           // else call normal pdf2ps.sh
           gsCmd = 'cd ' + %trim(scriptDir) + '; pdf2ps.sh ' +
                   %trim(rptDir) + '/PDF/' + %trim(rptNam) + ' ' +
                   %trim(opgsdv);
        endif;

        // Build Print Stream file cmd
        pStmf = %trim(rptDir) + '/PDF/' +
                %trim(rptNam) + '.pcl';

      /end-free
     P rptOrtp         e

730dA*----------------------------------------------------------------
730dA*  Fix case for some MRC parameters
730dA*----------------------------------------------------------------
730dA
730dAp FixCase         b
     d FixCase         pi

      /free

       // Create upercase version of url

       upURL = %xlate(lowercase: uppercase: ourl);

       // Make sure MRC parms are correct case
       // We pass in uppercase for matching against above string

       forceCase('D_': 'U');
       forceCase('S_': 'U');
       forceCase('G_': 'U');
       forceCase('&OUTFMT': 'L');
730fA  forceCase('&R0': 'U');
730fA  forceCase('&CALCULA': 'U');

      /end-free
     P                 e

     *----------------------------------------------------------------
     *  Force case for certain parms
     *----------------------------------------------------------------

     p forceCase       b
     d forceCase       pi
     D   searchStr                   10    value
730dAD   case                         1    const

      /free

730dA  // Search for the sent in string against the uppercase version of the URL.
730aD  // Yes, we are assuming the incoming string will be in uppercase.

730dD  //pos = %scan(%trim(searchStr):ourl);
730dM  pos = %scan(%trim(searchStr): upURL);

       dow pos > 0;

         endFmt = %scan('=':ourl:pos);

         if endFmt = 0;
            endfmt = %len(%trim(ourl)) - pos;
         else;
            endfmt = endFmt - pos;
         endif;

         if pos>0 and endfmt>0;   // endfmt should be length of level string

730dD       //if %trim(searchStr) <> '&o' and %trim(searchStr) <> '&O';
730dM       if case = 'U';
               %subst(ourl:pos:endfmt) =
                 %xlate(lowercase: uppercase: %subst(ourl: pos: endfmt));
            else;
               %subst(ourl:pos:endfmt) =
                 %xlate(uppercase: lowercase: %subst(ourl: pos: endfmt));
            endif;

            if (pos+1) < %len(%trim(ourl));
730dD          //pos = %scan(%trim(searchStr):ourl:pos+1);
730dM          pos = %scan(%trim(searchStr): upURL: pos+1);
            else;
               pos=0;
            endif;

         else;

            pos=0;

         endif;

       enddo;

      /end-free
     P forceCase       e

     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *   IsIntJob   --   Is this an interactive job?
     *        returns *ON if job is interactive
     *            or  *OFF if job is not interactive.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

     P IsIntJob        B                   export
     D IsIntJob        PI             1N

     D QUSRJOBI        PR                  EXTPGM('QUSRJOBI')
     D   RcvVar                   32766A   options(*varsize)
     D   RcvVarLen                   10I 0 const
     D   Format                       8A   const
     D   QualJob                     26A   const
     D   InternJob                   16A   const
     D   ErrorCode                32766A   options(*nopass:*varsize)

     D dsJob           DS
     D  dsJobBytesRtn                10I 0
     D  dsJobBytesAvl                10I 0
     D  dsJobName                    10A
     D  dsJobUser                    10A
     D  dsJobNumber                   6A
     D  dsJobIntern                  16A
     D  dsJobStatus                  10A
     D  dsJobType                     1A
     D  dsJobSubtype                  1A
     D  dsJobReserv1                  2A
     D  dsJobRunPty                  10I 0
     D  dsJobTimeSlc                 10I 0
     D  dsJobDftWait                 10I 0
     D  dsJobPurge                   10A

     c                   callp     QUSRJOBI(dsJob: %size(dsJob):'JOBI0100':
     c                                   '*': *blanks)
     c                   if        dsJobType = 'I'
     c                   return    *ON
     c                   else
     c                   return    *OFF
     c                   endif
     P                 E

720cA*------------------------------------------------------------------
720cA*  TimeStampDate  - Special format for timestamp date format
720cA*                   Use / instead of - from iso
720cA*----------------------------------------------------------------

     p TimeStampDate   b
     d TimeStampDate   pi          3000
     d  dateStr                    3000

      /free
730rA   // skip this code for certain reports.  We have different
740hA   // ways that timestamp values are compared in MRC reports.
740hA   // Any in this exception such as R28800 compares on pure
740hA   // timestamp
730rA   if bsRptPgm<>'BFCREPORTS.R20300' and
740gA      bsRptPgm<>'BFCREPORTS.R36700' and
740hA      bsRptPgm<>'BFCREPORTS.R28800';
          // Ensure all -'s in ISO date are converted to /'
          pos = %scan('-':dateStr);
          dow pos > 0;
             dateStr = %replace('/':dateStr:pos);
             pos = %scan('-':dateStr);
          enddo;
730rA   else;
730rA     // when certain reports format timestamp different
730rA     pos = %scan(' ':%trim(dateStr));
730rA     // place dash in place of space between
730rA     // date and time
740cA     if pos > 0;
730rA       dateStr = %replace('-':dateStr:pos);
740cA     endif;
730rA     // replace semicolon with period
730rA     pos = %scan(':':dateStr);
730rA     dow pos > 0;
730rA        dateStr = %replace('.':dateStr:pos);
730rA        pos = %scan(':':dateStr);
730rA     enddo;
730rA     // add micro seconds
730rA     if %scan('23.59':dateStr)>0;
740hA        if bsRptPgm='BFCREPORTS.R28800';
740hM          dateStr = %trim(dateStr) + '.999999';
740hA        else;
740dM          dateStr = %trim(dateStr) + '-99.99.99.999999';
740hA        endif;
730rA     else;
740hA        if bsRptPgm='BFCREPORTS.R28800';
740hM          dateStr = %trim(dateStr) + '.000000';
740hA        else;
740dM          dateStr = %trim(dateStr) + '-00.00.00.000000';
740hA        endif;
730rA     endif;
730rA   endif;
        return %trim(dateStr);
      /end-free

730qAP                 E
730qA*------------------------------------------------------------------
730qA*  WrkFileReq   - Return whether Work File creation is necessary
730qA*------------------------------------------------------------------
730qA
730qAp WrkFileReq      b
730qAd WrkFileReq      pi              n
730qA
730qA /free
730qA   // This sub procedure offers a clean way up in the code
730qA   // to ask whether this report requires the building of
730qA   // a work file.  If returned true it saves parms and
730qA   // ultimately calls that Work File Build process with
730qA   // Timestamp instead of Session Id in BldWrkFCallStr
730qA   select;
730qA     when bsrptpgm='BFCREPORTS.R33200'
760qA       or bsrptpgm='BFCREPORTS.R32300'
740fA       or bsrptpgm='BFCREPORTS.R35800'
760cA       or bsrptpgm='BFCREPORTS.R40200'
770aA       or bsrptpgm='BFCREPORTS.R42900';
730qA      return *on;
730qA     other;
730qA      return *off;
730qA   endsl;
730qA /end-free
730qA
730qAp                 E
730qA*------------------------------------------------------------------
730qA*  SaveWrkFParms - Save Work File Parms
730qA*------------------------------------------------------------------
730qA
730qAp SaveWrkFParms   b
730qAd SaveWrkFParms   pi
730qA
730qAd ctr             s              3  0
730qA
730qA /free
730qA   // Save parms in array so you can build the command processor
730qA   // properly when you have all the parms.  This subprocedure is
730qA   // called for each parm and locates the next empty parm.  It populates
730qA   // and leaves.  This built array is used in BldWrkFCallStr.
730qA   ctr = 1;
730qA   dow ctr < 51;
730qA      // populate next blank array element with additional parm
730qA      if wrkfparmn(ctr) = *blanks;
730qA         wrkfparmn(ctr) = %trim(bsmrcprm);
730qA         wrkfparmv(ctr) = %trim(bsvalue);
730qA         leave;
730qA      endif;
730qA      ctr = ctr +1;
730qA   enddo;
730qA   return;
730qA /end-free
730qA
730qAP                 E
730qA*------------------------------------------------------------------
730qA*  BldWrkFCallStr - Build the command call string and call the report
730qA*                   Work File process to build data for the report
730qA*------------------------------------------------------------------
730qA
730qAp BldWrkFCallStr  b
730qAd BldWrkFCallStr  pi
730qA
730qAd ctr             s              3  0
730qA
730qA /free
730qA   // It is easiest to first build a QCMDSRC and Command on
730qA   // iSeries to call your program that builds the Report Work
730qA   // File.  The Select below will have a section for each report
730qA   // that is scheduled that needs to call work file build.  It
730qA   // will first build base parms like R33200 is with SESSID and
730qA   // Warehuse.  Session Id is being populated with a timestamp
730qA   // since we have no current method for getting session id before
730qA   // build work file.  You will also have to change your report
730qA   // to pass session id from the report when ran interactively
730qA   // because we will pass the parm from so it will get passed.It
730qA   // then loops and builds out the command string and executes.
730qA   // once complete Scheduler can then call the report and pass the
730qA   // timestamp used to build and all should be good.
760aA   if bsrptpgm<>'BFCREPORTS.R40700';      // set in extParms
730qA     rptTimeStamp = %char(%timestamp());
760aA   endif;
730qA   select;
740fA
740fA     // Batch processing for Empty Pick Slot w/Overflow
740fA     when bsrptpgm='BFCREPORTS.R35800';
740fA
740fA       cmdToRun = 'UPDSUM012 SESSID(' + sq + %trim(rptTimeStamp) +
740fA                   sq + ')';
740fA       // Add timestamp to act as replacement for Session Id for
740fA       // Scheduled Reports with Work Files.  MRC is still populating
740fA       // CALCULA007 on Selection side with Session Id.  But during
740fA       // the schedule process the Build File program is getting called
740fA       // at end of this subprocedure and it is tacking on CALCULA007 with
740fA       // the same timestamp so the report locates the correct data.
740fA       // Scheduler is single threaded so I see no real way to get dups
740fA       oURL = %trim(oURL) + '&CALCULA007=' +
740fA              %trim(rptTimeStamp);
740fA       cmdToRun = %trim(cmdToRun) + ' PWHSE(' + %char(iWhse) + ')';
740fA       ctr = 1;
740fA       dow ctr < 51;
740fA         if wrkfparmn(ctr) = *blanks;
740fA            leave;
740fA         endif;
740fA
740fA         // Convert CALCULA/Rxxx fields from MRC program to the
740fA         // appropriate values for iSeries command.  There will be
740fA         // a separte when block for each Report
740fA         select;
740fA            when bsrptpgm='BFCREPORTS.R35800';
740fA              select;
740fA                when %trim(wrkfparmn(ctr)) = 'R001';
740fA                   // Department
740fA                   wrkfparmn(ctr) = 'PWHDP';
740fA                when %trim(wrkfparmn(ctr)) = 'CALCULA005';
740fA                   // From Aisle
740fA                   wrkfparmn(ctr) = 'PFAISL';
740fA                when %trim(wrkfparmn(ctr)) = 'CALCULA006';
740fA                   // To Aisle
740fA                   wrkfparmn(ctr) = 'PTAISL';
740fA              endsl;
740fA         endsl;
740fA         cmdToRun = %trim(cmdToRun) + ' ' + %trim(wrkfparmn(ctr)) +
740fA                    '(' + %trim(wrkfparmv(ctr)) + ')';
740fA         ctr = ctr +1;
740fA       enddo;
740fA
740fA       // Execute command
740fA       reTurnCode = goCmd(%trim(cmdToRun));
740fA
760cA     // Batch processing for Selection % Report
760cA     when bsrptpgm='BFCREPORTS.R40200';
760cA
760cA       cmdToRun = 'UPDSUM016 SESSID(' + sq + %trim(rptTimeStamp) +
760cA                   sq + ')';
760cA       // Add timestamp to act as replacement for Session Id for
760cA       // Scheduled Reports with Work Files.  MRC is still populating
760cA       // CALCULA007 on Selection side with Session Id.  But during
760cA       // the schedule process the Build File program is getting called
760cA       // at end of this subprocedure and it is tacking on CALCULA007 with
760cA       // the same timestamp so the report locates the correct data.
760cA       // Scheduler is single threaded so I see no real way to get dups
760cA       oURL = %trim(oURL) + '&CALCULA011=' +
760cA              %trim(rptTimeStamp);
760cA       cmdToRun = %trim(cmdToRun) + ' PWHSE(' + %char(iWhse) + ')';
760cA       ctr = 1;
760cA       dow ctr < 51;
760cA         if wrkfparmn(ctr) = *blanks;
760cA            leave;
760cA         endif;
760cA
760cA         // Convert CALCULA/Rxxx fields from MRC program to the
760cA         // appropriate values for iSeries command.  There will be
760cA         // a separte when block for each Report
760cA         select;
760cA            when bsrptpgm='BFCREPORTS.R40200';
760cA              select;
760cA                when %trim(wrkfparmn(ctr)) = 'CALCULA005';
760cA                   // Begin Shift Date
760cA                   wrkfparmn(ctr) = 'PSDATE';
760cA                when %trim(wrkfparmn(ctr)) = 'CALCULA006';
760cA                   // End Shift Date
760cA                   wrkfparmn(ctr) = 'PEDATE';
760cA                when %trim(wrkfparmn(ctr)) = 'CALCULA007';
760cA                   // Shift
760cA                   wrkfparmn(ctr) = 'PSHIFT';
760cA                when %trim(wrkfparmn(ctr)) = 'CALCULA008';
760cA                   // Employee Number
760cA                   wrkfparmn(ctr) = 'PEMPNO';
760cA                when %trim(wrkfparmn(ctr)) = 'CALCULA009';
760cA                   // Omit Zero Employees
760cA                   wrkfparmn(ctr) = 'POMITZERO';
760cA              endsl;
760cA         endsl;
760cA         cmdToRun = %trim(cmdToRun) + ' ' + %trim(wrkfparmn(ctr)) +
760cA                    '(' + %trim(wrkfparmv(ctr)) + ')';
760cA         ctr = ctr +1;
760cA       enddo;
760cA
760cA       // Execute command
760cA       reTurnCode = goCmd(%trim(cmdToRun));
760cA
760aA     // Batch processing for Staging Interface Error Report
760aA     when bsrptpgm='BFCREPORTS.R40700';
760aA
760aA       cmdToRun = 'UPDSUM019 SESSID(' + sq + %trim(rptTimeStamp) +
760aA                   sq + ')';
760aA       // Add timestamp to act as replacement for Session Id for
760aA       // Scheduled Reports with Work Files.  MRC is still populating
760aA       // CALCULA007 on Selection side with Session Id.  But during
760aA       // the schedule process the Build File program is getting called
760aA       // at end of this subprocedure and it is tacking on CALCULA007 with
760aA       // the same timestamp so the report locates the correct data.
760aA       // Scheduler is single threaded so I see no real way to get dups
760aA       oURL = %trim(oURL) + '&CALCULA007=' +
760aA              %trim(rptTimeStamp);
760aA       ctr = 1;
760aA       dow ctr < 51;
760aA         if wrkfparmn(ctr) = *blanks;
760aA            leave;
760aA         endif;
760aA
760aA         // Convert CALCULA/Rxxx fields from MRC program to the
760aA         // appropriate values for iSeries command.  There will be
760aA         // a separte when block for each Report
760aA         select;
760aA            when bsrptpgm='BFCREPORTS.R40700';
760aA              select;
760aA                when %trim(wrkfparmn(ctr)) = 'CALCULA002';
760aA                   // Warehouse
760aA                   wrkfparmn(ctr) = 'PWHSE';
760aA                when %trim(wrkfparmn(ctr)) = 'CALCULA003';
760aA                   // Interface Batch Id
760aA                   wrkfparmn(ctr) = 'PBATID';
760bA              endsl;
760aA         endsl;
760aA         cmdToRun = %trim(cmdToRun) + ' ' + %trim(wrkfparmn(ctr)) +
760aA                    '(' + %trim(wrkfparmv(ctr)) + ')';
760aA         ctr = ctr +1;
760aA       enddo;
740fA
730qA       // Execute command
730qA       reTurnCode = goCmd(%trim(cmdToRun));
730qA     when bsrptpgm='BFCREPORTS.R33200';
730qA
730qA       cmdToRun = 'UPDSUM007 SESSID(' + sq + %trim(rptTimeStamp) +
730qA                   sq + ')';
730qA       // Add timestamp to act as replacement for Session Id for
730qA       // Scheduled Reports with Work Files.  MRC is still populating
730qA       // CALCULA001 on Selection side with Session Id.  But during
730qA       // the schedule process the Build File program is getting called
730qA       // at end of this subprocedure and it is tacking on CALCULA001 with
730qA       // the same timestamp so the report locates the correct data.
730qA       // Scheduler is single threaded so I see no real way to get dups
730qA       oURL = %trim(oURL) + '&CALCULA020=' +
730qA              %trim(rptTimeStamp);
730qA       cmdToRun = %trim(cmdToRun) + ' PWHSE(' + %char(iWhse) + ')';
730qA       ctr = 1;
730qA       dow ctr < 51;
730qA         if wrkfparmn(ctr) = *blanks;
730qA            leave;
730qA         endif;
730qA
730qA         // Convert CALCULA/Rxxx fields from MRC program to the
730qA         // appropriate values for iSeries command.  There will be
730qA         // a separte when block for each Report
730qA         select;
730qA            when bsrptpgm='BFCREPORTS.R33200';
730qA              select;
730qA                when %trim(wrkfparmn(ctr)) = 'CALCULA002';
730qA                   // Number of Replens
730qA                   wrkfparmn(ctr) = 'PTNUMRPLNS';
730qA                when %trim(wrkfparmn(ctr)) = 'CALCULA004';
730qA                   // From Aisle
730qA                   wrkfparmn(ctr) = 'PTFRMAISL';
730qA                when %trim(wrkfparmn(ctr)) = 'CALCULA005';
730qA                   // To Aisle
730qA                   wrkfparmn(ctr) = 'PTTOAISL';
730qA                when %trim(wrkfparmn(ctr)) = 'CALCULA006';
730qA                   // From Location
730qA                   wrkfparmn(ctr) = 'PTFRMLOC';
730qA                when %trim(wrkfparmn(ctr)) = 'CALCULA007';
730qA                   // To Location
730qA                   wrkfparmn(ctr) = 'PTTOLOC';
730qA                when %trim(wrkfparmn(ctr)) = 'CALCULA008';
730qA                   // Crew
730qA                   wrkfparmn(ctr) = 'PTCREW';
730qA                when %trim(wrkfparmn(ctr)) = 'CALCULA009';
730qA                   // Shift
730qA                   wrkfparmn(ctr) = 'PTSHFT';
730qA                when %trim(wrkfparmn(ctr)) = 'CALCULA010';
730qA                   // Task
730qA                   wrkfparmn(ctr) = 'PTTASK';
730qA                when %trim(wrkfparmn(ctr)) = 'CALCULA011';
730qA                   // From Task Date
730qA                   wrkfparmn(ctr) = 'PTFRMDATE';
730qA                when %trim(wrkfparmn(ctr)) = 'CALCULA012';
730qA                   // To Task Date
730qA                   wrkfparmn(ctr) = 'PTTODATE';
730qA              endsl;
730qA         endsl;
730qA         cmdToRun = %trim(cmdToRun) + ' ' + %trim(wrkfparmn(ctr)) +
730qA                    '(' + %trim(wrkfparmv(ctr)) + ')';
730qA         ctr = ctr +1;
730qA       enddo;
730qA
730qA       // Execute command
730qA       reTurnCode = goCmd(%trim(cmdToRun));
730uA
730uA     // Build work file for Daily Selection Label Report
730uA     when bsrptpgm='BFCREPORTS.R32300';
730uA
730uA       cmdToRun = 'UPDSUM011 SESSID(' + sq + %trim(rptTimeStamp) +
730uA                   sq + ')';
730uA       // Add timestamp to act as replacement for Session Id for
730uA       // Scheduled Reports with Work Files.  MRC is still populating
730uA       // CALCULA001 on Selection side with Session Id.  But during
730uA       // the schedule process the Build File program is getting called
730uA       // at end of this subprocedure and it is tacking on CALCULA001 with
730uA       // the same timestamp so the report locates the correct data.
730uA       // Scheduler is single threaded so I see no real way to get dups
730uA       oURL = %trim(oURL) + '&CALCULA018=' +
730uA              %trim(rptTimeStamp);
730uA       cmdToRun = %trim(cmdToRun) + ' PWHSE(' + %char(iWhse) + ')';
730uA       ctr = 1;
730uA       dow ctr < 51;
730uA         if wrkfparmn(ctr) = *blanks;
730uA            leave;
730uA         endif;
730uA
730uA         // Convert CALCULA/Rxxx fields from MRC program to the
730uA         // appropriate values for iSeries command.  There will be
730uA         // a separte when block for each Report
730uA         select;
730uA            when bsrptpgm='BFCREPORTS.R32300';
730uA              select;
730uA                when %trim(wrkfparmn(ctr)) = 'R001';
730uA                   // Transaction number
730uA                   wrkfparmn(ctr) = 'PTRANNUM';
730uA                when %trim(wrkfparmn(ctr)) = 'R002';
730uA                   // Route Id
730uA                   wrkfparmn(ctr) = 'PTRTEID';
730uA                when %trim(wrkfparmn(ctr)) = 'R003';
730uA                   // Pallet Id
730uA                   wrkfparmn(ctr) = 'PTPALLID';
730uA                when %trim(wrkfparmn(ctr)) = 'R004';
730uA                   // Employee List
730uA                   wrkfparmn(ctr) = 'PTEMPLIST';
730uA                when %trim(wrkfparmn(ctr)) = 'CALCULA005';
730uA                   // From Date - Save and join with time at end of loop
730uA                   calcula005 = wrkfparmv(ctr);
730uA                when %trim(wrkfparmn(ctr)) = 'CALCULA006';
730uA                   // To Date - Save and join with time at end of loop
730uA                   calcula006 = wrkfparmv(ctr);
730uA                when %trim(wrkfparmn(ctr)) = 'CALCULA007';
730uA                   // Include RF/Voice Selection Option
730uA                   wrkfparmn(ctr) = 'PTRFVOICE';
730uA                when %trim(wrkfparmn(ctr)) = 'CALCULA008';
730uA                   // Include UPC UOM Exists Option
730uA                   wrkfparmn(ctr) = 'PTUPCE';
730uA                when %trim(wrkfparmn(ctr)) = 'CALCULA009';
730uA                   // Include RF/Voice Errors Option
730uA                   wrkfparmn(ctr) = 'PTVOERRORS';
730uA                when %trim(wrkfparmn(ctr)) = 'R005';
730uA                   // Item
730uA                   wrkfparmn(ctr) = 'PTITEM';
730uA              endsl;
730uA         endsl;
              if wrkfparmn(ctr)<>'CALCULA005' and wrkfparmn(ctr)<>'CALCULA006';
                // calc5 and calc6 are joined with selected times and built into
                // workfile parms below after do loop
730uA           cmdToRun = %trim(cmdToRun) + ' ' + %trim(wrkfparmn(ctr)) +
730uA                      '(' + %trim(wrkfparmv(ctr)) + ')';
              endif;

730uA         ctr = ctr +1;
730uA       enddo;
730uA
730uA       // Build from and todate/time fields to build work file
730uA       cmdToRun = %trim(cmdToRun) + ' PTFDTETIM(' + %trim(calcula005) +
730uA                  %trim(fromHr) + %trim(fromMin) + '00)';
730uA       cmdToRun = %trim(cmdToRun) + ' PTTDTETIM(' + %trim(calcula006) +
730uA                  %trim(toHr) + %trim(toMin) + '00)';
740iA
740iA       // Return List hidden from GUI selection screen but still passed
740iA       // as empty so we need to mimic
740iA       cmdToRun = %trim(cmdToRun) + ' PTRTNLIST()';
730uA
730uA       // Execute command
730uA       reTurnCode = goCmd(%trim(cmdToRun));
730uA
770aA     // Build work file for Drop Pick Issues Report
770aA     when bsrptpgm='BFCREPORTS.R42900';
770aA
770aA       cmdToRun = 'UPDSUM020 SESSID(' + sq + %trim(rptTimeStamp) +
770aA                   sq + ')';
770aA       // Add timestamp to act as replacement for Session Id for
770aA       // Scheduled Reports with Work Files.  MRC is still populating
770aA       // CALCULA001 on Selection side with Session Id.  But during
770aA       // the schedule process the Build File program is getting called
770aA       // at end of this subprocedure and it is tacking on CALCULA001 with
770aA       // the same timestamp so the report locates the correct data.
770aA       // Scheduler is single threaded so I see no real way to get dups
770aA       oURL = %trim(oURL) + '&CALCULA002=' +
770aA              %trim(rptTimeStamp);
770aA       cmdToRun = %trim(cmdToRun) + ' PUSER(' + 'BFCRPTS' + ')';
770aA       cmdToRun = %trim(cmdToRun) + ' PDICT(' + 'BFCREPORTS' + ')';
770aA       cmdToRun = %trim(cmdToRun) + ' PPGM(' + 'R42900' + ')';
770aA       cmdToRun = %trim(cmdToRun) + ' PPARMSTR1(' + sq + 'whse=' +
770aA                                      %editc(iWhse:'X') + sq + ')';
770aA
770aA       // Execute command
770aA       reTurnCode = goCmd(%trim(cmdToRun));
770aA
730gA   endsl;
730qA /end-free
730qA
730qAP                 E
760aA*------------------------------------------------------------------
760aA*  extParms - Save parms sent via direct call in case work file required
760aA*------------------------------------------------------------------
760aA
760aAp extParms        b
760aAd extParms        pi
760aA
760aAd ctr             s              3  0
760aAd str             s              5  0
760aAd end             s              5  0
760aA
760aA /free
760aA   // Save parms in array so you can build the command processor
760aA   // properly when you have all the parms.  This subprocedure is called
760aA   // within processReport routine for reports being called outside the
760aA   // scheduler as direct calls from iSeries.  This will loop through the
760aA   // url sent capturing any Rxxx or CALCULAxxx fields and add to array
760aA   // used in BldWrkFCall
760aA   str=1;
760aA   end=1;
760aA   ctr = 0;
760aA   select;
760aA     when currRptPgm = 'BFCREPORTS.R40700';
760aA       // get each parm for work file build
760aA         if %scan('CALCULA001':iurl:str) <> 0;     // Session/TimeStamp from Interface pgm
760aA           str = %scan('CALCULA001':iurl:str);
760aA           // for session variable I am only going through
760aA           // the motions to get to the proper timestamp
760aA           // used as session if for this report.  In this
760aA           // case it is parm CALCULA001.  We put value of
760aA           // calcula001 in rptTimeStamp below
760aA           str = str + 11;
760aA           if %scan('&':iurl:str) <> 0;
760aA             end = %scan('&':iurl:str);
760aA           else;
760aA             end = %scan(' ':iurl:str);
760aA           endif;
760aA           // reverse the html escape characters from interface pgm
760aA           DateString = %subst(iUrl:str:end-(str));
                rptTimeStamp = %trim(reverseHTML(DateString));
760aA         endif;
760aA         if %scan('CALCULA002':iurl:str) <> 0;     // WAREHOUSE
760aA           ctr = ctr + 1;
760aA           str = %scan('CALCULA002':iurl:str);
760aA           wrkfparmn(ctr) = %subst(iUrl:str:10);
760aA           str = str + 11;
760aA           if %scan('&':iurl:str) <> 0;
760aA             end = %scan('&':iurl:str);
760aA           else;
760aA             end = %scan(' ':iurl:str);
760aA           endif;
760aA           wrkfparmv(ctr) = %subst(iUrl:str:end-(str));
760aA         endif;
760aA         if %scan('CALCULA003':iurl:str) <> 0;     // Batch Id
760aA           ctr = ctr + 1;
760aA           str = %scan('CALCULA003':iurl:str);
760aA           wrkfparmn(ctr) = %subst(iUrl:str:10);
760aA           str = str + 11;
760aA           if %scan('&':iurl:str) <> 0;
760aA             end = %scan('&':iurl:str);
760aA           else;
760aA             end = %scan(' ':iurl:str);
760aA           endif;
760aA           wrkfparmv(ctr) = %subst(iUrl:str:end-(str));
760aA         endif;
760bA         if %scan('CALCULA005':iurl:str) <> 0;     // Email Subject
760bA           ctr = ctr + 1;
760bA           str = %scan('CALCULA005':iurl:str);
760bA           wrkfparmn(ctr) = %subst(iUrl:str:10);
760bA           str = str + 11;
760bA           if %scan('&':iurl:str) <> 0;
760bA             end = %scan('&':iurl:str);
760bA           else;
760bA             end = %scan(' ':iurl:str);
760bA           endif;
760bA           wrkfparmv(ctr) = %subst(iUrl:str:end-(str));
760bA           if wrkfparmv(ctr) <> *blanks;
760bA             DateString=%trim(wrkfparmv(ctr));
760bA             emailSubject = %trim(reverseHTML(DateString));
760bA             wrkfparmn(ctr)=*blanks;
760bA             wrkfparmv(ctr)=*blanks;
760bA             ctr = ctr - 1;
760bA           endif;
760bA         endif;
760aA         bsrptpgm=currRptPgm;
760aA         BldWrkFCallStr();  // Build Work File for Report
760aA   endsl;
760aA   return;
760aA /end-free
760aAP                 E
