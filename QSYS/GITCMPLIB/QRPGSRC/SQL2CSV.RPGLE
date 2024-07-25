     H dftactgrp(*no) bnddir('QC2LE') debug
     H option(*srcstmt : *nodebugio)

      * Revisions
510aA *   03/23/07  DAS  5.10a
      *     - Revised to only put quotes around character fields.
      *     - Revised to add CR before LF for each line.
      *     - Revised to only use %trimr for character fields because
      *       it wasn't handling right justified fields correctly.

      *********************************************************************
      * SQL2CSVR - Create CSV from SQL
      *********************************************************************

      **------------------------------------------------------------------
      * SQL2CSV CMD PARAMETERS
      **------------------------------------------------------------------
     D EntryParms      PR                  extpgm('SQL2CSV')
     D  pSQLSTMT                   5000A
     D  pTOCSV                       63A
     D  pMODE                         8A
     D  pCOLHDRS                     10A
     D  pTITLE                      120A
     D  pNAMING                       4A
     D EntryParms      PI
     D  pSQLSTMT                   5000A
     D  pTOCSV                       63A
     D  pMODE                         8A
     D  pCOLHDRS                     10A
     D  pTITLE                      120A
     D  pNAMING                       4A

      *----------------------------------------------------------------
      * sql communication area
      *----------------------------------------------------------------
     D SQLCA           DS
     D  SQLCAID                       8
     D  SQLCABC                       9B 0
     D  SQLCODE                       9B 0
     D  SQLERRML                      4B 0
     D  SQLERRMC                     70
     D  SQLERRP                       8
     D  SQLERRD                      24
     D   SQLER1                       9B 0 Overlay(SQLERRD:1)
     D   SQLER2                       9B 0 Overlay(SQLERRD:5)
     D   SQLER3                       9B 0 Overlay(SQLERRD:9)
     D   SQLER4                       9B 0 Overlay(SQLERRD:13)
     D   SQLER5                       9B 0 Overlay(SQLERRD:17)
     D   SQLER6                       4a   Overlay(SQLERRD:21)
     D  SQLWARN                      11
     D  SQLSTATE                      5

      *----------------------------------------------------------------
      * sql descriptor area
      *----------------------------------------------------------------
     D SQLDA           DS                  based(pSQLDA)
     D  SQLDAID                       8A
     D  SQLDABC                       9B 0
     D  SQLN                          4B 0
     D  SQLD                          4B 0
     D  SQL_VAR                      80A   DIM(2)

     D SQLVAR          DS                  based(pSQLVAR)
     D  SQLTYPE                       4B 0
     D  SQLLEN                        4B 0
     D   Precision                    3I 0 overlay(SQLLEN)
     D   Scale                        3I 0 overlay(SQLLEN:*next)
     D  SQLRES                       12A
     D  SQLDATA                        *
     D  SQLIND                         *
     D  SQLNAMELEN                    4B 0
     D  SQLNAME                      30A

     D* SQLDA pointers
     D pSQLDA          s               *
     D pSQLVAR         s               *

     D* SQLDA sizes
     D nSQLDA          s              5i 0
     D szSQLDA         s             10i 0

     D* Column sizes
     D cSQLLEN         s              5i 0

     D* Record buffer
     D Record          s          32000

     D* CSV space
     d pSPCNAME        S               *
     d pCSV            S               *
     d lCSV            s             10i 0
     d CSV             s           1024    based(pCSV)
     d Number          s             33    based(pCSV)
     d SpcSize         s             10i 0
     d SpcAvail        s             10i 0
     d SpcUsed         s             10i 0
     d SpcMinimum      s             10i 0

     D* Miscellaneous
     D psqlL           s              5i 0
     D NullFields      s              5i 0 dim(1000)
     D c               s              5i 0
     D cn              s              5i 0
     D i               s              5i 0
     D j               s              5i 0
     D od              s              5i 0
     D on              s              5i 0
     D LF              c                   x'25'
     D CR              c                   x'0d'

      *----------------------------------------------------------------
   *  * QSQPRCED - process extended dynamic sql
      *----------------------------------------------------------------
     D QSQPRCED        PR                  extpgm('QSQPRCED')
     D  SQLCA                       136
     D  SQLDA                     32000    options(*varsize)
     D  sqformat                      8    const
     D  sqlp0100                   5096    options(*varsize)
     D  apierror                    120    options(*varsize)
     D** Function Template
     D sqlp0100        ds
     D  function                      1    inz('0')
     D  pkgname                      10    inz('SQLCSV')
     D  pkglib                       10    inz('QTEMP')
     D  mainpgm                      10    inz('SQL2CSV')
     D  mainlib                      10    inz('*LIBL')
     D  stmname                      18    inz('CSV')
     D  curname                      18    inz('CURSOR')
     D  openopt                       1    inz(x'00')
     D  claudesc                      1    inz('A')
     D  commit                        1    inz('N')
     D  datefmt                       3    inz('ISO')
     D  datesep                       1    inz('-')
     D  timefmt                       3    inz('ISO')
     D  timesep                       1    inz('.')
     D  namingopt                     3    inz('SYS')
     D  decpos                        1    inz('.')
     D  block                         4b 0 inz(0)
     D  SqlStmtl                      4b 0 inz(0)
     D  SqlStmt                    5000

     D sqformat        ds
     D  format                       10    inz('SQLP0100')

      *----------------------------------------------------------------
      * QUSROBJD - object description information
      *----------------------------------------------------------------
     D QUSROBJD        PR                  extpgm('QUSROBJD')
     D  objd_rcvr                   512    options(*varsize)
     D  objd_bytes                    9b 0 const
     D  objd_form                     8    const
     D  obj_name                     20    const
     D  objd_type                    10    const
     D  apierror                    120    options(*varsize)
     D** Object description
     D objd_rcvr       ds
     D  objd_bytes                    9b 0
     D  objd_avail                    9b 0
     D  objd_rlib                    10    overlay(objd_rcvr:39)
     D  objd_size                     9b 0 overlay(objd_rcvr:473)
     D  objd_name      s             20

      *----------------------------------------------------------------
      * QUSCRTUS/QUSPTRUS/QUSCUSAT - user space mgmt
      *----------------------------------------------------------------
     D QUSCRTUS        PR                  extpgm('QUSCRTUS')
     D  UserSpace                    20    const
     D  ExtendedAtr                  10    const
     D  InitialSize                  10i 0 const
     D  InitialValue                  1    const
     D  PublicAuth                   10    const
     D  Text                         50    const
     D  Replace                      10    const
     D  ApiError                    120    options(*varsize)
     D  Domain                       10    options(*nopass)

     d QUSPTRUS        PR                  extpgm('QUSPTRUS')
     d  UserSpace                    20    const
     d  UserSpacePtr                   *

      *----------------------------------------------------------------
      * QMHSNDPM/QMHRCVPM/QMHRSNEM - send/receive/resend pgm messages
      *----------------------------------------------------------------
     D QMHSNDPM        PR                  extpgm('QMHSNDPM')
     D  MessageId                     7    const
     D  MessageFile                  20    const
     D  MessageData                 512    const options(*varsize)
     D  MessageDataL                  9b 0 const
     D  MessageType                  10    const
     D  CallStkEntry                128    const options(*varsize)
     D  CallStkCount                  9b 0 const
     D  MessageKey                    4    const
     D  ApiError                    120    options(*varsize)
     D* send program message
     D sndpgmmsg       ds
     D  msgid                         7    inz('CPF9898')
     D  msgfile                      20    inz('QCPFMSG   QSYS      ')
     D  msgdataL                      9b 0 inz(512)
     D  msgtype                      10    inz('*COMP     ')
     D  msgmsgq                      11    inz('*       ')
     D  msgstack                      9b 0 inz(1)
     D  msgkey                        4
     D* receive program message
     D QMHRCVPM        PR                  extpgm('QMHRCVPM')
     D  rcv0100                    1024
     D  msgbytes                      9b 0 const
     D  msgformat                     8    const
     D  msgmsgq                      11    const
     D  msgstack                      9b 0 const
     D  msgtyper                     10    const
     D  msgkey                        4    const
     D  msgwait                       9b 0 const
     D  msgaction                    10    const
     D  ApiError                    120    options(*varsize)
     D rcvpgmmsg       ds
     D  msgbytes                      9b 0 inz(8)
     D  msgformat                     8    inz('RCVM0100')
     D  msgwait                       9b 0 inz(0)
     D  msgaction                    10    inz('*OLD      ')
     D  msgtyper                     10    inz('*ANY      ')
     D msgdata         s            512
     D rcv0100         s           1024
     D* resend escape message
     D QMHRSNEM        PR                  extpgm('QMHRSNEM')
     D  qmhmkey                       4    const
     D  ApiError                    120    options(*varsize)
     D  qmhtostack                   48    const
     D  qmhtostack#                   9B 0 const
     D  qmhtostackf                   8    const
     D  qmhfrmstka                   16    const
     D  qmhfrmstkc                    9B 0 const
     d qmhtostack      ds
     d  qmhtostackc                   9b 0 inz(1)
     d  qmhtostackeq                 20    inz('*NONE     *NONE     ')
     d  qmhtostacki                   9b 0 inz(10)
     d  qmhtostackei                 20    inz('*PGMBDY')
     d qmhmkey         s              4    inz('    ')
     d qmhtostack#     s              9b 0 inz(48)
     d qmhtostackf     s              8    inz('RSNM0100')
     d qmhfrmstka      s             16    inz('*')
     d qmhfrmstkc      s              9b 0 inz(0)

      *----------------------------------------------------------------
      * SQL2IFS - write to IFS
      *----------------------------------------------------------------
     D SQL2IFS         PR                  extpgm('SQL2IFS')
     D  pSPCNAME                       *
     D  plCSV                        10I 0
     D  pTOCSV                       63A
     D  pMODE                         8A

      *----------------------------------------------------------------
      * api error structure
      *----------------------------------------------------------------
     D ApiError        ds
     D  ApiErrLP                      9b 0 inz(%len(Apierror))
     D  ApiErrLA                      9b 0 inz(0)
     D  ApiErrMsg                     7
     D                                1
     D  ApiErrDta                   104

      *----------------------------------------------------------------
      * MI/C functions
      *----------------------------------------------------------------
     D* Copy Bytes left adjusted (MemCpy)
     D Cpybla          pr                  ExtProc('cpybla')
     D  Receiver                       *   value
     D  Source                         *   value
     D  Size                         10i 0 value

      *----------------------------------------------------------------
