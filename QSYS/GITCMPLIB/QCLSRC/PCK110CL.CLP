/********************************************************************/
/*                                                                  */
/* 5770SS1 V7R2M0 140418     RTVCLSRC Output     06/04/18 13:12:26  */
/*                                                                  */
/* Program name . . . . . . . . . . . . . . :   PCK110CL          PN*/
/* Library name . . . . . . . . . . . . . . :   PIRCUR            PL*/
/* Original source file . . . . . . . . . . :   QTESTSRC          SN*/
/* Library name . . . . . . . . . . . . . . :   PIRWORK           SL*/
/* Original source member . . . . . . . . . :   PCK110CL          SM*/
/* Source file change                                               */
/*   date/time  . . . . . . . . . . . . . . :   07/17/97 09:45:29 SC*/
/* Patch option . . . . . . . . . . . . . . :   *NOPATCH          PO*/
/* User profile . . . . . . . . . . . . . . :   *USER             UP*/
/* Text . . . : Create test items for warehouse 900               TX*/
/* Owner  . . . . . . . . . . . . . . . . . :   JEFF              OW*/
/* User mod flag  . . . . . . . . . . . . . :   *YES              UM*/
/* Retrieve included source . . . . . . . . :   *NO               RI*/
/*                                                                ED*/
/*  Revisions:                                                       */
/*                                                                   */
/*    11/14/19  DAS  7.30                                            */
/*      - Made warehouse an option field                             */
/*                                                                   */
/********************************************************************/
 PCK110CL:   PGM        PARM(&WHSEA)      /* 730aM */
     DCL VAR(&SBMPGM) TYPE(*CHAR) LEN(10) VALUE(PCK110CL)
     DCL VAR(&OPTPGM) TYPE(*CHAR) LEN(8) VALUE(PCK110)
     DCL VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) VALUE('Create test items-
 for warehouse 900')
     DCL VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) VALUE('Creating test -
items for warehouse 900')
     DCL VAR(&MSGDTA) TYPE(*CHAR) LEN(256)
     DCL VAR(&MSGF) TYPE(*CHAR) LEN(10)
     DCL VAR(&MSGFLIB) TYPE(*CHAR) LEN(10)
     DCL VAR(&MSGID) TYPE(*CHAR) LEN(7)
     DCL VAR(&RETURN) TYPE(*CHAR) LEN(8)
     DCL VAR(&SEV) TYPE(*DEC) LEN(2 0)
     DCL VAR(&TYPE) TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)  /* 730aA */
     MONMSG MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
     RTVJOBA TYPE(&TYPE)
     IF COND(&TYPE = '0') THEN(GOTO CMDLBL(SKIP1))
     CALL PGM(&OPTPGM) PARM(&WHSEA &RETURN)   /* 730aA */
     IF COND((&RETURN *EQ '*CANCEL') *OR (&RETURN *EQ '*EXIT')) -
THEN(DO)
     SNDPGMMSG MSGID(PIR9801) MSGF(PIRMSGF) MSGDTA(&CANCELMSG) -
MSGTYPE(*INFO)
     RETURN
     ENDDO
     IF COND(&RETURN *EQ '*JOBQ') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSEA)) +
                          JOB(&SBMPGM)                         /* 730aA */
     GOTO CMDLBL(GETOUT)
     ENDDO
SKIP1:
     RMVMSG CLEAR(*ALL)
     MSGBFC MESSAGE(&WORKINGMSG)
     CALL PGM(PCK115) PARM(&TYPE &WHSEA)   /* 730aA */
GETOUT:
NEXTMSG: +
     DO
     RCVMSG PGMQ(*SAME (*)) MSGQ(*PGMQ) MSGDTA(&MSGDTA) MSGID(&MSGID)-
 SEV(&SEV) MSGF(&MSGF) MSGFLIB(&MSGFLIB)
     IF COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
     SNDPGMMSG MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSGDTA(&MSGDTA) -
MSGTYPE(*COMP)
     GOTO CMDLBL(NEXTMSG)
     ENDDO
NOMSG:
     RCLRSC LVL(*CALLER)
     ENDPGM
