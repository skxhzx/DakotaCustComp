/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TR120CL   Trax Options by Customer - select whse and cust        */
/*  03 Dec 2014                                                      */
/*  Retha Davis                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TR120CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)   TYPE(*CHAR) LEN(8)  VALUE(TR120)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)   TYPE(*DEC) LEN(3 0)
             DCL        VAR(&TYPE)   TYPE(*CHAR) LEN(1)
             DCL        VAR(&CUST)   TYPE(*DEC) LEN(11 0)

 /* GETUSER program parameters */

             DCL        VAR(&PCODE)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&PWHSE)   TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&PEMP#)   TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&PFNAM)   TYPE(*CHAR) LEN(15)
             DCL        VAR(&PINIT)   TYPE(*CHAR) LEN(1)
             DCL        VAR(&PLNAM)   TYPE(*CHAR) LEN(20)
             DCL        VAR(&PWHDP)   TYPE(*CHAR) LEN(5)
             DCL        VAR(&PSTYP)   TYPE(*CHAR) LEN(1)
             DCL        VAR(&PSHFT)   TYPE(*CHAR) LEN(6)
             DCL        VAR(&PCREW)   TYPE(*CHAR) LEN(6)
             DCL        VAR(&PNHRS)   TYPE(*DEC)  LEN(3 1)
             DCL        VAR(&PRTN)    TYPE(*CHAR) LEN(8)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

/* Get job information. */

             RTVJOBA    USER(&PCODE) TYPE(&TYPE)
 /* Get user information */

             CALL       PGM(GETUSER) PARM(&PCODE &PWHSE &PEMP# +
                          &PFNAM &PINIT &PLNAM &PWHDP &PSTYP &PSHFT +
                          &PCREW &PNHRS &PRTN)

             CHGVAR VAR(&WHSE) VALUE(&PWHSE)

             CALL       PGM(&PGM)  PARM(&WHSE &CUST &RETURN)


             ENDPGM
