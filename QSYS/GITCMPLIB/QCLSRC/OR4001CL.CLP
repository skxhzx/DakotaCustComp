/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR400CL   RF Order Selection w/Signoff=*YES                      */
/*  10 November 2011                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    03/29/06  RH   5.00                                            */
/*      - Created                                                    */
/*                                                                   */
/*    03/11/19  MLB  7.30                                            */
/*      - Enh: Revised pgm to add logic to check for pgm TIMZONESET. */
/*        If found, run pgm at login. Needed for RF Selection where  */
/*        OR4001CL called from user id.                              */
/*    11/09/19  MLB  7.30a                                           */
/*      - Fix: Revised pgm to add call to GETUNQMEM for WORKOPT.     */
/*        OR400 calls WH900 to verify whse and it opens WORKOPT      */
/*        causing record lock errors. Found at ISP.                  */
/*                                                                   */
/*    06/12/08  MLB  7.50                                            */
/*      - Fix: Revised pgm to add MONMSG on call to &PGM for         */
/*        program failures.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR400CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OR400)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&EXIST)  TYPE(*LGL)                   /* (730 A) */
             DCL        VAR(&FIRST)  TYPE(*LGL)         VALUE('0') /*(730 A) */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)          /* (730aA) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&SYSNAM) TYPE(*CHAR) LEN(8)           /* (730 A) */
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             IF         COND(*NOT &FIRST) THEN(DO)                /* (730 A) */
             CHGVAR     VAR(&EXIST) VALUE('1')                    /* (730 A) */
             CHKOBJ     OBJ(QGPL/TIMZONESET) OBJTYPE(*PGM)        /* (730 A) */
             MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0')) /* Timezn not installed     /* (730 A) */
               IF         COND(&EXIST) THEN(DO)                   /* (730 A) */
                 CALL       PGM(QGPL/TIMZONESET)                  /* (730 A) */
               ENDDO                                              /* (730 A) */
               CHGVAR     VAR(&FIRST) VALUE('1')                  /* (730 A) */
             ENDDO                                                /* (730 A) */

/*  Define work file to be used for display options.                 (730aA) */
/*    - Get unique member to use.                                    (730aA) */
/*    - Override file to use unique member.                          (730aA) */

             IF (&MEMBER = ' ') DO                                /* (730aA) */
                CALL PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)  /* (730aA) */
             ENDDO                                                /* (730aA) */

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)    /* (730aA) */

/*  On with the show ... */

             CALL       PGM(&PGM)
             MONMSG     MSGID(CPF0006 CPF4128 CPF9999) EXEC(DO)   /* (750 A) */
               DSPJOBLOG  OUTPUT(*PRINT)                          /* (750 A) */
               GOTO       CMDLBL(ENDPGM)                          /* (750 A) */
             ENDDO  /* End pgm if connection lost. */             /* (750 A) */

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)                             /* (730aA) */
             MONMSG     MSGID(CPF9841)                            /* (730aA) */
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(WORKOPT) MBR(&MEMBER)                /* (730aA) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (730aA) */

ENDPGM:                                                           /* (750 A) */
             SIGNOFF    LOG(*NOLIST)

             ENDPGM
