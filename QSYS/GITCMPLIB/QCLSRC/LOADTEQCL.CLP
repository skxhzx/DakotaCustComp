/*-------------------------------------------------------------------*/
/*  LOADTEQCL: Close Returned Trailer Equipment (Pirrtn/Opt 20)      */
/*                                                                   */
/*                                                                   */
/*  October 29, 2008                                                 */
/*  Jose G. Duque                                                    */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADTEQCL:  PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/*           DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PIRUSER)  */
/*           DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(US110B)   */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)




REPEAT:
             /* Loadr51 displays data by loader and Loadr52 by trailer */

             CALL       PGM(LOADR51)  PARM(&RETURN)
             IF         (&RETURN = '*F9') DO
                        CALL PGM(LOADR52) PARM(&RETURN)
                             IF (&RETURN = '*F9') GOTO CMDLBL(REPEAT)
                             ELSE
                             GOTO  CMDLBL(DONE)
                        ENDDO
             ELSE
/*  Check if user wants to print a report. */
             IF         (&RETURN = '*F21') THEN(DO)
             RUNQRY     QRY(OPNEQUIP) OUTTYPE(*RUNOPT) +
                        PRTDEV(LP04)
                        GOTO       CMDLBL(REPEAT)
             ENDDO
             ELSE
                        GOTO       CMDLBL(DONE)



DONE:

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
