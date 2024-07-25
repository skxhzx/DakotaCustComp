/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PCK220CL  Create random test orders for warehouse 900            */
/*  29 July 1997                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    09/05/97  DAS  4.05                                            */
/*      - Added order type.                                          */
/*                                                                   */
/*    07/17/02  DAS  4.16                                            */
/*      - Added ftp option.                                          */
/*                                                                   */
/*    07/21/11  DAS  6.40                                            */
/*      - Added Batch pick option                                    */
/*      - Revised to use OI280 '4' files.                            */
/*      - Added IMPFORDDM file.                                      */
/*                                                                   */
/*    10/28/13  DAS  6.50                                            */
/*      - Made warehouse an option field                             */
/*                                                                   */
/*    01/30/16  DAS  7.00a                                           */
/*      - Added AMP pick option                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PCK220CL:   PGM        PARM(&RTE &TRUCK &ITM1 &ITM2 &PCS1 &PCS2 +
                          &CUBEDRY &CUBEREF &CUBEFRZ &LBLYN &ORDTYPE +
                          &FTP &BPCK &APCK &ACOD &WHSEA)
                            /* 700aM */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PCK220CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PCK220)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Create random test orders for +
                          warehouse 900')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Creating random test orders for +
                          warehouse 900')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&APCK)       TYPE(*CHAR) LEN(1)   /* 700aA */
             DCL        VAR(&ACOD)       TYPE(*CHAR) LEN(3)   /* 700aA */
             DCL        VAR(&BATCH)      TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&CUBEDRY)    TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&CUBEREF)    TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&CUBEFRZ)    TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&EXIST)      TYPE(*LGL)           /* 416 A */
             DCL        VAR(&FTP)        TYPE(*CHAR) LEN(1)   /* 416 A */
             DCL        VAR(&BPCK)       TYPE(*CHAR) LEN(1)   /* 640aA */
             DCL        VAR(&ITM1)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&ITM2)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&LBLYN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&ORDTYPE)    TYPE(*CHAR) LEN(1)    /* 404 A */
             DCL        VAR(&OTYPE)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&PCS1)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&PCS2)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTEID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TRUCK)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO SKIP1)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&RTE &TRUCK &ITM1 &ITM2 +
                          &PCS1 &PCS2 &CUBEDRY &CUBEREF &CUBEFRZ +
                          &LBLYN &ORDTYPE &FTP &BPCK &WHSEA &APCK +
                          &ACOD &RETURN) /* 700aM */

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&RTE &TRUCK &ITM1 +
                          &ITM2 &PCS1 &PCS2 &CUBEDRY &CUBEREF +
                          &CUBEFRZ &LBLYN &ORDTYPE &FTP &BPCK +
                          &WHSEA &APCK &ACOD)) JOB(&SBMPGM)
               GOTO    CMDLBL(GETOUT)  /* 640 */
             ENDDO

/*  Otherwise, run program. */

 SKIP1:

/* Get printer device to use and then execute print program. */

             RMVMSG     CLEAR(*ALL)

/*  Initialize variables */

       /*    CHGVAR     VAR(&WHSE) VALUE(900)           650aD */
             CHGVAR     VAR(&WHSE) VALUE(&WHSEA)     /* 650aM */
             CHGVAR     VAR(&RTEID) VALUE('PK220')
             CHGVAR     VAR(&BATCH) VALUE(9999999)
             CHGVAR     VAR(&OTYPE) VALUE(' ')

/*  See if user wants to populate WORKLBL file */

             IF (&LBLYN *NE 'Y') THEN(GOTO SKIPLBL)

/*  Call program to populate WORKLBL file.  */

             MSGBFC     MESSAGE('Populating WORKLBL file with +
                          slotted items')
/* 650a M */
             CALL       PGM(PCK224) PARM(&TYPE &RTE &TRUCK &RTEID &WHSE)

/*  Call program to zone combinations and zone generations */

             MSGBFC     MESSAGE('Assigning zones to WORKLBL records')
             CALL       PGM(OR612) PARM(&BATCH &WHSE &TRUCK &RTEID)
             CALL       PGM(OR615) PARM(&BATCH &WHSE &TRUCK &OTYPE &RTEID)

/*  Call program to create random orders */

 SKIPLBL:

/*  If not using FTP then skip member stuff */

             IF (&FTP *NE 'F') THEN(GOTO SKIPMBR)

/*  See if header member exists (1=EXIST) */

             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(IMPFORDH4) OBJTYPE(*FILE) MBR(PCKTEST)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

/*  If header member does not exist then create it */

             IF (*NOT &EXIST) DO
                ADDPFM FILE(IMPFORDH4) MBR(PCKTEST) +
                       TEXT('Created by PCK210CL')
             ENDDO

/*  If header member exists then clear it */

             IF (&EXIST) DO
                CLRPFM FILE(IMPFORDH4) MBR(PCKTEST)
             ENDDO

/*  See if header misc member exists (1=EXIST) */

             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(IMPFORDHM) OBJTYPE(*FILE) MBR(PCKTEST)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

/*  If header misc member does not exist then create it */

             IF (*NOT &EXIST) DO
                ADDPFM FILE(IMPFORDHM) MBR(PCKTEST) +
                       TEXT('Created by PCK210CL')
             ENDDO

/*  If header misc member exists then clear it */

             IF (&EXIST) DO
                CLRPFM FILE(IMPFORDHM) MBR(PCKTEST)
             ENDDO

/*  See if detail member exists (1=EXIST) */

             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(IMPFORDD4) OBJTYPE(*FILE) MBR(PCKTEST)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

/*  If detail member does not exist then create it */

             IF (*NOT &EXIST) DO
                ADDPFM FILE(IMPFORDD4) MBR(PCKTEST) +
                       TEXT('Created by PCK210CL')
             ENDDO

/*  If detail member exists then clear it */

             IF (&EXIST) DO
                CLRPFM FILE(IMPFORDD4) MBR(PCKTEST)
             ENDDO

/*  See if detail misc member exists (1=EXIST) */

             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(IMPFORDDM) OBJTYPE(*FILE) MBR(PCKTEST)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

/*  If detail misc member does not exist then create it */

             IF (*NOT &EXIST) DO
                ADDPFM FILE(IMPFORDDM) MBR(PCKTEST) +
                       TEXT('Created by PCK210CL')
             ENDDO

/*  If detail misc member exists then clear it */

             IF (&EXIST) DO
                CLRPFM FILE(IMPFORDDM) MBR(PCKTEST)
             ENDDO

/*  Override files to use correct memeber */

             OVRDBF     FILE(IMPFORDH4) MBR(PCKTEST)
             OVRDBF     FILE(IMPFORDHM) MBR(PCKTEST)
             OVRDBF     FILE(IMPFORDD4) MBR(PCKTEST)
             OVRDBF     FILE(IMPFORDDM) MBR(PCKTEST)

 SKIPMBR:

             MSGBFC     MESSAGE(&WORKINGMSG)
             CALL       PGM(PCK225) PARM(&TYPE &RTE &TRUCK &ITM1 +
                          &ITM2 &PCS1 &PCS2 &CUBEDRY &CUBEREF +
                          &CUBEFRZ &ORDTYPE &FTP &BPCK &WHSE &APCK +
                          &ACOD) /* 700aM */

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             IF (&FTP *EQ 'F') DO
               DLTOVR FILE(IMPFORDH4 IMPFORDHM IMPFORDD4 IMPFORDDM)
               MONMSG     MSGID(CPF0000)
             ENDDO

             RCLRSC     LVL(*CALLER)

             ENDPGM
