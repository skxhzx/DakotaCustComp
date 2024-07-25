      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2012 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------
      *
      *  R18200  Generate RMTOUTQ on create and perform other com
      *  21 MAR 2016
      *  Kenneth Elder
      *
      *  Revisions:
      *
      *    03/21/16  KDE  7.00
      *      - Created.
      *    03/29/16  KDE  7.00
      *      - Added files GLOUSRGRP and GLOUSRWTR to control whi
      *        writers should be displayed
      *    04/23/16  KDE  7.00a
      *      - Removed default of *ALL since ADMINS exist on WEB
      *        boxes and they would see everyones writers.
      *        This change also allows for someone to be defined
      *        as *ALL so they can see all writers by default
      *    04/23/16  KDE  7.00b
      *      - Setup loop to build queue from the possibility of
      *        multiple user queue selection records in GLOUSRWTR
      *    04/27/16  KDE  7.00c
      *      - Add code to move outq entries from one outq to
      *        another.  This allows the user to move to another
      *        printer when one fails
700dA *    07/21/16  DAS  7.00d
      *      - Revised to remove ADMIN check. Re: if a cloud user
      *        was defined as ADMIN he would see printers for
      *        all cloud clients.
710aA *    06/14/17  KDE  7.10a
      *      - Change ENDWTR to submit to batch and then check
      *        for status to end to return since OS7.1 and below
      *        is not working correctly by just executing command
      *      - Also added Restart option and eliminated Ping Option
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------

      *----------------------------------------------------------
      *  Parameters
      *----------------------------------------------------------

     D  pSessId        s             40    varying
     D  pUser          s             10    varying
     D  pPgm           s             20    varying
     D  pWhse          s              3p 0
     D  pCommand       s             15    varying
     D  pOutqLib       s             10    varying
     D  pOutq          s             10    varying
     D  pOutIP         s             15    varying
     D  pOutStr        s           1024    varying

     D  Session        s             40
     D  Cmd            s             15
     D  OutqLib        s             10
     D  Outq           s             10
     D  OutIP          s             15
      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------
     d admincnt        s              3  0
     d endFile         s             10
     d wrkcmd          s             13
     d pMessage        s             30
     d pResponse       s            100
     d SelectStmt      s            500
     d wrkoutqprt      s             10
     d wtrsts          s             10
710aAd cnt             s              2  0
      *----------------------------------------------------------
      *  Standard variables and constants
      *----------------------------------------------------------

      /copy qcopysrc,c#stdvar

     D Up              C                   CONST('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
     D Low             C                   CONST('abcdefghijklmnoPQRSTUVWXYZ')

      *----------------------------------------------------------
      *  Standard SQL variables and constants
      *----------------------------------------------------------

      /copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  Program info data structure
      *----------------------------------------------------------

      /copy qcopysrc,c#pgminfds

      *----------------------------------------------------------
      * Prototypes
      *----------------------------------------------------------

      /copy qcopysrc,p.wrtsessl

      /COPY *libl/qcopysrc,C#DRIPARMP

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)

     D NullString      C                   -1
     D Success         C                   0
     D WrtNotActive    C                   'CPF3313'
     D WrtCurActive    C                   'CPF3310'

     D Errmsgid        S              7    Import('_EXCP_MSGID')
     D Returncode      S             10I 0

710aA *  External procedure to return status of Outq
710aAD GetOutqSts      Pr                  ExtPgm('CHKWTRSTS')
710aAD  pOutqName                    20a
710aAD  pOutqStatus                  12

710aAD pOutqLibl       ds            20
710aAd  pOutqb                       10
710aAd  pOutqLibb                    10
710aAd pOutqSts        s             12

