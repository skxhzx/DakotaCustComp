/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADRFCL2A RF Flag Clear - Loading 11 X 20 screen  Signoff NO    */
/*  July 15, 2008                                                    */
/*  Retha Davis                                                      */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*  06/28/10  JCJ  5.30                                              */
/*   - Fix: Fixed looping problem.                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

             PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(2)
             DCL        VAR(&OPT)        TYPE(*CHAR) LEN(2)

/* 530 D     MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(JOB))        */
/* 530 A*/   MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Call menu program  */

 JOB:        CALL       PGM(LOADR10)

 GETOUT:                                                    /* 530 A */
/*  Clean up before leaving */
             RCLRSC     LVL(*CALLER)

             ENDPGM
