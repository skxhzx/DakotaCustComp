      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  DRIORDC     Dakota realtime interface - Selection Catchweights
     *  19 November 2013
     *  Dave Sommerville
     *
650 A*    11/19/13  DAS  6.50
     *      - Created
     *
650aA*    04/23/14  DAS  6.50a
     *      - Added logic for working with catchweight flag file ORDCFLG
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  - Logic has not been included to be called by a Host system.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub-Command Notes
     *
     *      *OPEN        Open program and return.
     *
     *      *CLOSE       Close program with *INLR = *ON
     *
     *      *ADD         Add catchweight
     *
     *      *CHANGE      Change catchweight
     *
     *      *DELETE      Delete catchweight
     *
650aA*      *GETFLGLBL   Get lowest flag for label
650aA*      *GETFLGTRN   Get lowest flag for transaction
650aA*      *GETFLGWGT   Get lowest flag for individual weight
650aA*      *GETLBLCNT   Get label level count flag
650aA*      *GETLBLVAR   Get label level variance flag
     *
650aA*      *OVRLBLCNT   Override label level count flag
650aA*      *OVRLBLVAR   Override label level variance flag
     *
     *      *VERIFYADD   Do "ADD" verification without update
     *
     *      *VERIFYCHG   Do "CHANGE" verification without update
     *
     *      *VERIFYDEL   Do "DELETE" verification without update
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fordc1     uf a e           k disk
     F                                     infds(file1ds)
650aAFordcflg   uf a e           k disk
650aAFordcflg1  if   e           k disk    rename(ocfrec:ocfrec1)
650aAFordcflg2  uf   e           k disk    rename(ocfrec:ocfrec2)
650aAFordcflg3  uf   e           k disk    rename(ocfrec:ocfrec3)
650aAFoptions   if   e           k disk
     Flabel     if   e           k disk
650aAFlabel7    if   e           k disk
650aAFitemmsc   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

650aA /copy qcopysrc,id#nichola
650aA /copy qcopysrc,id#glazier

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ORDC
     D saveVer#        s                   like($ocver#)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D HostCall        s               n
650aAD wrtFlag         s               n

650aAD client          s             10
650aAD clientloc       s             10

650aAD hvskp           s               n
650aAD ihrng           s             13  2
650aAD ihvar           s             13  2
650aAD ilrng           s             13  2
650aAD ilvar           s             13  2
650aAD lvskp           s               n
650aAD prg1c           s              4  3
650aAD prg2c           s              4  3
650aAD tfrorder        s              4    inz('*NO ')
650aAD opicwflag       s              1
650aAD opwrncflag      s              1
650aAD warningFlag     s              1
650aAD pieces          s                   like(lbqpck)
650aAD rngText         s             20
650aAD saveCmd         s             10
650aAD wgtCount        s              5  0
650aAD ttlWgt          s             13  2
650aAD weight          s              7  2