710aA *  Delay procedure to pause after command, to ensure completed
710aAD sleep           pr            10u 0 extproc('sleep')
710aAD   Interval                    10u 0 value

      *----------------------------------------------------------
      *  SPOOL FILE INPUT DATA STRUCTURE
      *----------------------------------------------------------
      *-
     D OUTQE           DS
     D  FILL0                         1A
     D  SPLFIL                       10A
     D  FILL1                         1A
     D  USER                         10A
     D  FILL2                         1A
     D  USRDTA                       10A
     D  FILL3                         2A
     D  STATUS                        5A
     D  FILL4                         1A
     D  PAGES                         5A
     D  FILL5                         1A
     D  COPIES                        5A
     D  FILL6                         2A
     D  FRMTYP                       10A
     D  FILL7                         1A
     D  PTY                           2A
     D  FILL8                         5A
     D  FILNUM                        6A
     D  FILL9                         5A
     D  JOB                          10A
     D  FILL10                        1A
     D  JOBNUM                        6A
     D  FILL11                       11A
     D  JOBDTE                        8A
     D  FILL12                       22A
      *----------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      pSessId     Session Id
      *      pUser       GUI User
      *      pPgm        GUI dictionary.program
      *      pWhse       Warehouse
      *      pCommand    Outq Command
      *      pOutqLib    Outq Library
      *      pOutq       Outq
      *      pOutIP      Outq IP address
      *
      *    Returned Parameters
      *      pMessage   Return error message
      *
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------
     C     *entry        plist
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pWhse
     c                   parm                    pCommand
     c                   parm                    pOutqLib
     c                   parm                    pOutq
     c                   parm                    pOutIP
     C                   parm                    pOutStr

      *----------------------------------------------------------
      *  Main line
      *----------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = '*OK';

         Session = pSessId;
         Cmd = pCommand;
         outqLib = poutqLib;
         outq = poutq;
         outip = poutip;

         select;
           // Creates records for given session id when screen is
           when pCommand = '*CREATE';
             exsr dltRecords;
             exsr addRecords;
           when pCommand = '*RESTR';   // Restart Queue. Ends and Starts
             exsr endwtr;
             exsr strwtr;
             exsr dltRecords;  // Refresh Queue Records for Sessi
             exsr addRecords;
           when pCommand = '*ENDWTR';
             exsr endwtr;
             exsr dltRecords;  // Refresh Queue Records for Sessi
             exsr addRecords;
           when pCommand = '*STRWTR';
             exsr strwtr;
             exsr dltRecords;  // Refresh Queue Records for Sessi
             exsr addRecords;
           when pCommand = '*HLDWTR';
             exsr hldwtr;
             exsr dltRecords;  // Refresh Queue Records for Sessi
             exsr addRecords;
           when pCommand = '*RLSWTR';
             exsr rlswtr;
             exsr dltRecords;  // Refresh Queue Records for Sessi
             exsr addRecords;
           when pCommand = '*MOVWTR'
                 or pCommand = '*MOVCHK';
             exsr movwtr;
             exsr dltRecords;  // Refresh Queue Records for Sessi
             exsr addRecords;
           when pCommand = '*PING';
             exsr pingwtr;
           other;
        endsl;

        pOutStr = '{'
          +  '"pwhse":"'  + %trim(%char(pWhse)) + '",'
          +  '"pSession":"'  + %trim(Session) + '",'
          +  '"pCommand":"'  + %trim(Cmd) + '",'
          +  '"poutqLib":"'  + %trim(outqlib) + '",'
          +  '"pOutq":"'  + %trim(Outq) + '",'
          +  '"poutIP":"'  + %trim(outIP) + '",'
          +  '"pResponse":"'  + %trim(pResponse) + '",'
          +  '"pMessage":"'  + %trim(pMessage) + '"}';

         return;
      /end-free

      *----------------------------------------------------------
      *  *PSSR  Unexpected error handler
      *----------------------------------------------------------

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
         pOutStr = '{'
                   +  '"pWhse":"'  + %trim(%char(pWhse)) + '",'
                   +  '"pMessage":"'  + %trim(pMessage) + '"}';
         *inlr = *on;
         return;

       endsr;
      /end-free

      *----------------------------------------------------------
      *  addRecords  Add records to RMTOUTQ for given session
      *----------------------------------------------------------

      /free
       begsr addRecords;

         outFile = *blanks;
         outFile = 'RMTOUTQ   QGPL   ';