*s4*  * Internal procedures
      *----------------------------------------------------------------
     D EditN           PR
     D  cn                            5I 0 const
     D  Precision                     3I 0 const options(*nopass)
     D  Scale                         3I 0 const options(*nopass)
     D  NumType                      10    const options(*nopass)
     D  SQLDATA                        *   value options(*nopass)
     D  CSV                            *   value options(*nopass)

     D RtvSysVal       PR

      *----------------------------------------------------------------
      * program status area
      *----------------------------------------------------------------
     D parms          sds
     D  parmsL           *parms
     D  pgmnam           *proc

      *****************************************************************
      ** MAIN
      *****************************************************************

      /free

       // reformat the SQL statement
       SqlStmt = pSQLSTMT;
       psqlL = %checkr(' ':SqlStmt);
       for j = 1 to psqlL;
         select;
           when %subst(SqlStmt:j:1) = '"';
             %subst(SqlStmt:j:1) = '''';
           when %subst(SqlStmt:j:1) = '[';
             %subst(SqlStmt:j:1) = '"';
           when %subst(SqlStmt:j:1) = ']';
             %subst(SqlStmt:j:1) = '"';
         endsl;
       endfor;

       // create the *sqlpkg If it does not exist
       ApiErrMsg = *blanks;
       objd_name = pgmnam + '*LIBL';
       QUSROBJD (objd_rcvr:48:'OBJD0100':objd_name:'*PGM':apierror);
       mainlib = objd_rlib;
       ApiErrMsg = *blanks;
       pkgname = pgmnam;
       objd_name = pkgname + pkglib;
       QUSROBJD (objd_rcvr:48:'OBJD0100':objd_name:'*SQLPKG':apierror);
       If ApiErrMsg = 'CPF9801';
         // prepare the sql template
         namingopt = %subst(pNAMING:2:3);
         // crea il package
         ApiErrMsg = ' ';
         function = '1';
         QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
         If ApiErrMsg <> ' ';
           *inlr = *on;
           return;
         EndIf;
       EndIf;

       // allocate 20 elements
       nSQLDA = 20;
       szSQLDA = (nSQLDA * 80) + 16;
       pSQLDA = %alloc(szSQLDA);
       clear SQLDA;
       SQLN = nSQLDA;

       // prepare the SQL statement
       function = '2';
       openopt = x'80';
       SqlStmtl = psqlL;
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);

       // If errors in prepare/describe do not continue
       If SQLCODE <> 0;
         exsr ckretcode;
         *inlr = *on;
         return;
       EndIf;

       // describe the SQL into SQLDA
       function = '7';
       select;
         when pCOLHDRS = '*FLDNAM';
           claudesc = 'N';
         when pCOLHDRS = '*SQLLABEL';
           claudesc = 'L';
         when pCOLHDRS = '*ANY';
           claudesc = 'A';
         other;
           claudesc = 'N';
       endsl;
       SqlStmtl = psqlL;
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       If SQLN <= SQLD;                  // reallocate If not enough
         nSQLDA = SQLD;
         szSQLDA = (nSQLDA * 80) + 16;
         pSQLDA = %realloc(pSQLDA:szSQLDA);
         SQLN = nSQLDA;
         QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       EndIf;
       // only select statements are allowed
       If sqld = 0;
         SQLCODE = 0084;
       EndIf;
       // If there are errors in prepare/describe do not continue
       If SQLCODE <> 0;
         exsr ckretcode;
         *inlr = *on;
         return;
       EndIf;

       // setup space for CSV
       SpcSize = 15000000;
       QUSCRTUS ('CSV       QTEMP     ' : ' ' : SpcSize : X'00' :
                   '*ALL' : 'Space for CSV' : '*NO' : ApiError);
       QUSPTRUS ('CSV       QTEMP     ' : pSPCNAME);

       objd_name = 'CSV       QTEMP     ';
       QUSROBJD (objd_rcvr:476:'OBJD0400':objd_name:'*USRSPC':apierror);
       SpcSize = objd_size;

       pCSV = pSPCNAME;

       // write title
       If pTITLE <> '*NONE';
         CSV = '"' + %trim(pTITLE) + '"' + LF;
         pCSV = pCSV + %len(%trim(pTITLE)) + 3;
       EndIf;

       // set the record buffer addresses into SQLDA
       pSQLVAR = %addr(SQL_VAR);
       od = 0;
       on = 0;

       for c = 1 to SQLD;

         // set record buffer address into SQLDA
         select;                                     // field Type
           when  SQLTYPE = 484 or SQLTYPE = 485 or   // .. Packed
                 SQLTYPE = 488 or SQLTYPE = 489;     // .. Signed
             cSQLLEN = Precision;
           when  SQLTYPE = 384 or SQLTYPE = 385;     // .. Date
             cSQLLEN = 10;
           when  SQLTYPE = 388 or SQLTYPE = 389;     // .. Time
             cSQLLEN = 10;
           when  SQLTYPE = 392 or SQLTYPE = 393;     // .. Timestamp
             cSQLLEN = 18;
           when  SQLTYPE = 448 or SQLTYPE = 449;     // .. VarChar
             SQLLEN += 2;
             cSQLLEN = SQLLEN;
             SQLTYPE += 4;
           other;                                    // .. Char
             cSQLLEN = SQLLEN;
           endsl;

         SQLDATA = %addr(Record) + od;               // address for data
         SQLIND  = %addr(NullFields) + on;           // address for nullind

         // write column header
         If pCOLHDRS <> '*NONE';
           if c = 1;
             CSV = '"' + %trim(SQLNAME) + '"';
             pCSV = pCSV + %len(%trim(SQLNAME)) + 2;
           else;
             CSV = ',"' + %trim(SQLNAME) + '"';
             pCSV = pCSV + %len(%trim(SQLNAME)) + 3;
           endif;
         EndIf;

         // point to next element
         od = od + cSQLLEN + 1;
         on = on + 2;
         pSQLVAR = pSQLVAR + 80;
       endfor;

       // Set Minimum space required
       SpcMinimum = od * 10;

       // end column header
       If pCOLHDRS <> '*NONE';
         CSV = LF;
         pCSV += 1;
       EndIf;

       // initialize edit words
       EditN(0);

       // open cursor
       function = '4';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);

       // fetch records
       function = '5';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       dow SQLCODE = 0;

         // Check available space
         SpcUsed  = pCSV - pSPCNAME;
         SpcAvail = SpcSize - SpcUsed;
         if SpcAvail < SpcMinimum;
           SQL2IFS (pSPCNAME:SpcUsed:pTOCSV:pMODE);
           eval pMODE = '*ADD';
           pCSV = pSPCNAME;
         endif;

         // initialize numeric edit code
         cn = 0;

         //.. point to first element
         pSQLVAR = %addr(SQL_VAR);
         for c = 1 to SQLD;

           // open tag
           if c = 1;
510aD        //CSV = '"';
510aD        //pCSV += 1;
510aM        CSV = ' ';
510aM        pCSV += 1;
           else;
510aD        //CSV = ',"';
510aD        //pCSV += 2;
510aM        CSV = ',';
510aM        pCSV += 1;
           endif;

           // data
           select;
             // null field
             when NullFields(c) = -1;
             // ... Packed
             when SQLTYPE = 484 or SQLTYPE = 485;
               cn += 1;
               EditN(cn:Precision:Scale:'*PACKED':SQLDATA:pCSV);
               Number = %triml(Number);
               pCSV = pCSV + %len(%trimr(Number));
             // ... Signed
             when SQLTYPE = 488 or SQLTYPE = 489;
               cn += 1;
               EditN(cn:Precision:Scale:'*ZONED':SQLDATA:pCSV);
               Number = %triml(Number);
               pCSV = pCSV + %len(%trimr(Number));
             // ... Short integer
             when SQLTYPE = 500 or SQLTYPE = 501;
               cn += 1;
               EditN(cn:x'05':x'00':'*BINARY':SQLDATA:pCSV);
               Number = %triml(Number);
               pCSV = pCSV + %len(%trimr(Number));
             // ... Large integer
             when SQLTYPE = 496 or SQLTYPE = 497;
               cn += 1;
               EditN(cn:x'0a':x'00':'*BINARY':SQLDATA:pCSV);
               Number = %triml(Number);
               pCSV = pCSV + %len(%trimr(Number));
             // ... Big integer
             when SQLTYPE = 492 or SQLTYPE = 493;
             // ... Date/Time/Timestamp
             when SQLTYPE = 384 or SQLTYPE = 385 or
                  SQLTYPE = 388 or SQLTYPE = 389 or
                  SQLTYPE = 392 or SQLTYPE = 393;
               cpybla (pCSV:SQLDATA:SQLLEN);
               od = %len(%trim(%subst(CSV:1:SQLLEN)));
               pCSV = pCSV + od;
             // ... Characters and other
             other;
510aA          CSV = '"';
510aA          pCSV += 1;
               cpybla (pCSV:SQLDATA:SQLLEN);
510aD        //od = %len(%trim(%subst(CSV:1:SQLLEN)));
510aM          od = %len(%trimr(%subst(CSV:1:SQLLEN)));
               pCSV = pCSV + od;
510aA          CSV = '"';
510aA          pCSV += 1;
           endsl;

           // close tag
510aD      //CSV = '"';
510aD      //pCSV += 1;

           //.. point to next element
           pSQLVAR = pSQLVAR + 80;
         endfor;

         // write linefeed
510aA    CSV = CR;
510aA    pCSV += 1;
         CSV = LF;
         pCSV += 1;

         QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       enddo;

       // close cursor
       function = '8';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);

       // length of CSV
       lCSV = pCSV - pSPCNAME; // + 1;

       // write to IFS
       SQL2IFS (pSPCNAME:lCSV:pTOCSV:pMODE);

       *inlr = *on;
       return;

       // ------------------------------------------------------------------
       // Check sql return codes
       // ------------------------------------------------------------------
       begsr ckretcode;

       select;
          // error condition
          when SQLCODE < 0;
            msgtype = '*DIAG';
            //... cpf message
            If SQLER1 > 0;
              msgid = %editw(%dec(SQLER1:7:0):'0      ');
              %subst(msgid:1:3) = 'CPF';
            else;
            //... cpd message
              If SQLER2 > 0;
                msgid = %editw(%dec(SQLER2:7:0):'0      ');
                %subst(msgid:1:3) = 'CPD';
              else;
                msgid = %editw(%dec(SQLCODE*-1:7:0):'0      ');
                %subst(msgid:1:3) = 'SQL';
                %subst(msgfile:1:10) = 'QSQLMSG';
              EndIf;
            EndIf;
          // successful with warnings
          when SQLCODE > 0;
            msgid = %editw(%dec(SQLCODE:7:0):'0      ');
            %subst(msgid:1:3) = 'SQL';
            %subst(msgfile:1:10) = 'QSQLMSG';
          // successful execution
          other;
            msgid = 'SQL' + SQLER6;
            %subst(msgfile:1:10) = 'QSQLMSG';
       endsl;

       // message text
       If SQLERrml > 0;
         msgdata = SQLERrmc;
         msgdataL = SQLERrml;
       EndIf;

       EndSr;

      /end-free

     p**---------------------------------------------------------------
     p** Edit
     p**---------------------------------------------------------------

     P EditN           B
     D EditN           PI
     D  cn                            5I 0 const
     D  Precision                     3I 0 const options(*nopass)
     D  Scale                         3I 0 const options(*nopass)
     D  NumType                      10    const options(*nopass)
     D  SQLDATA                        *   value options(*nopass)
     D  CSV                            *   value options(*nopass)

     D QECCVTEC        PR                  extpgm('QECCVTEC')
     D  EditMask                    256A
     D  EditMaskL                     9B 0
     D  RcvrVarL                      9B 0
     D  ZeroBalF                      1A   const
     D  EditCode                      1A   const
     D  FillCode                      1A   const
     D  pPrecis                       9B 0 const
     D  pScale                        9B 0 const
     D  Apierror                    120    options(*varsize)
     D QECEDT          PR                  extpgm('QECEDT')
     D  RcvrVar                     256A
     D  RcvrVarL                      9B 0 const
     D  SrcVar                       25A   const
     D  SrcVarC                      10A   const
     D  pPrecis                       9B 0 const
     D  EditMask                    256A   const
     D  EditMaskL                     9B 0 const
     D  FillCode                      1A   const
     D  Apierror                    120    options(*varsize)

     D EditCode        s              1    static
     D FillCode        s              1
     D EditMask        s            256
     D EditMaskL       s              9B 0
     D RcvrVar         s            256    based(CSV)
     D RcvrVarL        s              9B 0
     D SrcVar          s             25    based(SQLDATA)
     D SrcVarC         s             10
     D ZeroBalF        s              1

     D EditMaskS       s             48A   dim(1000) static
     D EditMaskSL      s              9B 0 dim(1000) static
     D RcvrVarSL       s              9B 0 dim(1000) static

     D Initialized     S               N

      /free

        // initialize edit words
        if cn = 0;
          EditMaskS = *blank;
          EditMaskSL = *zeros;
          RcvrVarSL = *zeros;
          EditCode = 'Q';
          return;
        endif;

       // prepare/retrieve edit mask
       if EditMaskS(cn) = ' ';
         QECCVTEC (EditMask:EditMaskL:RcvrVarL:ZeroBalF:EditCode:' ':
                   Precision:Scale:ApiError);
         i = %scan(',':%subst(EditMask:1:EditMaskL));
         if i > 1;
           EditMaskS(cn) = %replace('.':%subst(EditMask:1:EditMaskL):i:1);
         else;
           EditMaskS(cn) = %subst(EditMask:1:EditMaskL);
         endif;
         EditMaskSL(cn) = EditMaskL;
         RcvrVarSL(cn) = RcvrVarL;
       endif;

       // edit number
       EditMask = EditMaskS(cn);
       EditMaskL = EditMaskSL(cn);
       RcvrVarL = RcvrVarSL(cn);
       QECEDT (RcvrVar:RcvrVarL:SrcVar:NumType:Precision:
               EditMask:EditMaskL:' ':ApiError);

      /end-free

     p EditN           E
