/********************************************************************/
/*                                                                  */
/* 5770SS1 V7R1M0 100423     RTVCLSRC Output     04/08/13 16:51:27  */
/*                                                                  */
/* Program name . . . . . . . . . . . . . . :   QSTRUP            PN*/
/* Library name . . . . . . . . . . . . . . :   QSYS              PL*/
/* Original source file . . . . . . . . . . :   S000076444        SN*/
/* Library name . . . . . . . . . . . . . . :   $BLDSS1           SL*/
/* Original source member . . . . . . . . . :   S000076444        SM*/
/* Source file change                                               */
/*   date/time  . . . . . . . . . . . . . . :   10/05/09 00:20:13 SC*/
/* Patch option . . . . . . . . . . . . . . :   *NOPATCH          PO*/
/* User profile . . . . . . . . . . . . . . :   *USER             UP*/
/* Text . . . :                                                   TX*/
/* Owner  . . . . . . . . . . . . . . . . . :   QSYS              OW*/
/* User mod flag  . . . . . . . . . . . . . :   *NO               UM*/
/* Retrieve included source . . . . . . . . :   *NO               RI*/
/*------------------------------------------------------------------*/
/* Client Custom Revisions: <client name here>                      */
/*                                                                  */
/* 04/08/13  MLB   BFC                                              */
/*   - Added start up of voice sockets on systems return.           */
/*     Added start up of Tomcat server to pgm.                      */
/*     Included 5 min. delay to allow tcp/ip services to start.     */
/* 04/11/14  MLB   BFCa                                             */
/*   - Enh: Revised pgm to use new BFCTOMCAT cmd to start servers.  */
/*                                                                ED*/
/*------------------------------------------------------------------*/
/********************************************************************/
     PGM
     DCL VAR(&STRWTRS) TYPE(*CHAR) LEN(1)
     DCL VAR(&CTLSBSD) TYPE(*CHAR) LEN(20)
     DCL VAR(&CPYR) TYPE(*CHAR) LEN(90) VALUE('5770-SS1 (C) COPYRIGHT-
 IBM CORP 1980, 2009. LICENSED MATERIAL - PROGRAM PROPERTY OF IBM')
     QSYS/STRSBS SBSD(QSERVER)
     MONMSG MSGID(CPF0000)
     QSYS/STRSBS SBSD(QUSRWRK)
     MONMSG MSGID(CPF0000)
     QSYS/RLSJOBQ JOBQ(QGPL/QS36MRT)
     MONMSG MSGID(CPF0000)
     QSYS/RLSJOBQ JOBQ(QGPL/QS36EVOKE)
     MONMSG MSGID(CPF0000)
     QSYS/STRCLNUP
     MONMSG MSGID(CPF0000)
     QSYS/RTVSYSVAL SYSVAL(QCTLSBSD) RTNVAR(&CTLSBSD)
     IF COND((&CTLSBSD *NE 'QCTL      QSYS      ') *AND (&CTLSBSD *NE-
 'QCTL      QGPL      ')) THEN(GOTO CMDLBL(DONE))
     QSYS/STRSBS SBSD(QINTER)
     MONMSG MSGID(CPF0000)
     QSYS/STRSBS SBSD(QBATCH)
     MONMSG MSGID(CPF0000)
     QSYS/STRSBS SBSD(QCMN)
     MONMSG MSGID(CPF0000)
DONE:
     QSYS/STRSBS SBSD(QSPL)
     MONMSG MSGID(CPF0000)
     QSYS/RTVSYSVAL SYSVAL(QSTRPRTWTR) RTNVAR(&STRWTRS)
     IF COND(&STRWTRS = '0') THEN(GOTO CMDLBL(NOWTRS))
     CALL PGM(QSYS/QWCSWTRS)
     MONMSG MSGID(CPF0000)
NOWTRS:
BFC:
     DLYJOB     DLY(300)                                          /* (BFC A) */
     SBMJOB     CMD(PIRVOICE/VOSTRGRP PORTGRP(8000) START(1) +
                  GROUPS(1) TYPE(PRO)) JOB(BFCSTRVOC) +
                  JOBD(PIR650/PIRJOBD) JOBQ(QS36EVOKE) +
                  INLLIBL(*JOBD)
     MONMSG     MSGID(CPF0000)                                    /* (BFC A) */
     SBMJOB     CMD(PIRVOICE/VOSTRGRP PORTGRP(8000) START(20) +
                  GROUPS(1) TYPE(TST)) JOB(BFCSTRVOC) +
                  JOBD(PIR650/PIRJOBDTST) JOBQ(QS36EVOKE) +
                  INLLIBL(*JOBD)
     MONMSG     MSGID(CPF0000)                                    /* (BFC A) */

/*   SBMJOB     CMD(CALL PGM(STRBFCTOMC)) JOB(STRBFCTOM) +
                  JOBD(PIR/PIRJOBD) INLLIBL(*JOBD)                /* (BFCaD) */
     SBMJOB     CMD(PIR650/BFCTOMCAT CMD(*START) PROD(Y) +
                    PROD2(Y) TEST(N) TEST2(N)) JOB(STRBFCTOM) +
                    JOBD(PIR650/PIRJOBD) INLLIBL(*JOBD)           /* (BFCaM) */
     MONMSG     MSGID(CPF0000)                                    /* (BFC A) */

     RETURN
     CHGVAR VAR(&CPYR) VALUE(&CPYR)
     ENDPGM
