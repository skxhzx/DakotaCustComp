     H dftactgrp(*no) actgrp('XML') bnddir('QC2LE') debug
     H option(*srcstmt : *nodebugio)

      *********************************************************************
      * SQL2XMLR - Create XML from SQL
      *********************************************************************

      **------------------------------------------------------------------
      * SQL2XML CMD PARAMETERS
      **------------------------------------------------------------------
     D EntryParms      PR                  extpgm('SQL2XML')
     D  pSQLSTMT                   5000A
     D  pTOXML                       63A
     D  pROOT                        32A
     D  pENTITY                      32A
     D  pXSL                         63A
     D  pTITLE                      120A
     D  pTITLENAME                   32A
     D  pCOLHDRS                     10A
     D  pRPLSPCHAR                    4A
     D  pOUTEMPTYE                    4A
     D  pMODE                         8A
     D  pENDROOT                      4A
     D  pNAMING                       4A
     D  pACTION                       9A
     D EntryParms      PI
     D  pSQLSTMT                   5000A
     D  pTOXML                       63A
     D  pROOT                        32A
     D  pENTITY                      32A
     D  pXSL                         63A
     D  pTITLE                      120A
     D  pTITLENAME                   32A
     D  pCOLHDRS                     10A
     D  pRPLSPCHAR                    4A
     D  pOUTEMPTYE                    4A
     D  pMODE                         8A
     D  pENDROOT                      4A
     D  pNAMING                       4A
     D  pACTION                       9A

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
     D  SQL_VAR                      80A   DIM(1)

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
     D nSQLDA          s              5I 0
     D szSQLDA         s             10I 0

     D* Column sizes
     D cSQLLEN         s              5I 0

     D* Record buffer
     D Record          s          32000

     D* XML buffer
     d pSPCNAME        S               *
     d pXML            s               *
     d XML             s           1024    based(pXML)
     d Number          s             33    based(pXML)
     d lXML            s             10i 0

     d SpcSize         s             10i 0
     d SpcAvail        s             10i 0
     d SpcUsed         s             10i 0
     d SpcMinimum      s             10i 0

     D* Miscellaneous
     D psqlL           s              5i 0
     D nullFields      s              5i 0 dim(1000)
     D emptyField      S               N
     D c               s              5i 0
     D i               s              5i 0
     D j               s              5i 0
     D cn              s              5i 0
     D jo              s              5i 0
     D od              s              5i 0
     D on              s              5i 0
     D os              s             10i 0
     D LF              c                   x'25'
     D CR              c                   x'0d'

     D SqlError        S            512A

      *----------------------------------------------------------------
      * QSQPRCED - process extended dynamic sql
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
     D  pkgname                      10    inz('SQLXML')
     D  pkglib                       10    inz('QTEMP')
     D  mainpgm                      10    inz('SQL2XML')
     D  mainlib                      10    inz('*LIBL')
     D  stmname                      18    inz('XML')
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
      * QMHSNDPM/QMHRCVPM - send/receive program messages
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
     D* retrieve message
     D QMHRTVM         PR                  extpgm('QMHRTVM')
     D  MsgInfo                    4096    options(*varsize)
     D  MsgInfoL                      9B 0 const
     D  MsgFmtName                    8    const
     D  MessageId                     7    const
     D  MsgFileName                  20    const
     D  MsgRplData                  128    const options(*varsize)
     D  MsgRplDataL                   9B 0 const
     D  MsgRplOpt                    10    const
     D  MsgRtnCtrlC                  10    const
     D  ApiError                    120    options(*varsize)

     d** SQL Error message
     d ErrorMsg        ds           170
     D  QMHLMRTN               9     12B 0
     D  QMHMH                 25    164

      *----------------------------------------------------------------
      * SQL2IFS - write to IFS
      *----------------------------------------------------------------
     D SQL2IFS         PR                  extpgm('SQL2IFS')
     D  pSPCNAME                       *   const
     D  plXML                        10I 0 const
     D  pTOXML                       63A   const
     D  pMODE                         8A   const

      *----------------------------------------------------------------
      * SQL2CGI - write to CGI
      *----------------------------------------------------------------
     D SQL2CGI         PR                  extpgm('SQL2CGI')
     D  pSPCNAME                       *   const
     D  plXML                        10I 0 const

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
      * get SQL return code
      *----------------------------------------------------------------
     d getSqlCode      PR

      *----------------------------------------------------------------
      * Edit
      *----------------------------------------------------------------
     d EditN           PR
     D  cn                            5I 0 const
     D  Precision                     3I 0 const options(*nopass)
     D  Scale                         3I 0 const options(*nopass)
     D  NumType                      10    const options(*nopass)
     D  SQLDATA                        *   value options(*nopass)
     d  XML                            *   value options(*nopass)

      *----------------------------------------------------------------
      * Set elelement Text
      *----------------------------------------------------------------
     d setElementN     PR

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

       // setup space for XML
       SpcSize = 15000000;
       QUSCRTUS ('XML       QTEMP     ' : ' ' : SpcSize : X'00' :
                   '*ALL' : 'Space for XML' : '*NO' : ApiError);
       QUSPTRUS ('XML       QTEMP     ' : pSPCNAME);

       objd_name = 'XML       QTEMP     ';
       QUSROBJD (objd_rcvr:476:'OBJD0400':objd_name:'*USRSPC':apierror);
       SpcSize = objd_size;

       pXML = pSPCNAME;

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
         // prepara la sql template
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
         getSqlCode();
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
         getSqlCode();
         *inlr = *on;
         return;
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
           other;                                    // .. Char
             cSQLLEN = SQLLEN;
           endsl;

         SQLDATA = %addr(Record) + od;               // address for data
         SQLIND  = %addr(NullFields) + on;           // address for nullind

         // point to next element
         od = od + cSQLLEN + 1;
         on += 2;
         pSQLVAR = pSQLVAR + 80;
       endfor;

       // Set Minimum space required
       SpcMinimum = od * 500;

       // open cursor
       function = '4';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);

       // write xmlheader and xsl if new document
       if pMODE = '*REPLACE';
         // write xmlheader
         XML = '<?xml version="1.0" encoding="ISO-8859-1"?>' + LF;
         pXML += 44;
         // write xsl
         if pXSL <> '*NONE';
           XML = '<?xml-stylesheet type="text/xsl" href="' +
                  %trim(pXSL) + '"?>' + LF;
           pXML = pXML + %len(%trim(pXSL)) + 43;
         endif;
       endif;

       // write <rootName>
       if pMODE = '*REPLACE';
         XML = '<' + %trim(pROOT) + '>' + LF;
         pXML = pXML + %len(%trim(pROOT)) + 3;
       endif;

       // write <Title>
       if pTITLE <> '*NONE';
         XML = '<' + %trim(pTITLENAME) + '>' +
               %trim(pTITLE) +
               '</'+ %trim(pTITLENAME) + '>' + LF;
         pXML = pXML + %len(%trim(XML));
       endif;

       // initialize edit words
       EditN(0);

       // fetch records
       function = '5';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       dow SQLCODE = 0;

        // Check available space
        SpcUsed  = pXML - pSPCNAME;
        SpcAvail = SpcSize - SpcUsed;
        if SpcAvail < SpcMinimum;
          SQL2IFS (pSPCNAME:SpcUsed:pTOXML:pMODE);
          eval pMODE = '*ADD';
          pXML = pSPCNAME;
        endif;

       // write <entity>
       XML = '<' + %trim(pENTITY) + '>' + LF;
       pXML = pXML + %len(%trim(pENTITY)) + 3;

         // initialize numeric edit code
         cn = 0;

         //.. point to first element
         pSQLVAR = %addr(SQL_VAR);
         for c = 1 to SQLD;

           // null field
           if NullFields(c) = -1;
             emptyField = *on;
             if pOUTEMPTYE = '*YES';
               XML = '<' + %trim(SQLNAME) + '/>' + LF;
               pXML = pXML + %len(%trim(SQLNAME)) + 4;
             endif;
           else;
             // field opening tag
             XML = '<' + %trim(SQLNAME) + '>';
             pXML = pXML + %len(%trim(SQLNAME)) + 2;
             emptyField = *off;
             // dati
             select;
               // ... Packed
               when SQLTYPE = 484 or SQLTYPE = 485;
                 cn += 1;
                 EditN(cn:Precision:Scale:'*PACKED':SQLDATA:pXML);
                 setElementN();
               // ... Signed
               when SQLTYPE = 488 or SQLTYPE = 489;
                 cn += 1;
                 EditN(cn:Precision:Scale:'*ZONED':SQLDATA:pXML);
                 setElementN();
               // ... Short integer
               when SQLTYPE = 500 or SQLTYPE = 501;
                 cn += 1;
                 EditN(cn:x'05':x'00':'*BINARY':SQLDATA:pXML);
                 setElementN();
               // ... Large integer
               when SQLTYPE = 496 or SQLTYPE = 497;
                 cn += 1;
                 EditN(cn:x'0a':x'00':'*BINARY':SQLDATA:pXML);
                 setElementN();
               // ... Big integer
               when SQLTYPE = 492 or SQLTYPE = 493;
               // ... Date/Time/Timestamp
               when  SQLTYPE = 384 or SQLTYPE = 385 or
                     SQLTYPE = 388 or SQLTYPE = 389 or
                     SQLTYPE = 392 or SQLTYPE = 393;
                 cpybla (pXML:SQLDATA:SQLLEN);
                 od = %len(%trim(%subst(XML:1:SQLLEN)));
                 pXML = pXML + od;
               // ... Characters and other
               other;
                 cpybla (pXML:SQLDATA:SQLLEN);
                 od = %len(%trim(%subst(XML:1:SQLLEN)));
                 if od > 0;
                   if pRPLSPCHAR = '*YES';
                     if %scan('&':%subst(XML:1:od)) > 0;
                       XML = '<![CDATA[' + %subst(XML:1:od) + ']]>';
                       od += 12;
                     endif;
                   endif;
                   pXML += od;
                 else;
                   emptyField = *on;
                   if pOUTEMPTYE = '*YES';
                     pXML -= 1;
                     XML = '/>' + LF;
                     pXML += 3;
                   else;
                     pXML = pXML - %len(%trim(SQLNAME)) - 2;
                   endif;
                 endif;
             endsl;
           endif;

           // field close tag
           if not emptyField;
             XML = '</' + %trim(SQLNAME) + '>' + LF;
             pXML = pXML + %len(%trim(SQLNAME)) + 4;
           endif;

           //.. point to next element
           pSQLVAR += 80;
         endfor;

         // write </elementName>
         XML = '</' + %trim(pENTITY) + '>' + LF;
         pXML = pXML + %len(%trim(pENTITY)) + 4;

         QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       enddo;

       // close cursor
       function = '8';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);

       // write </rootName>
       if pENDROOT = '*YES';
         XML = '</' + %trim(pROOT) + '>' + CR + LF;
         pXML = pXML + %len(%trim(pROOT)) + 5;
       endif;

       // length of XML
       lXML = pXML - pSPCNAME; // + 1;

       // write to IFS
       if pTOXML <> '*CGI';
         SQL2IFS (pSPCNAME:lXML:pTOXML:pMODE);
       // write to CGI
       else;
         SQL2CGI (pSPCNAME:lXML);
       endif;

       // send a completion message and return
       getSqlCode();
       msgtype  = '*COMP';
       msgstack = 1;
       QMHSNDPM (msgid:msgfile:msgdata:msgdataL:msgtype:msgmsgq:
                 msgstack:msgkey:apierror);
       *inlr = *on;
       return;

      /end-free

      **---------------------------------------------------------------
      ** Get sql return codes
      **---------------------------------------------------------------

     P getSqlCode      B
     D getSqlCode      PI

      /free

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

       If SQLCODE <> 0;
         if pTOXML = '*CGI';
           clear ErrorMsg;
           QMHRTVM (ErrorMsg: %len(ErrorMsg): 'RTVM0100': MsgId:
                    msgfile: msgdata: msgdataL: '*YES': '*NO': ApiError);
           SqlError = %subst(QMHMH:1:QMHLMRTN);
           i = %scan('<':SqlError);
           if i > 0;
             SqlError = %replace('&lt;':SqlError:i:1);
           endif;
           i = %scan('>':SqlError);
           if i > 0;
             SqlError = %replace('&gt;':SqlError:i:1);
           endif;
           XML = '<?xml version="1.0" encoding="UTF-8"?>' + x'25' +
                 '<SQLERROR>' + SqlError + '</SQLERROR>' + x'0d25';
           SQL2CGI (pXML:%len(%trim(XML)));
         else;
           if pACTION = '*ESCAPE';
             QMHSNDPM (msgid:msgfile:msgdata:msgdataL:
                       '*ESCAPE':'*CTLBDY':1:msgkey:apierror);
           endif;
         endif;
       endif;

      /end-free

     P getSqlCode      E

      **---------------------------------------------------------------
      ** Edit number
      **---------------------------------------------------------------

     P EditN           B
     D EditN           PI
     D  cn                            5I 0 const
     D  Precision                     3I 0 const options(*nopass)
     D  Scale                         3I 0 const options(*nopass)
     D  NumType                      10    const options(*nopass)
     D  SQLDATA                        *   value options(*nopass)
     D  XML                            *   value options(*nopass)

     D QECCVTEC        PR                  extpgm('QECCVTEC')
     D  EditMask                    256A
     D  EditMaskL                     9B 0
     D  RcvrVarL                      9B 0
     D  ZeroBalF                      1A   const
     D  EditCode                      1A   const
     D  FillCode                      1A   const
     D  pPrecision                    9B 0 const
     D  pScale                        9B 0 const
     D  Apierror                    120    options(*varsize)
     D QECEDT          PR                  extpgm('QECEDT')
     D  RcvrVar                     256A
     D  RcvrVarL                      9B 0 const
     D  SrcVar                       25A   const
     D  SrcVarC                      10A   const
     D  pPrecision                    9B 0 const
     D  EditMask                    256A   const
     D  EditMaskL                     9B 0 const
     D  FillCode                      1A   const
     D  Apierror                    120    options(*varsize)

     D EditCode        S              1
     D FillCode        S              1
     D EditMask        S            256
     D EditMaskL       S              9B 0
     D RcvrVar         S            256    based(XML)
     D RcvrVarL        S              9B 0
     D SrcVar          S             25    based(SQLDATA)
     D SrcVarC         S             10
     D ZeroBalF        S              1

     D EditMaskS       S             48A   dim(1000) static
     D EditMaskSL      S              9B 0 dim(1000) static
     D RcvrVarSL       S              9B 0 dim(1000) static

     D Initialized     S               N

      /free

       // initialize edit words
       if cn = 0;
         EditMaskS = *blank;
         EditMaskSL = *zeros;
         RcvrVarSL = *zeros;
         return;
       endif;

       // prepare/retrieve edit mask
       if EditMaskS(cn) = ' ';
         if Scale = 2;
           EditCode = 'N';
         else;
           EditCode = 'Q';
         endif;
         QECCVTEC (EditMask:EditMaskL:RcvrVarL:ZeroBalF:EditCode:' ':
                   Precision:Scale:ApiError);
         EditMaskS(cn) = %subst(EditMask:1:EditMaskL);
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

      **---------------------------------------------------------------
      ** Skip empty tags
      **---------------------------------------------------------------

     P setElementN     B
     D setElementN     PI

      /free

       if Number = ' ';
         emptyField = *on;
         if pOUTEMPTYE = '*YES';
           pXML -= 1;
           XML = '/>' + LF;
           pXML += 3;
         else;
           pXML = pXML - %len(%trim(SQLNAME)) - 2;
         endif;
       else;
         Number = %triml(Number);
         pXML = pXML + %len(%trimr(Number));
       endif;

      /end-free

     P setElementN     E
