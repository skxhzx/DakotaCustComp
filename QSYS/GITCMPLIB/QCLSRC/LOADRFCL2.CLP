/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADRFCL2 RF Flag Clear - Loading 11 X 20 screen                 */
/*  December 6, 2006                                                 */
/*  Jose Duque                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*  06/28/10  JCJ  5.30                                              */
/*   - Fix: Fixed looping problem.                                   */
/*                                                                   */
/*  12/19/16  MLB  7.00                                              */
/*   - Fix: Added code to override WORKOPT file to unique mbr.       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADRFCL2:  PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(2)
             DCL        VAR(&OPT)        TYPE(*CHAR) LEN(2)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)      /* (700 A) */

/* 530 D     MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(JOB))        */
/* 530 A*/   MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define work file to be used for display options.                 (700 A) */
/*    - Get unique member to use.                                    (700 A) */
/*    - Override file to use unique member.                          (700 A) */

             IF (&MEMBER = ' ') DO                                /* (700 A) */
               CALL PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)   /* (700 A) */
             ENDDO                                                /* (700 A) */

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)    /* (700 A) */

/*  Call menu program  */

 JOB:        CALL       PGM(LOADR10)


 ENDJOB:
 GETOUT:                                                    /* 530 A */
/*  Clean up before leaving */
             DLTOVR     FILE(WORKOPT)                             /* (700 A) */
             MONMSG     MSGID(CPF9841)                            /* (700 A) */
             CLOF       OPNID(WORKOPT)                            /* (700 A) */
             MONMSG     MSGID(CPF4519 CPF4520)                    /* (700 A) */
             RMVM       FILE(WORKOPT) MBR(&MEMBER)                /* (700 A) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (700 A) */
             RCLRSC     LVL(*CALLER)

/*  End and signoff    */
             SIGNOFF

             ENDPGM
