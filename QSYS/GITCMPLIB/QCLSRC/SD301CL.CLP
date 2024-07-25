/*----------------------------------------------------------------   */
/*   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   245 W. Roosevelt Rd.  Bldg 8, Suite 51                          */
/*   West Chicago, IL  60185                                         */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SD301CL   Print Check Digit Exceptions Report                    */
/*  22 November, 2006                                                */
/*  Randy Haselhorst                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*  12/04/06  JCJ  5.10A                                             */
/*    - Added from and to date to report prompt.                     */
/*    - Added from and to date to QRYSLT.                            */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SD301CL:    PGM        PARM(&PWHSEA &DEPT &EMPA &PFMDT &PTODT +
                          &FMSTMP &TOSTMP &JOBQ &RETURN &DEV &FORM +
                          &MEMBER)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SD301CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(SD301)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(SD302)

  /* Report FILE and printer file names. */

             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(SD302PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Check Digit Exception Report Cancelled')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Check Digit Exception Report')


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&EMPA)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&EMP)        TYPE(*DEC)  LEN(5 0)
/* 510 A */  DCL        VAR(&PFMDT)      TYPE(*CHAR) LEN(8)
/* 510 A */  DCL        VAR(&PTODT)      TYPE(*CHAR) LEN(8)
/* 510 A */  DCL        VAR(&FMSTMP)     TYPE(*CHAR) LEN(26)
/* 510 A */  DCL        VAR(&TOSTMP)     TYPE(*CHAR) LEN(26)
/* 510 A */  DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&PWHSEA)     TYPE(*CHAR) LEN(3)
             DCL        VAR(&PWHSE)      TYPE(*DEC) LEN(3 0)
             DCL        VAR(&DEPT)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&PWHSE &DEPT &EMP &PFMDT +
                          &PTODT &FMSTMP &TOSTMP &JOBQ &RETURN &DEV +
                          &FORM)


/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             CHGVAR     VAR(&PWHSEA) VALUE(&PWHSE)
             CHGVAR     VAR(&EMPA) VALUE(&EMP)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&PWHSEA &DEPT +
                          &EMPA &JOBQ &RETURN &DEV +
                          &FORM &MEMBER)) JOB(SD301CL)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CHGVAR     VAR(&PWHSEA) VALUE(&PWHSE)
             CHGVAR     VAR(&EMPA) VALUE(&EMP)
 REPORT:

             CHGVAR     VAR(&QRYSLT) VALUE('SDEWHS *EQ ' *CAT &PWHSEA)
             IF         COND(&DEPT *NE '*ALL ') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SDEWHD +
                          *EQ' *BCAT &QUOTE *CAT &DEPT *CAT &QUOTE)
             ENDDO
             IF         COND(&EMPA *NE '00000') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SDEEMP *EQ ' +
                          *CAT &EMPA)
             ENDDO

/* 5.10A Add from and to date selection to qryslt     */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('SDEATS  +
                          *GE ' *BCAT &QUOTE *CAT &FMSTMP *CAT &QUOTE))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('SDEATS  +
                          *LE ' *BCAT &QUOTE *CAT &TOSTMP *CAT &QUOTE))

             OVRDBF     FILE(SLTDGTEX) SHARE(*YES)
             OPNQRYF    FILE((SLTDGTEX)) QRYSLT(&QRYSLT) +
                          KEYFLD((SDEWHS) (SDEWHD) (SDEEMP))

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             CALL       PGM(SD302) PARM(&PWHSEA &DEPT &EMPA &PFMDT +
                          &PTODT)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)
             RMVMSG     CLEAR(*ALL)

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

             ENDPGM
