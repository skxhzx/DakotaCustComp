/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EQ485CL   RF Return trailer equipment                            */
/*  2 June, 2016                                                     */
/*  Retha Davis                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    01/12/17  RBD  7.00                                            */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Cheney                                  */
/*                                                                   */
/*    01/12/17  RBD  CBI                                             */
/*      - Added user authorization check.                            */
/*                                                                   */
/*-------------------------------------------------------------------*/

 EQ485CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (700 A) */

             DCL        VAR(&CHENEY) TYPE(*CHAR) LEN(10) +
                          VALUE('CHENEYBROS')                     /* (CBI A) */

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(EQ485)
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (CBI A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)          /* (700 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (700 A) */
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10)          /* (CBI A) */
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)          /* (CBI A) */
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)           /* (CBI A) */
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)          /* (CBI A) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (700 A) */

/*  Check if user is authorized to use this option                   (CBI A) */

             IF         COND(&CLIENT *EQ &CHENEY +
                                                 ) THEN(DO)       /* (CBI A) */
               CHGVAR     VAR(&PGMID) VALUE(EQ485CL)              /* (CBI A) */
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')              /* (CBI A) */
               RTVJOBA    USER(&PUSR)                             /* (CBI A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (CBI A) */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)        /* (CBI A) */
                 RETURN                                           /* (CBI A) */
               ENDDO                                              /* (CBI A) */
             ENDDO                                                /* (CBI A) */

/*  On with the show ... */

             CALL       PGM(&PGM)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
