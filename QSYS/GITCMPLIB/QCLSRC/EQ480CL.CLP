/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EQ480CL   RF Load trailer equipment                              */
/*  2 June, 2016                                                     */
/*  Retha Davis                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    01/12/17  RBD  7.00                                            */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*    10/17/17  RBD  7.10                                            */
/*      - Added cmd, pgmid and route id to parm list.                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Cheney                                  */
/*                                                                   */
/*    01/12/17  RBD  CBI                                             */
/*      - Added user authorization check.                            */
/*                                                                   */
/*-------------------------------------------------------------------*/

 EQ480CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (700 A) */

             DCL        VAR(&CHENEY) TYPE(*CHAR) LEN(10) +
                          VALUE('CHENEYBROS')                     /* (CBI A) */


             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(EQ480)
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
             DCL        VAR(&ZONE) TYPE(*CHAR) LEN(6)
             DCL        VAR(&CMD) TYPE(*CHAR) LEN(8)              /* (710aA) */
             DCL        VAR(&RTEID) TYPE(*CHAR) LEN(5)            /* (710aA) */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (700 A) */

/*  Check if user is authorized to use this option                   (CBI A) */

             IF         COND(&CLIENT *EQ &CHENEY +
                                                 ) THEN(DO)       /* (CBI A) */
               CHGVAR     VAR(&PGMID) VALUE(EQ480CL)              /* (CBI A) */
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')              /* (CBI A) */
               RTVJOBA    USER(&PUSR)                             /* (CBI A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (CBI A) */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)        /* (CBI A) */
                 RETURN                                           /* (CBI A) */
               ENDDO                                              /* (CBI A) */
             ENDDO                                                /* (CBI A) */

/*  On with the show ... */

             CALL       PGM(&PGM) PARM(&CMD &PGMID &ZONE &RTEID)  /* (710aM) */

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
