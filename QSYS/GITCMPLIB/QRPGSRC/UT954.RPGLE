      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  UT954     End Jobs for User ID
     *  19 August 2014
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650a *    08/19/14  RTR  6.50a
     *      - Created from sample code online.
     *      - Modified to end certain types of jobs.
650b *    10/27/14  RTR  6.50b
     *      - Changed return message from 40 to 50 chars because it was
     *        being truncated.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pUserID   User ID to end jobs for
     *
     *    Returned Parameters
     *      $pReturn   Result message
     *
     *----------------------------------------------------------------
     D main            pr                  extpgm('UT954')
      * Input
     D   $pUserID                    10
      * Output
605bMD   $pReturn                    50
650bDD*  $pReturn                    40

     D main            pi
     D   $pUserID                    10
650bMD   $pReturn                    50
650bDD*  $pReturn                    40

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *
     d CommandCall     pr                  extpgm('QCMDEXC')
     d  parmcmd                     200
     d  parmlen                      15  5

     *----------------------------------------------------------------
      *
      * CrtUsrSpc: Create User Space for OS/400 API's
      *
     d QUSCRTUS        pr                  extpgm('QUSCRTUS')
     d   UsrSpc                      20A   const
     d   ExtAttr                     10A   const
     d   InitialSize                 10I 0 const
     d   InitialVal                   1A   const
     d   PublicAuth                  10A   const
     d   Text                        50A   const
     d   Replace                     10A   const
     d   ErrorCode                32766A   options(*nopass: *varsize)
      *
      * --- Prototype for API Retrive User Space
      *
     d QUSRTVUS        pr                  extpgm( 'QUSRTVUS' )
     d   QRtvUserSpace...
     d                               20
     d   QRtvStartingPosition...
     d                                8b 0
     d   QRtvLengthOfData...
     d                                8b 0
     d   QRtvReceiverVariable...
     d                            32048
     d   QRtvError...
     d                              256

      * --- Prototype for API Retrive List Job
      *
     d QUSLJOB         pr                  extpgm( 'QUSLJOB' )
     d   QJobUserSpace...
     d                               20
     d   QJobFormatName...
     d                                8
     d   QJobJobName...
     d                               26
     d   QFldStatus...
     d                               10
     d   QFldError...
     d                              256
     d   QJobType...
     d                                1
     d   QNbrFldRtn...
     d                                8b 0
     d   QKeyFldRtn...
     d                                8b 0 dim( 100 )
      *
     d qcmdexc         pr                  extpgm( 'QCMDEXC' )
     d   os400_cmd                 2000A   options( *varsize ) const
     d   cmdlength                   15P 5                     const
      *
      * Defined variables
      *
     d*emailaddress    s             24    inz('email1@domain.com')
     d*emailaddress1   s             29    inz('email2@domain.com')
     d strcmd          s            200a
     d strlen          s             15  5
     d size            s             10I 0 inz(10000)
     d UsrSpcName      s             20    inz( 'UT954     QTEMP     ' )

      *
      ******************************************************************

     dQUSA0100         DS
     d QUsrSpcOffset...
     d                         1      4B 0
     d QUsrSpcEntries...
     d                         9     12B 0
     d QUsrSpcEntrieSize...
     d                        13     16B 0

     dLJOBINPUT        ds                           qualified
     d  JobName...
     d                         1     10
     d  UserName...
     d                        11     20
     d  JobNumber...
     d                        21     26
     d  Status...
     d                        27     36
     d  UserSpace...
     d                        37     46
     d  UserSpaceLibrary...
     d                        47     56
     d  Format...
     d                        57     64
     d  JobType...
     d                        65     65
     d  Reserved01...
     d                        66     68
     d  Reserved02...
     d                        69     72B 0
      *
     dLJOB100          ds                           qualified
     d  JobName...
     d                         1     10
     d  UserName...
     d                        11     20
     d  JobNumber...
     d                        21     26
     d  InternalJobId...
     d                        27     42
     d  Status...
     d                        43     52
     d  JobType...
     d                        53     53
     d  JobSubType...
     d                        54     54
     d  Reserved01...
     d                        55     56
      *
     dLJOB200          ds                           qualified
     d  JobName...
     d                         1     10
     d  UserName...
     d                        11     20
     d  JobNumber...
     d                        21     26
     d  InternalJobId...
     d                        27     42
     d  Status...
     d                        43     52
     d  JobType...
     d                        53     53
     d  JobSubType...
     d                        54     54
     d  Reserved01...
     d                        55     56
     d  JobInfoStatus...
     d                        57     57
     d  Reserved02...
     d                        58     60
     d  NumberOfFieldsReturned...
     d                        61     64B 0
     d  ReturnedData...
     d                        65   1064
      *
     dLJOB200KEY       ds                           qualified
     d  KeyNumber01...
     d                         1      4B 0
     d  NumberOfKeys...
     d                         5      8B 0
      *
     dLJOBKEYINFO      ds                           qualified
     d  LengthOfInformation...
     d                         1      4b 0
     d  KeyField...
     d                         5      8b 0
     d  TypeOfData...
     d                         9      9
     d  Reserved01...
     d                        10     12
     d  LengthOfData...
     d                        13     16B 0
     d  KeyData...
     d                        17   1016
      *
      *  APIErrDef     Standard API error handling structure.
      *
     dQUSEC            DS
     d  ErrorBytesProvided...
     d                         1      4B 0
     d  ErrorBytesAvailble...
     d                         5      8b 0
     d  ErrorExceptionId...
     d                         9     15
     d  ErrorReserved...
     d                        16     16
      *
     dAPIError         DS
     d APIErrorProvied...
     d                                     LIKE( ErrorBytesProvided )
     d                                     INZ( %LEN( APIError ) )
     d APIErrorAvailble...
     d                                     LIKE( ErrorBytesAvailble )
     d APIErrorMessageID...
     d                                     LIKE( ErrorExceptionId )
     d APIErrorReserved...
     d                                     LIKE( ErrorReserved )
     d APIErrorInformation...
     d                              240A

      *-----------------------------------------------------------------
      * program status dataarea
      *-----------------------------------------------------------------
     d PgmSts         SDS
     d   P1User              254    263
     d   W1Program       *PROC

      *--------------------------------------------------------------*
      * work fields                                                  *
      *--------------------------------------------------------------*
     d Variables       ds
     d   Q                            1    inz( '''' )
     d   Count                       15  0 inz(  0   )
     d   KeyCount                    15  0 inz(  0   )
     d   EndPos                      15  0 inz(  0   )
     d   JobbStatus                   4    inz( ' '  )
     d   Subsystem                   20    inz( ' '  )
     d   SubShort                    20    inz( ' '  )
     d   ReturnCode                   1    inz( ' '  )
     d   FormatName                   8    inz( ' ' )
     d   QualifedJobName...
     d                               26    inz( ' ' )
     d   JobStatus                   10    inz( ' ' )
     d   JobType                      1    inz( ' ' )
     d   NbrOfFldRtn                  8B 0 inz(  0  )
     d   KeyFldRtn                    8B 0 inz(  0  ) dim( 100 )
     d   StartingPosition...
     d                                8B 0 inz(  0  )
     d   LengthOfData...
     d                                8B 0 inz(  0  )
     d   KeyStartingPosition...
     d                                8B 0 inz(  0  )
     d   KeyLengthOfData...
     d                                8B 0 inz(  0  )
     d   ReceiverVariable...
     d                            32048
     d   OS400_Cmd                 2000    inz( ' '  )
     d   CmdLength                   15P 5 inz( %size( OS400_Cmd ) )
     d   True                         1    inz( *on  )
     d   False                        1    inz( *off )
     d   endcnt                       6s 0

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        exsr CheckJobs;

        select;
          when $pReturn <> *blanks;
          when endcnt = 0;
            $pReturn = 'No interactive jobs found for user '
                     + %trim($pUserid) + '.';
          when endcnt > 0;
            $pReturn = %char(endcnt) + ' jobs ended for user '
                     + %trim($pUserid) + '.';
        endsl;
        *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *  CHECKJOBS   Checks for active jobs for the user
     *----------------------------------------------------------------
      /free
       begsr CheckJobs;

         // Create a user space
         QUSCRTUS(UsrSpcName: 'USRSPC': size: x'00': '*ALL':
                  'Temp User Space for  QUSLJOB API':  '*YES': APIError);

         // Set up API parms
         FormatName = 'JOBL0200';
         QualifedJobName = '*ALL      ' + $pUserID + '*ALL  ';
         JobStatus = '*ALL';
         JobType = '*';
         NbrOfFldRtn = 2;
         KeyFldRtn( 1 ) = 0101;
         KeyFldRtn( 2 ) = 1906;

         // Run API to fill user space job information
         callp QUSLJOB( UsrSpcName  : FormatName  : QualifedJobName :
                        JobStatus   : APIError    : JobType         :
                        NbrOfFldRtn : KeyFldRtn   );

         // If error message from the API then dump program
         if APIErrorMessageID <> ' ';
           dump;
           ReturnCode = True;
           $pReturn = 'API Error: QUSLJOB ' + APIErrorMessageID;
           leavesr;
         endif;

         // Run API to get user space attributes
         StartingPosition = 125;
         LengthOfData = 16;
         callp QUSRTVUS( UsrSpcName   : StartingPosition :
                         LengthOfData : ReceiverVariable :
                         APIError );
         QUSA0100 = ReceiverVariable;

         // If error message from the API then dump program
         if APIErrorMessageID <> ' ';
           dump;
           ReturnCode = True;
           $pReturn = 'API Error: QUSRTVUS ' + APIErrorMessageID;
           leavesr;
         endif;

         // Read from user space
         StartingPosition = QUsrSpcOffset + 1;
         LengthOfData = QUsrSpcEntrieSize;

         for count = 1 to QUsrSpcEntries;
           callp QUSRTVUS( UsrSpcName   : StartingPosition  :
                           LengthOfData : ReceiverVariable  :
                           APIError );
           LJOB200 = ReceiverVariable;
           if APIErrorMessageID <> ' ';
             dump;
             ReturnCode = True;
             $pReturn = 'API Error: QUSRTVUS ' + APIErrorMessageID;
             leavesr;
           endif;

           // End selected jobs.
           exsr EndJobs;

           StartingPosition = StartingPosition + LengthOfData;
         endfor;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  ENDJOBS     Ends jobs that match criteria
     *----------------------------------------------------------------
      /free
       begsr EndJobs;

           select;
             when %subst(LJOB200.UserName:1:1) = 'Q';
               // skip system jobs.
             when LJOB200.Status = '*OUTQ';
               // skip finished jobs.
             when LJOB200.JobType = 'B';
               // skip batch jobs.
             when %subst(LJOB200.JobName:1:6) = 'BFCWTD';
               // skip BFC WRTTRAN jobs.

             other;
               clear strcmd;
               strcmd = 'ENDJOB JOB('
                      + LJOB200.JobNumber + '/'
                      + %trim(LJOB200.UserName) + '/'
                      + %trim(LJOB200.JobName)
                      + ') OPTION(*IMMED)';
               strlen = %len(%trim(strcmd));
               callp(e) CommandCall ( strcmd : strlen );
               endcnt = endcnt + 1;

           endsl;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR      Initialization
     *----------------------------------------------------------------
      /free
       begsr *inzsr;

         endcnt = 0;
         $pReturn = *blanks;

        endsr;
      /end-free
