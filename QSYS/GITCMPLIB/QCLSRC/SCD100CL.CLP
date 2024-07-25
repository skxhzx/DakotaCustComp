/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SCD100CL  RF Slot and Check Digit Entry                          */
/*  04 January, 2001                                                 */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    12/08/17  MLB  7.10                                            */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: TPC Foodservice                         */
/*                                                                   */
/*    12/08/17  MLB  TPC                                             */
/*      - Add user authorization check.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SCD100CL:   PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (710 A) */

             DCL        VAR(&TPC) TYPE(*CHAR) LEN(10) +
                          VALUE('TPC')                            /* (TPC A) */

             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (TPC A) */
             DCL        VAR(&PGM) TYPE(*CHAR) LEN(8) VALUE(SCD100)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)    TYPE(*CHAR) LEN(10)       /* (710 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (710 A) */
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10)          /* (TPC A) */
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)          /* (TPC A) */
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)           /* (TPC A) */
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)          /* (TPC A) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (710 A) */

/*  Check if user is authorized to use this option                   (TPC A) */

             IF         COND(&CLIENT *EQ &TPC +
                                                  ) THEN(DO)      /* (TPC A) */
               CHGVAR     VAR(&PGMID) VALUE(SCD100CL)             /* (TPC A) */
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')              /* (TPC A) */
               RTVJOBA    USER(&PUSR)                             /* (TPC A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (TPC A) */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)        /* (TPC A) */
                 RETURN                                           /* (TPC A) */
               ENDDO                                              /* (TPC A) */
             ENDDO                                                /* (TPC A) */


/*  On with the show ... */

             CALL       PGM(&PGM)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
