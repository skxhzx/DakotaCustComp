/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP180CL   PIR options - FTP Export                               */
/*  04 March 1999                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    03/04/99  DAS  4.11                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    01/24/20  MLB  7.40                                            */
/*    - Enh:  Add user authorization check.                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP180CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP180)
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)          /* (740 A) */
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE('FTP +
                          Options')
             DCL        VAR(&PGMCL) TYPE(*CHAR) LEN(10)  VALUE(OP180CL) +
                                                                  /* (740 A) */
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)           /* (740 A) */
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)          /* (740 A) */
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (740 A) */
             DCL        VAR(&GLOBAL) TYPE(*CHAR) LEN(4) VALUE(*YES)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Check if user is authorized to use this option                /* (740 A) */

               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')              /* (740 A) */
               RTVJOBA    USER(&PUSR)                             /* (740 A) */
               CALL       PGM(CHKLIST) PARM(&PGMCL &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (740 A) */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)        /* (740 A) */
                 RETURN                                           /* (740 A) */
               ENDDO                                              /* (740 A) */

/*  On with the show ... */

             CALL       PGM(OP010) PARM(&PGM &DESC &GLOBAL &RETURN)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