700dD          // set the outq selection based on whether ADMIN
700dD          // or if specific outq selection configured
700dD          //exec sql
700dD          //     select count(*) into :admincnt
700dD          //            from glousrgrp
700dD          //            where guguser = :pUser and
700dD          //                  guggroup = 'ADMIN';
700dD          //
700dD          //          if sqlstt = '00000' and admincnt > 0;
700dD          //             outqs = '*ALL';
700dD          //          else;

700dM    // Select outq's based on glousrwtr entries

         exec sql declare UsrWtr Cursor for
           select uwoutqs
             from glousrwtr
            where uwuser = :pUser;
         exec sql open UsrWtr;
         exec sql fetch UsrWtr into :outqs;

700dD          //          endif;

         dow sqlstt = '00000';

      /end-free
     c                   call      'RMTOUTQR2M'
     c                   parm                    outqs            10
     c                   parm      '*ALL'        libs             10
     c                   parm      '*FILE'       outtype           5
     c                   parm                    outFile          20
     c                   parm      '*ADD'        FileOpt           8
     c                   parm                    Session
      /free

           exec sql fetch UsrWtr into :outqs;

         enddo;

710aD    // exec sql open UsrWtr;
710aA    exec sql close UsrWtr;

       endsr;
      /end-free

      *----------------------------------------------------------
      *  dltRecords  Delete records for this Session if exists
      *----------------------------------------------------------

      /free

       begsr dltRecords;

             if pCommand <> '*CREATE';
                // pause to make sure fiel is not recreated prior
                // to writer being completely ended or started
                Returncode = Gocmd('DLYJOB DLY(2)');
             endif;
             exec sql delete from QGPL/RMTOUTQ
                  where Session = :Session;
       endsr;

      /end-free
      *----------------------------------------------------------
      *  EndWtr   End Writer
      *----------------------------------------------------------

      /free

       begsr EndWtr;

710aA     // Make sure writer is not already stopped before trying to end
710aA     if pCommand <> '*RESTR';
710aA        pOutqLibb = pOutqlib;
710aA        pOutqb = pOutq;
710aA        pOutqSts = *blanks;
710aA        GetOutqSts (pOutqLibl:pOutqSts);
710aA        if pOutqSts = 'STOPPED';
710aA           pResponse = 'Writer ' +
710aA                      %trim(pOutqLib) + '/' +
710aA                      %trim(pOutq) + ' is already ended';
710aA           leavesr;
710aA        endif;
710aA     endif;
710aA     // Submit End writer since IBM does not support ending a
710aA     // writer from multi-thread job such as QZDA jobs MRC runs
710aA     Returncode = Gocmd('SBMJOB CMD(ENDWTR WTR(' + %trim(pOutq) +
710aA                  ') OPTION(*IMMED))');

          select;
             when
             Returncode = Success;
710aA           // since submit job was done we will loop until writer
710aA           // shows it has ended or 20 seconds have passed
710aA           // do up to 20 times looking for writer status to end
710aA           for cnt = 1 to 20;
710aA              sleep(1);   // pause 1 second
710aA              pOutqLibb = pOutqlib;
710aA              pOutqb = pOutq;
710aA              pOutqSts = *blanks;
710aA              GetOutqSts (pOutqLibl:pOutqSts);
710aA              if pOutqSts = 'STOPPED';
710aA                 cnt = 1;
710aA                 leave;
710aA              endif;
710aA           endfor;
710aA           if pCommand <> '*RESTR';
710aA              if cnt = 1;
                      pResponse = 'Writer ' + %trim(pOutqLib) + '/' +
                                  %trim(pOutq) + ' was ended ' +
                                  'successfully';
