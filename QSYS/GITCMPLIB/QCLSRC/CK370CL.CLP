/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CK370CL   Manager Ship List                                      */
/*  05 January 2004                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Revision                                                         */
/*    01/05/04  MLB  CBI                                             */
/*      - Created.                                                   */
/*    10/07/13  RTR  CBIa                                            */
/*      - Change to call GETUNQMEM with *NEW to stop member error    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CK370CL:    PGM        PARM(&PWHSE &PRTID &PORD# &PJOBQ &PDEV &PFORM)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&PJOBQ)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&PORD#)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SBMPGM)     TYPE(*CHAR) LEN(10) VALUE('CK370CL')
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&PDEV)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&PFORM)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(CK375PR)


/*  Don't submit job, if being run from JOBQ.                                 */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0' *or &PJOBQ = 'Y') THEN(DO)
               GOTO       CMDLBL(REPORT)
             ENDDO

/* See if user wants to put report on jobq. */

             IF (&PJOBQ = 'Y') THEN(DO)
               SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&PWHSE &PRTID +
                            &PORD# &PJOBQ &PDEV &PFORM)) JOB(&SBMPGM)
               RETURN
             ENDDO

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

REPORT:

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('LBWHSE *EQ ' *CAT &PWHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBRTE  +
                          *EQ ' *BCAT &QUOTE *CAT &PRTID *CAT &QUOTE))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBGRP1  +
                          *EQ ' *BCAT &QUOTE *CAT S *CAT &QUOTE))

/*    Print Manager Ship List for Single Order.                               */
             IF (&PORD# *GT '0000000') THEN(DO)
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND' *BCAT +
                            'LBORD *EQ ' *CAT &PORD#)
             ENDDO

             OVRDBF     FILE(LABEL90) SHARE(*YES)
             OPNQRYF    FILE((LABEL90)) QRYSLT(&QRYSLT)

         /*  CALL       PGM(GETUNQMEM) PARM(*REUSE CK375A &MEMBER)      CBIaD */
             CALL       PGM(GETUNQMEM) PARM(*NEW CK375A &MEMBER)     /* CBIaA */
             OVRDBF     FILE(CK375A) MBR(&MEMBER) SHARE(*YES)
             CALL       PGM(CK375A) PARM(&PORD#)

             DLTOVR     FILE(LABEL90)

             OVRDBF     FILE(CK375) TOFILE(CK375A) MBR(&MEMBER) +
                          SHARE(*YES)

             OPNQRYF    FILE((CK375A)) FORMAT(CK375) +
                          KEYFLD((CK375A/WBWHDP) (CK375A/WBSTOP) +
                          (CK375A/WBPAL#) (CK375A/WBDISP))

             OVRPRTF    FILE(&PRTF1) DEV(&PDEV) CPI(12) OVRFLW(48) +
                          PAGRTT(90) OUTQ(*DEV) FORMTYPE(&PFORM)

             CALL       PGM(CK375) PARM(&PWHSE &PRTID &PORD# &RETURN)

/*  Clean up before leaving */

             DLTOVR     FILE(CK375A)
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(CK375A) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF7301 +
                          CPF7310)

             ENDPGM