530bAD curwhse         s                   like(ocwhse)
530bAD curtrn          s                   like(octran)
530bAD curlbl          s                   like(oclbl#)
530bAD curord          s                   like(ocord)
530bAD curosq          s                   like(ocseq#)
530bAD curitem         s                   like(ocitem)
530bAD curwsq          s                   like(ocseq)

     *----------------------------------------------------------------
410aA*  *SYSTEM  -  System options.
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
410 A*    OPWRNC  -  Perform catch weight variance check (Y,N).
410 A*    OPRG1C  -  Catch weight low variance percentage.
410 A*    OPRG2C  -  Catch weight high variance percentage.
411 A*    OPIMPI  -  Import item fields from host.(Y,N).
412 A*    OPICW   -  Individual catch weight entry (Y,N).
530aA*    OPUCI   -  Use UCI processing (Y,N) ntry (Y,N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
410 AD  opwrnc                 5      5
410 AD  oprg1c                 6      8  1
410 AD  oprg2c                 9     11  1
411 AD  opimpi                12     12
412 AD  opicw                 13     13
530aAD  opuci                 36     36
     D  optend               117    117

     *----------------------------------------------------------------
     *  File information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

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
         $ordc = $pdata;
         $preturn = '*OK';
         $pmessage = ' ';
      /end-free

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

       // Turn LR on for testing. Otherwise, pgm changes will not be recognized
       // in the GUI program until the Tomcat server is rebooted.

       *inlr = *on;

       dou 1=1; //bottom

         // See which system is calling the program.

         if %subst($psubcmd:1:1) = '%';
           DakotaCall = *on;
           HostCall = *off;
           %subst($psubcmd:1:1) = '*';
         else;
           HostCall = *on;
           DakotaCall = *off;
         endif;

         // See if we are just opening or closing program.

         select;

           when $psubcmd = '*OPEN';
             $preturn = '*OK';
             $pmessage = ' ';
             leave; //bottom

           when $psubcmd = '*CLOSE';
             $preturn = '*OK';
             $pmessage = ' ';
             exsr aaaclose;
             *inlr = *on;
             leave; //bottom

         endsl;

         // Otherwise, do some initialization and move on.

         exsr aaainit;
         error = *off;

650aA    // Check that flags have already been created
650aA
650aA    exsr FirstCheck;

         // Do what user has requested.

         select;

           when $psubcmd = '*ADD';
             exsr VerifyAdd;
             if not error;
               exsr AddCW;
             endif;

           when $psubcmd = '*CHANGE';
             exsr VerifyChg;
             if not error;
               exsr ChangeCW;
             endif;

           when $psubcmd = '*DELETE';
             exsr VerifyDel;
             if not error;
               exsr DeleteCW;
             endif;

650aA      when $psubcmd = '*GETFLGLBL';
             exsr VerifyGetLbl;
             if not error;
650aA          exsr GetFlgLbl;
             endif;

650aA      when $psubcmd = '*GETFLGTRN';
             exsr VerifyGetTrn;
             if not error;
650aA          exsr GetFlgTrn;
             endif;

650aA      when $psubcmd = '*GETFLGWGT';
             exsr VerifyGetWgt;
             if not error;
650aA          exsr GetFlgWgt;
             endif;

650aA      when $psubcmd = '*GETLBLCNT';
             exsr VerifyGetLbl;
             if not error;
650aA          exsr GetLblCnt;
             endif;

650aA      when $psubcmd = '*GETLBLVAR';
             exsr VerifyGetLbl;
             if not error;
650aA          exsr GetLblVar;
             endif;

650aA      when $psubcmd = '*OVRLBLCNT';
             exsr VerifyOvrLbl;
             if not error;
650aA          exsr OverrideLblCnt;
             endif;

650aA      when $psubcmd = '*OVRLBLVAR';
             exsr VerifyOvrLbl;
             if not error;
650aA          exsr OverrideLblVar;
             endif;

           when $psubcmd = '*VERIFYADD';
             exsr VerifyAdd;

           when $psubcmd = '*VERIFYCHG';
             exsr VerifyChg;

           when $psubcmd = '*VERIFYDEL';
             exsr VerifyDel;

           other;
             error = *on;
             $preturn = 'INVLDSBCMD';
             $pmessage = 'Invalid subcommand '
                       + '(' + %trim($psubcmd) + ') '
                       + 'sent to ' + %trim(#pgm);

         endsl;

       enddo; //bottom

       // We are finished so get out

       $pdata = $ordc;
       return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   endsr

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
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

      /free
       begsr aaainit;

         chain (0: '*SYSTEM') options;
         if not %found(options);
           opcapc = 'Y';
           opwrnc = 'N';
           oprg1c = 0;
           oprg2c = 0;
           opicw = 'N';
         endif;

         if opicw = 'N';
           opicwflag = 'N';
         else;
           opicwflag = 'Y';
         endif;

         if opwrnc = 'N';
           opwrncflag = 'N';
         else;
           opwrncflag = 'Y';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  aaaclose   Close called programs
     *----------------------------------------------------------------

      /free
       begsr aaaclose;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddCW      Add catchweight
     *----------------------------------------------------------------

      /free
       begsr AddCW;

         // Get next weight seq# to use

         setgt ($ocwhse: $oclbl#) ordc1;
         readp ordc1;
         if %eof(ordc1)
           or ocwhse <> $ocwhse
           or oclbl# <> $oclbl#;
             ocseq = 1;
         else;
             ocseq += 1;
         endif;

         // Initialize the rest of the fields and write record

         ocwhse = $ocwhse;
         ocord  = $ocord;
         ocseq# = $ocseq#;
         ocitem = $ocitem;
         octran = $octran;
         oclbl# = $oclbl#;
         occwgt = $occwgt;

         write(e) ocrec;
         if %error;
           error = *on;
           $oclbl#e = $drierror;
           $preturn  = 'ERRADDREC';
           $pmessage = 'Error adding ORDC rec '
                       + '(' + %trimr(f1messageid) + ')'
                       + '('
                       + %trim(%char(ocwhse))
                       + '/'
                       + %trim(%char(ocord))
                       + '/'
                       + %trim(%char(ocseq#))
                       + '/'
                       + %trim(ocitem)
                       + '/'
                       + %trim(%char(oclbl#))
                       + '/'
                       + %trim(%char(ocseq))
                       + ')';
           leavesr;
         endif;

         // Create weight flags

         curwhse = ocwhse;
         curtrn = octran;
         curlbl = oclbl#;
         curord = ocord;
         curosq = ocseq#;
         curitem = ocitem;
         curwsq = ocseq;
         weight = occwgt;

         if $occwgte = $driwarnovr;
           warningFlag = '3';
         else;
           warningFlag = '2';
         endif;

         wrtFlag = *on;
         exsr VfyWeight;

         // Create label flags

         // After a new weight has been added, any label warnings
         // will be set to '2' and need to be overriden.

         warningFlag = '2';

         wrtFlag = *on;
         exsr VfyLabel;

         // Clear some return values that can be ignored from the Vfy routines.

         $preturn = '*OK';
         $pmessage = ' ';
         $rtnshort = ' ';

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  CalcVariance   Calculate variances (based on code from CW112)
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr CalcVariance;

         lvskp = *off;
         hvskp = *off;
         prg1c = 0;
         prg2c = 0;
         ilvar = 0;
         ihvar = 0;

         // See if there is an item variance percentage

         chain (curwhse: curitem) itemmsc;

         if %found(itemmsc);

           if imrg1c > 0;
             prg1c = imrg1c / 100;
             if imrg1c = 99;
               lvskp = *on;
             endif;
           endif;

           if imrg2c > 0;
             prg2c = imrg2c / 100;
             if imrg2c = 99;
               hvskp = *on;
             endif;
           endif;

         endif;

         // If no item variance percentage, get system variance percentage.

         if prg1c = 0;
           if oprg1c > 0;
             prg1c = oprg1c / 100;
           endif;
         endif;

         if prg2c = 0;
           if oprg2c > 0;
             prg2c = oprg2c / 100;
           endif;
         endif;

         // Calculate weight variance

         if not lvskp;
           if prg1c = 0;
             lvskp = *on;
           else;
             ilvar = (pieces * lbuwgt) * prg1c;
             ilrng = (pieces * lbuwgt) - ilvar;
           endif;
         endif;

         if not hvskp;
           if prg2c = 0;
             hvskp = *on;
           else;
             ihvar = (pieces * lbuwgt) * prg2c;
             ihrng = (pieces * lbuwgt) + ihvar;
           endif;
         endif;

         // Create range text

         select;
           when lvskp and hvskp;
             rngText = '';
           when lvskp;
             rngText = '( wgt > ' + %char(ihrng) + ' )';
           when hvskp;
             rngText = '( wgt < ' + %char(ilrng) + ' )';
           other;
             rngText = '( ' + %char(ilrng) + '-' + %char(ihrng) + ' )';
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChangeCW   Change catchweight
     *----------------------------------------------------------------

      /free
       begsr ChangeCW;

         // Update weight. Record locked in VERIFYCHG routine.

         occwgt = $occwgt;

         update(e) ocrec;
         if %error;
           error = *on;
           $oclbl#e = $drierror;
           $preturn  = 'ERRUPDREC';
           $pmessage = 'Error updating ORDC record '
                       + '(' + %trimr(f1messageid) + ')'
                       + '('
                       + %trim(%char(ocwhse))
                       + '/'
                       + %trim(%char(oclbl#))
                       + '/'
                       + %trim(%char(ocseq))
                       + ')';
           leavesr;
         endif;

         // Create weight flags

         curwhse = ocwhse;
         curtrn = octran;
         curlbl = oclbl#;
         curord = ocord;
         curosq = ocseq#;
         curitem = ocitem;
         curwsq = ocseq;
         weight = occwgt;

         if $occwgte = $driwarnovr;
           warningFlag = '3';
         else;
           warningFlag = '2';
         endif;

         wrtFlag = *on;
         exsr VfyWeight;

         // Create label flags

         // After a new weight has been added, any label warnings
         // will be set to '2' and need to be overriden.

         warningFlag = '2';

         wrtFlag = *on;
         exsr VfyLabel;

         // Clear some return values that can be ignored from the Vfy routines.

         $preturn = '*OK';
         $pmessage = ' ';
         $rtnshort = ' ';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DeleteCW   Delete catchweight
     *----------------------------------------------------------------

      /free
       begsr DeleteCW;

         // Delete record. Record locked in VERIFYCHG routine.

         delete(e) ocrec;
         if %error;
           error = *on;
           $oclbl#e = $drierror;
           $preturn  = 'ERRDELREC';
           $pmessage = 'Error deleting ORDC record '
                       + '(' + %trimr(f1messageid) + ')'
                       + '('
                       + %trim(%char(ocwhse))
                       + '/'
                       + %trim(%char(oclbl#))
                       + '/'
                       + %trim(%char(ocseq))
                       + ')';
           leavesr;
         endif;

         // Delete corresponding flag records.

         setll (ocwhse: oclbl#: ocord: ocseq#: ocitem: ocseq) ordcflg3;

         dow forever = forever;

           reade (ocwhse: oclbl#: ocord: ocseq#: ocitem: ocseq) ordcflg3;
           if %eof(ordcflg3);
             leave;
           endif;

           delete(e) ocfrec3;

         enddo;

         // Create label flags

         // After a new weight has been added, any label warnings
         // will be set to '2' and need to be overriden.

         warningFlag = '2';

         curwhse = ocwhse;
         curtrn = octran;
         curlbl = oclbl#;

         wrtFlag = *on;
         exsr VfyLabel;

         // Clear some return values that can be ignored from the Vfy routines.

         $preturn = '*OK';
         $pmessage = ' ';
         $rtnshort = ' ';

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  FirstCheck   First check if a flag record exists
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr FirstCheck;

         // Get out if transaction is zero.
         // Sometimes the tran is not sent for label or weight commands.
         // We will assume a command sending in the tran will be called first.

         if not $octranu or $octran = 0;
           leavesr;
         endif;

         // Create warnings that need to be overridden for first check.

         warningFlag = '2';

         // See if a record exists for transaction.

         exsr GetFlgTrn;

         // If record exists, get out because initial check has been done.

         if $ocfcod <> ' ';
           leavesr;
         endif;

         // Otherwise, do initial check for transaction.

         // Temporarily set command to *INIT.

         saveCmd = $psubcmd;
         $psubcmd = '*INIT';

         // Loop through labels for transaction

         setll ($octran) label7;

         dow forever = forever;

           reade ($octran) label7;
           if %eof(label7);
             leave;
           endif;

           // Only look at O and B records.

           if lbtype <> 'O' and lbtype <> 'B';
             iter;
           endif;

           // Only work with weight items.

           if itcwgt <> 'Y';
             iter;
           endif;

           // Do label checks

           curwhse = lbwhse;
           curtrn = lbtrn#;
           curlbl = lblbl#;
           wrtFlag = *on;
           exsr VfyLabel;

           // Loop through entered weights for label

           setll (lbwhse: lblbl#) ordc1;

           dow forever = forever;

             reade(n) (lbwhse: lblbl#) ordc1;
             if %eof(ordc1);
               leave;
             endif;

             // Do individual weight checks

             curwhse = ocwhse;
             curtrn = octran;
             curlbl = oclbl#;
             curord = ocord;
             curosq = ocseq#;
             curitem = ocitem;
             curwsq = ocseq;
             weight = occwgt;
             wrtFlag = *on;
             exsr VfyWeight;

           enddo;

         enddo;

         // If no flag records exist now, then write out all-clear record.

         exsr GetFlgTrn;

         if $ocfcod = ' ';
           clear ocfrec;
           ocfwhs = $ocwhse;
           ocftrn = $octran;
           ocfcod = '99';
           ocfflg = '4';
           write(e) ocfrec;
         endif;

         // Restore original command

         $psubcmd = saveCmd;

       endsr;
      /end-free

650a *----------------------------------------------------------------
650a *  GetFlgLbl  Get lowest flag for label
650a *----------------------------------------------------------------
650a
650a  /free
650aA  begsr GetFlgLbl;

         $ocfcod = ' ';
         $ocfflg = ' ';
         $pmessage = ' ';
         $rtnshort = ' ';

         setll ($ocwhse: $oclbl#) ordcflg2;
         reade(n) ($ocwhse: $oclbl#) ordcflg2;

         if not %eof(ordcflg2);
           $ocfcod = ocfcod;
           $ocfflg = ocfflg;
           exsr GetFlgText;
         endif;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  GetFlgTrn  Get lowest flag for transaction
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr GetFlgTrn;

         $ocfcod = ' ';
         $ocfflg = ' ';
         $pmessage = ' ';
         $rtnshort = ' ';

         setll ($ocwhse: $octran) ordcflg1;
         reade(n) ($ocwhse: $octran) ordcflg1;

         if not %eof(ordcflg1);
           $ocfcod = ocfcod;
           $ocfflg = ocfflg;
           exsr GetFlgText;
         endif;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  GetFlgWgt  Get lowest flag for individual weight
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr GetFlgWgt;

         $ocfcod = ' ';
         $ocfflg = ' ';
         $pmessage = ' ';
         $rtnshort = ' ';

         setll ($ocwhse: $oclbl#: $ocord: $ocseq#: $ocitem: $ocseq) ordcflg3;
         reade(n) ($ocwhse: $oclbl#: $ocord: $ocseq#: $ocitem: $ocseq) ordcflg3;

         if not %eof(ordcflg3);
           $ocfcod = ocfcod;
           $ocfflg = ocfflg;
           exsr GetFlgText;
         endif;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  GetFlgText   Get text for flag
650aA*
650aA*    Flags
650aA*      1=Error
650aA*      2=Warning needing override
650aA*      3=Overridden warning
650aA*
650aA*   Note, some flag codes should always be hard errors, such
650aA*   as code 03 - Extra weights. However, all flags are checked
650aA*   for consistency and the possibility that a client wants to
650aA*   allow for a warning.
650aA*
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr GetFlgText;

         select;
           when $ocfcod = '01';
             select;
               when $ocfflg = '1';
                 $pmessage = 'Error: No weights entered';
                 $rtnshort = 'No Wgts';
               when $ocfflg = '2';
                 $pmessage = 'Warning: No weights entered';
                 $rtnshort = 'No Wgts';
               when $ocfflg = '3';
                 $pmessage = 'Overriden: No weights entered';
                 $rtnshort = 'No Wgts';
             endsl;

           when $ocfcod = '02';
             select;
               when $ocfflg = '1';
                 $pmessage = 'Error: Missing weights';
                 $rtnshort = 'Miss Wgts';
               when $ocfflg = '2';
                 $pmessage = 'Warning: Missing weights';
                 $rtnshort = 'Miss Wgts';
               when $ocfflg = '3';
                 $pmessage = 'Overriden: Missing weights';
                 $rtnshort = 'Miss Wgts';
             endsl;

           when $ocfcod = '03';
             select;
               when $ocfflg = '1';
                 $pmessage = 'Error: Extra weights';
                 $rtnshort = 'Extra Wgts';
               when $ocfflg = '2';
                 $pmessage = 'Warning: Extra weights';
                 $rtnshort = 'Extra Wgts';
               when $ocfflg = '3';
                 $pmessage = 'Overriden: Extra weights';
                 $rtnshort = 'Extra Wgts';
             endsl;

           when $ocfcod = '04';
             select;
               when $ocfflg = '1';
                 $pmessage = 'Error: Total weight out of range';
                 $rtnshort = 'Ttl Range';
               when $ocfflg = '2';
                 $pmessage = 'Warning: Total weight out of range';
                 $rtnshort = 'Ttl Range';
               when $ocfflg = '3';
                 $pmessage = 'Overriden: Total weight out of range';
                 $rtnshort = 'Ttl Range';
             endsl;

           when $ocfcod = '05';
             select;
               when $ocfflg = '1';
                 $pmessage = 'Error: Weight out of range';
                 $rtnshort = 'Wgt Range';
               when $ocfflg = '2';
                 $pmessage = 'Warning: Weight out of range';
                 $rtnshort= 'Wgt Range';
               when $ocfflg = '3';
                 $pmessage = 'Overriden: Weight out of range';
                 $rtnshort = 'Wgt Range';
             endsl;

           when $ocfcod = '06';
             select;
               when $ocfflg = '1';
                 $pmessage = 'Error: Individual weight is zero';
                 $rtnshort = 'Zero Wgt';
               when $ocfflg = '2';
                 $pmessage = 'Warning: Individual weight is zero';
                 $rtnshort = 'Zero Wgt';
               when $ocfflg = '3';
                 $pmessage = 'Overriden: Individual weight is zero';
                 $rtnshort = 'Zero Wgt';
             endsl;

           when $ocfcod = '07';
             select;
               when $ocfflg = '1';
                 $pmessage = 'Error: Individual weight is less than zero';
                 $rtnshort = 'Neg Wgt';
               when $ocfflg = '2';
                 $pmessage = 'Warning: Individual weight is less than zero';
                 $rtnshort = 'Neg Wgt';
               when $ocfflg = '3';
                 $pmessage = 'Overriden: Individual weight is less than zero';
                 $rtnshort = 'Neg Wgt';
             endsl;

           when $ocfcod = '51';
             $pmessage = 'Error: Tfr wgt cannot be greater than 999,999';
             $rtnshort = 'Tfr>999999';

           when $ocfcod = '99';
             $pmessage = 'No errors or warnings';
             $rtnshort = 'No Err/Wrn';

           other;
             $pmessage = 'Code ' + $ocfcod + ' flag ' + $ocfflg;
             $rtnshort = 'Unkwn ' + $ocfcod + '/' + $ocfflg;

         endsl;

       endsr;
      /end-free

650a *----------------------------------------------------------------
650a *  GetLblCnt  Get label count flag
650a *----------------------------------------------------------------
650a
650aA /free
650aA  begsr GetLblCnt;

         $ocfcod = ' ';
         $ocfflg = ' ';
         $pmessage = ' ';
         $rtnshort = ' ';

         setll ($ocwhse: $oclbl#) ordcflg3;

         dow forever = forever;

           reade(n) ($ocwhse: $oclbl#) ordcflg3;

           if %eof(ordcflg3);
             leave;
           endif;

           // Only want label level flags

           if ocford <> 0;
             leave;
           endif;

           // Only want label count flags

           if ocfcod <> '01'
             and ocfcod <> '02'
             and ocfcod <> '03';
               iter;
           endif;

           // Found one, save and get out.

           $ocfcod = ocfcod;
           $ocfflg = ocfflg;
           exsr GetFlgText;

           leave;

         enddo;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  GetLblVar  Get label variance flag
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr GetLblVar;

         $ocfcod = ' ';
         $ocfflg = ' ';
         $pmessage = ' ';
         $rtnshort = ' ';

         setll ($ocwhse: $oclbl#) ordcflg3;

         dow forever = forever;

           reade(n) ($ocwhse: $oclbl#) ordcflg3;

           if %eof(ordcflg3);
             leave;
           endif;

           // Only want label level flags

           if ocford <> 0;
             leave;
           endif;

           // Only want label count flags

           if ocfcod <> '04';
             iter;
           endif;

           // Found one, save and get out.

           $ocfcod = ocfcod;
           $ocfflg = ocfflg;
           exsr GetFlgText;

           leave;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  inzchkflds  Initialize check fields.
     *----------------------------------------------------------------

      /free
       begsr inzchkflds;

         $ocwhsee = $driok;
         $ocorde  = $driok;
         $ocseq#e = $driok;
         $ociteme = $driok;
         $octrane = $driok;
         $oclbl#e = $driok;
         $ocseqe  = $driok;
650aA    $ocfflge = $driok;
650aA    $ocfcode = $driok;

         // Do not clear the weight error field because a weight
         // override value can be sent in.
         //$occwgte = $driok;

       endsr;
      /end-free

650a *----------------------------------------------------------------
650a *  OverrideLblCnt  Override label count flag
650a *----------------------------------------------------------------
650a
650aA /free
650aA  begsr OverrideLblCnt;

         setll ($ocwhse: $oclbl#) ordcflg3;

         dow forever = forever;

           reade ($ocwhse: $oclbl#) ordcflg3;

           if %eof(ordcflg3);
             leave;
           endif;

           // Only want label level flags

           if ocford <> 0;
             unlock ordcflg3;
             leave;
           endif;

           // Only want label count flags

           if ocfcod <> '01'
             and ocfcod <> '02'
             and ocfcod <> '03';
               iter;
           endif;

           // Found one, override it

           ocfflg = '3';
           update ocfrec3;

           // Retrieve message text

           $ocfflg = '3';
           $ocfcod = ocfcod;
           exsr GetFlgText;

           // Retrieve message text

           $ocfcod = ocfcod;
           exsr GetFlgText;

         enddo;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  OverrideLblVar  Override label variance flag
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr OverrideLblVar;

         setll ($ocwhse: $oclbl#) ordcflg3;

         dow forever = forever;

           reade ($ocwhse: $oclbl#) ordcflg3;

           if %eof(ordcflg3);
             leave;
           endif;

           // Only want label level flags

           if ocford <> 0;
             unlock ordcflg3;
             leave;
           endif;

           // Only want label count flags

           if ocfcod <> '04';
             iter;
           endif;

           // Found one, override it.

           ocfflg = '3';
           update ocfrec3;

           // Retrieve message text

           $ocfflg = '3';
           $ocfcod = ocfcod;
           exsr GetFlgText;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  VerifyAdd   Verification for *ADD
     *----------------------------------------------------------------

      /free
       begsr VerifyAdd;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyOrdSent;
         if error;
           leavesr;
         endif;

         exsr vfySeq#Sent;
         if error;
           leavesr;
         endif;

         exsr vfyItemSent;
         if error;
           leavesr;
         endif;

         exsr vfyTranSent;
         if error;
           leavesr;
         endif;

         exsr vfyLbl#Sent;
         if error;
           leavesr;
         endif;

         exsr vfySeqSent;
         if error;
           leavesr;
         endif;

         exsr vfyCWgtSent;
         if error;
           leavesr;
         endif;

         // Label record must exist

         chain ($oclbl#) label;

         if not %found;
           error = *on;
           $oclbl#e = $drierror;
           $preturn  = 'INVLDLBL';
           $pmessage = 'Label record not found ('
                       + %trim(%editc($oclbl#: 'Z'))
                       + ')';
           leavesr;
         endif;

         // Label warehouse must match sent warehouse

         if lbwhse <> $ocwhse;
           error = *on;
           $ocwhsee = $drierror;
           $preturn  = 'WHSMISMTCH';
           $pmessage = 'Sent warehouse ('
                       + %trim(%char($ocwhse))
                       + ') does not match label warehouse ('
                       + %trim(%char(lbwhse))
                       + ')';
           leavesr;
         endif;

         // Label order id must match sent order id

         if lbord <> $ocord;
           error = *on;
           $ocorde  = $drierror;
           $preturn  = 'ORDMISMTCH';
           $pmessage = 'Sent order id ('
                       + %trim(%char($ocord))
                       + ') does not match label order id ('
                       + %trim(%char(lbord))
                       + ')';
           leavesr;
         endif;

         // Label order seq# must match sent order seq#

         if lbseq <> $ocseq#;
           error = *on;
           $ocseq#e = $drierror;
           $preturn  = 'SEQMISMTCH';
           $pmessage = 'Sent ord seq# ('
                       + %trim(%char($ocseq#))
                       + ') does not match label ord seq# ('
                       + %trim(%char(lbseq))
                       + ')';
           leavesr;
         endif;

         // Label item must match sent item

         if lbitem <> $ocitem;
           error = *on;
           $ociteme = $drierror;
           $preturn  = 'ITMMISMTCH';
           $pmessage = 'Sent item ('
                       + %trim($ocitem)
                       + ') does not match label item ('
                       + %trim(lbitem)
                       + ')';
           leavesr;
         endif;

         // Call weight flag verification

         curwhse = $ocwhse;
         curtrn = $octran;
         curlbl = $oclbl#;
         curord = $ocord;
         curosq = $ocseq#;
         curitem = $ocitem;
         curwsq = $ocseq;
         weight = $occwgt;

         if $occwgte = $driwarnovr;
           warningFlag = '3';
         else;
           warningFlag = '2';
         endif;

         wrtFlag = *off;
         exsr VfyWeight;

         // If a warning was found that needs an override,
         // Then set on error flag so we return to caller

         if $ocfflg = '2';
           error = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  VerifyChg   Verification for *CHANGE
     *----------------------------------------------------------------

      /free
       begsr VerifyChg;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyLbl#Sent;
         if error;
           leavesr;
         endif;

         exsr vfySeqSent;
         if error;
           leavesr;
         endif;

         exsr vfyCWgtSent;
         if error;
           leavesr;
         endif;

         // ORDC record must exist

         chain ($ocwhse: $oclbl#: $ocseq) ordc1;

         if not %found;
           error = *on;
           $oclbl#e = $drierror;
           $preturn  = 'RECNOTFND';
           $pmessage = 'ORDC1 record not found ('
                       + %trim(%char($ocwhse))
                       + '/'
                       + %trim(%char($oclbl#))
                       + ')';
           leavesr;
         endif;

         // Label record must exist

         chain (oclbl#) label;

         if not %found;
           error = *on;
           $oclbl#e = $drierror;
           $preturn  = 'INVLDLBL';
           $pmessage = 'Label record not found ('
                       + %trim(%editc($oclbl#: 'Z'))
                       + ')';
           leavesr;
         endif;

         // Do verifications while creating flag records

         curwhse = $ocwhse;
         curtrn = $octran;
         curlbl = $oclbl#;
         curord = $ocord;
         curosq = $ocseq#;
         curitem = $ocitem;
         curwsq = $ocseq;
         weight = $occwgt;

         if $occwgte = $driwarnovr;
           warningFlag = '3';
         else;
           warningFlag = '2';
         endif;

         wrtFlag = *off;
         exsr VfyWeight;

         // If a warning was found that needs an override,
         // Then set on error flag so we return to caller

         if $ocfflg = '2';
           error = *on;
         endif;

         // If error, unlock ordc record

         if error;
           unlock ordc1;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  VerifyDel   Verification for *DELETE
     *----------------------------------------------------------------

      /free
       begsr VerifyDel;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyLbl#Sent;
         if error;
           leavesr;
         endif;

         exsr vfySeqSent;
         if error;
           leavesr;
         endif;

         // ORDC record must exist

         chain ($ocwhse: $oclbl#: $ocseq) ordc1;

         if not %found;
           error = *on;
           $oclbl#e = $drierror;
           $preturn  = 'RECNOTFND';
           $pmessage = 'ORDC1 record not found ('
                       + %trim(%char($ocwhse))
                       + '/'
                       + %trim(%char($oclbl#))
                       + ')';
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  VerifyGetLbl   Verification for *GETFLGLBL, *GETLBLCNT, *GETLBLVAR
     *----------------------------------------------------------------

      /free
       begsr VerifyGetLbl;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyLbl#Sent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  VerifyGetTrn   Verification for *GETFLGRTN
     *----------------------------------------------------------------

      /free
       begsr VerifyGetTrn;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyTranSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  VerifyGetWgt   Verification for *GETFLGWGT
     *----------------------------------------------------------------

      /free
       begsr VerifyGetWgt;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyOrdSent;
         if error;
           leavesr;
         endif;

         exsr vfySeq#Sent;
         if error;
           leavesr;
         endif;

         exsr vfyItemSent;
         if error;
           leavesr;
         endif;

         exsr vfyLbl#Sent;
         if error;
           leavesr;
         endif;

         exsr vfySeqSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  VerifyOvrLbl   Verification for *OVRLBLCNT and *OVRLBLVAR
     *----------------------------------------------------------------

      /free
       begsr VerifyOvrLbl;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyLbl#Sent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Flag Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

650aA*----------------------------------------------------------------
650aA*  VfyLabel   Do label checks
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr VfyLabel;

         error = *off;
         warn = *off;

         $ocfcod = ' ';
         $ocfflg = ' ';
         $pmessage = ' ';
         $rtnshort = ' ';

         // Get label record

         chain (curlbl) label;

         if not %found;
           lbqpck = 0;
         endif;

         // Clear existing label flags

         if wrtFlag;

           setll (curwhse: curlbl) ordcflg3;

           dow forever = forever;

             reade (curwhse: curlbl) ordcflg3;
             if %eof(ordcflg3);
               leave;
             endif;

             // Only want label level flags

             if ocford <> 0;
               leave;
             endif;

             // Delete flag

             delete(e) ocfrec3;

           enddo;

         endif;

         // First do count check

         exsr  VfyLblCount;

         // If weights exist and there are not too many
         // and picked qty > 0,
         // Then do variance check.

         if $ocfcod <> '01' and $ocfcod <> '03'
          and lbqpck > 0;
            exsr  VfyLblVar;
         endif;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  VfyLblCount  Do label count check
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr VfyLblCount;

         $ocfcod = ' ';

         // Count weights for label

         wgtCount = 0;
         ttlWgt = 0;

         setll (curwhse: curlbl) ordc1;

         dow forever = forever;

           reade (curwhse: curlbl) ordc1;
           if %eof(ordc1);
             leave;
           endif;

           wgtCount += 1;
           ttlWgt += occwgt;

         enddo;

         // Error if Picked > 0 and no weights found

         if lbqpck > 0 and wgtCount = 0;

           error = *on;
           $preturn = 'NOWGT';
           $ocfcod = '01';
           $ocfflg = '1';
           exsr GetFlgText;

           if wrtFlag;
             clear ocfrec;
             ocfwhs = curwhse;
             ocftrn = curtrn;
             ocflbl = curlbl;
             ocfcod = $ocfcod;
             ocfflg = $ocfflg;
             write(e) ocfrec;
           endif;

           leavesr;

         endif;

         // If count matches picked, we can get out.

         if wgtCount = lbqpck;
           leavesr;
         endif;

         // Error if count greater than picked qty

         if wgtCount > lbqpck;

           error = *on;
           $preturn = 'EXTRAWGT';
           $ocfcod = '03';
           $ocfflg = '1';
           exsr GetFlgText;

           if wrtFlag;
             clear ocfrec;
             ocfwhs = curwhse;
             ocftrn = curtrn;
             ocflbl = curlbl;
             ocfcod = $ocfcod;
             ocfflg = $ocfflg;
             write(e) ocfrec;
           endif;

           leavesr;

         endif;

         // Missing weights ...

         if opicwflag = 'Y';

           if warningFlag = '2';
             warn = *on;
             $preturn = 'MISSWGT';
           endif;
           $ocfcod = '02';
           $ocfflg = warningFlag;
           exsr GetFlgText;

           if wrtFlag;
             clear ocfrec;
             ocfwhs = curwhse;
             ocftrn = curtrn;
             ocflbl = curlbl;
             ocfcod = $ocfcod;
             ocfflg = $ocfflg;
             write(e) ocfrec;
           endif;

           leavesr;

         endif;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  VfyLblVar  Check label weight variance
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr VfyLblVar;

         // Label information was retrieved in VfyLblCount

         // Skip if system option not set
         // Skip for Nicholas

         if opwrncflag <> 'Y'
           or client = nicholas;
             leavesr;
         endif;

         // Check total catch weight against variance

           curord = ocord;
           curosq = ocseq#;
           curitem = ocitem;
           curwsq = ocseq;
           pieces = lbqpck;
           exsr CalcVariance;

           // Check low range

           if not lvskp and ttlWgt < ilrng;

             if warningFlag = '2';
               warn = *on;
               $preturn = 'LOWTTLVAR';
             endif;
             $ocfcod = '04';
             $ocfflg = warningFlag;
             exsr GetFlgText;
             $pmessage = %trimr($pmessage) + ' ' + rngText;

             if wrtFlag;
               clear ocfrec;
               ocfwhs = curwhse;
               ocftrn = curtrn;
               ocflbl = curlbl;
               ocfwgt = ttlWgt;
               ocfcod = $ocfcod;
               ocfflg = $ocfflg;
               write(e) ocfrec;
             endif;

             leavesr;

           endif;

           // Check high range

           if not hvskp and ttlWgt > ihrng;

             if warningFlag = '2';
               warn = *on;
               $preturn = 'HITTLVAR';
             endif;
             $ocfcod = '04';
             $ocfflg = warningFlag;
             exsr GetFlgText;
             $pmessage = %trimr($pmessage) + ' ' + rngText;

             if wrtFlag;
               clear ocfrec;
               ocfwhs = curwhse;
               ocftrn = curtrn;
               ocflbl = curlbl;
               ocfwgt = ttlWgt;
               ocfcod = $ocfcod;
               ocfflg = $ocfflg;
               write(e) ocfrec;
             endif;

             leavesr;

           endif;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  VfyWeight  Do individual weight checks (based on code from CW112)
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr VfyWeight;

         error = *off;
         warn = *off;

         $ocfcod = ' ';
         $ocfflg = ' ';
         $pmessage = ' ';
         $rtnshort = ' ';

         // Clear existing individual weight flags

         if wrtFlag;

           setll (curwhse: curlbl: curord: curosq: curitem: curwsq) ordcflg3;

           dow forever = forever;

             reade (curwhse: curlbl: curord: curosq: curitem: curwsq) ordcflg3;
             if %eof(ordcflg3);
               leave;
             endif;

             delete(e) ocfrec3;

           enddo;

         endif;

         // Error - Weight cannot be zero

         if weight = 0;

           error = *on;
           $preturn = 'ZEROWGT';
           $ocfcod = '06';
           $ocfflg = '1';
           exsr GetFlgText;

           if wrtFlag;
             clear ocfrec;
             ocfwhs = curwhse;
             ocftrn = curtrn;
             ocflbl = curlbl;
             ocford = curord;
             ocfosq = curosq;
             ocfitm = curitem;
             ocfwsq = curwsq;
             ocfcod = $ocfcod;
             ocfflg = $ocfflg;
             write(e) ocfrec;
           endif;

           leavesr;

         endif;

         // Error - Weight cannot be less than zero

         if weight < 0;

           error = *on;
           $preturn = 'NEGWGT';
           $ocfcod = '07';
           $ocfflg = '1';
           exsr GetFlgText;

           if wrtFlag;
             clear ocfrec;
             ocfwhs = curwhse;
             ocftrn = curtrn;
             ocflbl = curlbl;
             ocford = curord;
             ocfosq = curosq;
             ocfitm = curitem;
             ocfwsq = curwsq;
             ocfwgt = weight;
             ocfcod = $ocfcod;
             ocfflg = $ocfflg;
             write(e) ocfrec;
           endif;

           leavesr;

         endif;

         // Error - Glazier tfr cannot be greater than 999,999

         if client = glazier
           and tfrorder = '*YES'
           and weight > 999999;

           error = *on;
           $preturn = 'GT999999';
           $ocfcod = '51';
           $ocfflg = '1';
           exsr GetFlgText;

           if wrtFlag;
             clear ocfrec;
             ocfwhs = curwhse;
             ocftrn = curtrn;
             ocflbl = curlbl;
             ocford = curord;
             ocfosq = curosq;
             ocfitm = curitem;
             ocfwsq = curwsq;
             ocfwgt = weight;
             ocfcod = $ocfcod;
             ocfflg = $ocfflg;
             write(e) ocfrec;
           endif;

           leavesr;

         endif;

         // Warning - Weight greater than 9,999,999

         if weight > 9999999;

           if warningFlag = '2';
             warn = *on;
             $preturn = 'GT9999999';
           endif;
           $ocfcod = '08';
           $ocfflg = warningFlag;
           exsr GetFlgText;

           if wrtFlag;
             clear ocfrec;
             ocfwhs = curwhse;
             ocftrn = curtrn;
             ocflbl = curlbl;
             ocford = curord;
             ocfosq = curosq;
             ocfitm = curitem;
             ocfwsq = curwsq;
             ocfwgt = weight;
             ocfcod = $ocfcod;
             ocfflg = $ocfflg;
             write(e) ocfrec;
           endif;

           leavesr;

         endif;

         // Warning - Weight out of variance range

         if opwrncflag = 'Y';

           // Calculate variances

           pieces = 1;
           exsr CalcVariance;

           // Check low range

           if not lvskp and weight < ilrng;

             if warningFlag = '2';
               warn = *on;
               $preturn = 'LOWVAR';
             endif;
             $ocfcod = '05';
             $ocfflg = warningFlag;
             exsr GetFlgText;
             $pmessage = %trimr($pmessage) + ' ' + rngText;

             if wrtFlag;
               clear ocfrec;
               ocfwhs = curwhse;
               ocftrn = curtrn;
               ocflbl = curlbl;
               ocford = curord;
               ocfosq = curosq;
               ocfitm = curitem;
               ocfwsq = curwsq;
               ocfwgt = weight;
               ocfcod = $ocfcod;
               ocfflg = $ocfflg;
               select;
                 when lvskp and hvskp;
                   ocflrg = 0;
                   ocfhrg = 0;
                 when lvskp;
                   ocflrg = 0;
                   ocfhrg = ihrng;
                 when hvskp;
                   ocflrg = ilrng;
                   ocfhrg = 0;
                 other;
                   ocflrg = ilrng;
                   ocfhrg = ihrng;
               endsl;
               write(e) ocfrec;
             endif;

             leavesr;

           endif;

           // Check high range

           if not hvskp and weight > ihrng;

             if warningFlag = '2';
               warn = *on;
               $preturn = 'HIVAR';
             endif;
             $ocfcod = '05';
             $ocfflg = warningFlag;
             exsr GetFlgText;
             $pmessage = %trimr($pmessage) + ' ' + rngText;

             if wrtFlag;
               clear ocfrec;
               ocfwhs = curwhse;
               ocftrn = curtrn;
               ocflbl = curlbl;
               ocford = curord;
               ocfosq = curosq;
               ocfitm = curitem;
               ocfwsq = curwsq;
               ocfwgt = weight;
               ocfcod = $ocfcod;
               ocfflg = $ocfflg;
               select;
                 when lvskp and hvskp;
                   ocflrg = 0;
                   ocfhrg = 0;
                 when lvskp;
                   ocflrg = 0;
                   ocfhrg = ihrng;
                 when hvskp;
                   ocflrg = ilrng;
                   ocfhrg = 0;
                 other;
                   ocflrg = ilrng;
                   ocfhrg = ihrng;
               endsl;
               write(e) ocfrec;
             endif;

             leavesr;

           endif;

         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Sent Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  vfyCWgtSent  Verify that weight was sent
     *----------------------------------------------------------------

      /free
       begsr vfyCWgtSent;

         if not $occwgtu;
           error = *on;
           $occwgte = $drierror;
           $preturn  = 'CWGTNOTSNT';
           $pmessage = 'Weight must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyItemSent  Verify that Item was sent
     *----------------------------------------------------------------

      /free
       begsr vfyItemSent;

         if not $ocitemu;
           error = *on;
           $ociteme = $drierror;
           $preturn  = 'ITEMNOTSNT';
           $pmessage = 'Item must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyLbl#Sent  Verify that Label number was sent
     *----------------------------------------------------------------

      /free
       begsr vfyLbl#Sent;

         if not $oclbl#u;
           error = *on;
           $oclbl#e = $drierror;
           $preturn  = 'LBLNOTSNT';
           $pmessage = 'Label Number must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyOrdSent  Verify that Order Id was sent
     *----------------------------------------------------------------

      /free
       begsr vfyOrdSent;

         if not $ocordu;
           error = *on;
           $ocorde  = $drierror;
           $preturn  = 'ORDNOTSNT';
           $pmessage = 'Order Id must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfySeqSent  Verify that cw seq was sent
     *----------------------------------------------------------------

      /free
       begsr vfySeqSent;

         if not $ocsequ;
           error = *on;
           $ocseqe  = $drierror;
           $preturn  = 'CSEQNOTSNT';
           $pmessage = 'Catchweight Seq must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfySeq#Sent  Verify that order seq# was sent
     *----------------------------------------------------------------

      /free
       begsr vfySeq#Sent;

         if not $ocseq#u;
           error = *on;
           $ocseq#e = $drierror;
           $preturn  = 'OSEQNOTSNT';
           $pmessage = 'Order Seq# must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyTranSent  Verify that transaction was sent
     *----------------------------------------------------------------

      /free
       begsr vfyTranSent;

         if not $octranu;
           error = *on;
           $octrane = $drierror;
           $preturn  = 'TRANNOTSNT';
           $pmessage = 'Transaction must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyWhseSent  Verify that warehouse was sent
     *----------------------------------------------------------------

      /free
       begsr vfyWhseSent;

         if not $ocwhseu;
           error = *on;
           $ocwhsee = $drierror;
           $preturn  = 'WHSENOTSNT';
           $pmessage = 'Warehouse must be sent';
         endif;

       endsr;
      /end-free