710aA              else;
710aA                 pResponse = 'Endwtr command for writer ' +
710aA                             %trim(pOutqLib) + '/' +
710aA                              %trim(pOutq) + ' failed';
710aA              endif;
710aA           endif;
             when
710aA        // would only execute if original submit endwtr failed
             Returncode = Null;
                pResponse = 'Improper Command was sent';
                pMessage = '*NO';
             When Errmsgid = WrtNotActive;     // CPF3313
                pResponse = 'Writer ' + %trim(pOutqLib) + '/' +
                            %trim(pOutq) + ' not active ' +
                            'nor on jobq';
             Other;
710aA          // would only execute if original submit endwtr failed
                pResponse = 'Endwtr command for writer ' +
                            %trim(pOutqLib) + '/' +
                            %trim(pOutq) + ' failed';
                pMessage = '*NO';
           endsl;

       endsr;
       /end-free

      *----------------------------------------------------------
      *  StrWtr   Start Writer
      *----------------------------------------------------------

      /free
        begsr StrWtr;

          Returncode = Gocmd('STRRMTWTR OUTQ(' + %trim(pOutqLib) +
                         '/' + %trim(pOutq) + ')');

          select;
             when
             Returncode = Success;
710aA           if pCommand <> '*RESTR';
                   pResponse = 'Writer ' + %trim(pOutqLib) + '/' +
                               %trim(pOutq) + ' was started ' +
                               'successfully';
710aA           else;
710aA              pResponse = 'Writer ' + %trim(pOutqLib) + '/' +
710aA                          %trim(pOutq) + ' was re-started ' +
710aA                          'successfully';
710aA           endif;
             when
             Returncode = Null;
                pResponse = 'Improper Command was sent';
                pMessage = '*NO';
             When Errmsgid = WrtCurActive;     // CPF3310
                pResponse = 'Writer ' + %trim(pOutqLib) + '/' +
                             %trim(pOutq) + ' already ' +
                             'started';
              Other;
                 pResponse = 'Start command for writer ' +
                            %trim(pOutqLib) + '/' +
                            %trim(pOutq) + ' failed';
                pMessage = '*NO';
           endsl;

       endsr;

       /end-free

      *----------------------------------------------------------
      *  PingWtr  Ping Writer
      *----------------------------------------------------------

      /free
       begsr PingWtr;

          Returncode = Gocmd('PING RMTSYS(' + sq + %trim(pOutIP) +
                        sq + ')');

          select;
             when
             Returncode = Success;
                pResponse = 'Writer ' + %trim(pOutqLib) + '/' +
                            %trim(pOutq) + ' pinged ' +
                            'successfully';
             when
             Returncode = Null;
                pResponse = 'Improper Command was sent';
                pMessage = '*NO';
             Other;
                pResponse = 'Ping command for writer ' +
                            %trim(pOutqLib) + '/' +
                            %trim(pOutq) + ' failed';
                pMessage = '*NO';
           endsl;

       endsr;
      /end-free

      *----------------------------------------------------------
      *  HldWtr   Hold Writer
      *----------------------------------------------------------

      /free
       begsr HldWtr;

          Returncode = Gocmd('HLDOUTQ OUTQ(' + %trim(pOutq) + ')');
          select;
             when
             Returncode = Success;
                pResponse = 'Outq ' + %trim(pOutqLib) + '/' +
                            %trim(pOutq) + ' was held ' +
                            'successfully';
             when
             Returncode = Null;
                pResponse = 'Improper Command was sent';
                pMessage = '*NO';
             Other;
                pResponse = 'HLDOUTQ command for writer ' +
                            %trim(pOutqLib) + '/' +
                            %trim(pOutq) + ' failed';
                pMessage = '*NO';
           endsl;

       endsr;
       /end-free

      *----------------------------------------------------------
      *  RlsWtr   Release Writer
      *----------------------------------------------------------

      /free

       begsr RlsWtr;
          Returncode = Gocmd('RLSOUTQ OUTQ(' + %trim(pOutq) + ')');
          select;
             when
             Returncode = Success;
                pResponse = 'Outq ' + %trim(pOutqLib) + '/' +
                            %trim(pOutq) + ' was released ' +
                            'successfully';
             when
             Returncode = Null;
                pResponse = 'Improper Command was sent';
                pMessage = '*NO';
             Other;
                pResponse = 'RLSOUTQ command for writer ' +
                            %trim(pOutqLib) + '/' +
                            %trim(pOutq) + ' failed';
                pMessage = '*NO';
           endsl;

       endsr;
       /end-free

      *----------------------------------------------------------
      *  MovWtr   Move Spool entries from one Queue to Another
      *----------------------------------------------------------

      /free

       begsr MovWtr;

          // check to make sure writer is ended when selecting
          // from I148xx, otherwise return with error that
          // writer should first be ended
          if pCommand = '*MOVCHK';
             exec sql select wtrsts into :wtrsts
                 from rmtoutq where session = :psessid
                      and outq = :poutq;
             if wtrsts = 'STR';
                pResponse = 'Writer (' + %trim(poutq) + ')' +
                            ' must be ended prior to moving' +
                            ' spool entries to another writer';
                pMessage = '*NO';
             else;
                pResponse = *blanks;
             endif;
             leavesr;
          endif;

          // delete Work File if it exist
          wrkoutqprt = 'WQ' + %char(%time():*hms0);
          endfile = 'SQ' + %char(%time():*hms0);
          Returncode = Gocmd('DLTF FILE(QGPL/' +
                        %trim(wrkoutqprt) + ')');
          Returncode = Gocmd('DLTF FILE(QGPL/' +
                        %trim(endfile) + ')');

          // Create work file for Outq output to analyze
          Returncode = Gocmd('CRTDUPOBJ OBJ(WRKOUTQPRT) ' +
                        'FROMLIB(*LIBL) OBJTYPE(*FILE) ' +
                        'TOLIB(QGPL) NEWOBJ(' +
                        %trim(wrkoutqprt) + ')');
          Returncode = Gocmd('CRTDUPOBJ OBJ(WRKOUTQPRT) ' +
                        'FROMLIB(*LIBL) OBJTYPE(*FILE) ' +
                        'TOLIB(QGPL) NEWOBJ(' +
                        %trim(endfile) + ')');

          // call CL to move spool entries from one queue to
          // another queue.  Submit to normal subsystem
          Returncode = Gocmd('SBMJOB CMD(CALL PGM(' +
                        'WRKOUTQPRT) PARM(' + sq +
                        '*LIBL' + sq + ' ' + sq +
                        %trim(poutip) + sq + ' ' + sq +
                        %trim(poutqlib) + sq + ' ' +
                        sq + %trim(poutq) + sq + ' ' +
                        sq + %trim(wrkoutqprt) + sq + ' ' +
                        sq + %trim(endfile) + sq + '))');
                pResponse = 'Ready status entries moved from ' +
                            'writer (' + %trim(poutip) + ') to ' +
                            'writer (' + %trim(poutq) + ')';
                pMessage = '*NO';

            // Ensure submitted job completed before returning
            // We had to submit since the spool commands could
            // not be ran in multi threaded QZDASOINIT
            errmsgid = *blanks;
            dow errmsgid <> 'CPF9801';
               Returncode = Gocmd('DLYJOB DLY(1)');
               Returncode = Gocmd('CHKOBJ OBJ(QGPL/' +
                        %trim(endfile) + ') OBJTYPE(*FILE)');
            enddo;
      /end-free
     c                   endsr
