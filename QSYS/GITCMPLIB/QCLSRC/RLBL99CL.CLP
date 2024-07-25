/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RLBL99CL  Receiving label program                               */
/*  26 April, 1996                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RLBL99CL:   PGM        PARM(&PCMD &PTRN# &PWHSE &PWHDP &PSTYP +
                          &PDISP &PPSLT &PQTY &PUM &PTIE &PHIGH +
                          &PITEM &PDESC &PPDSC &PUPC &PVEN &PVITM +
                          &PPO &PRCVD &PEXPD &PDEV &PFORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(DEPTDEF)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(DD110)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PCMD)   TYPE(*CHAR) LEN(8)
             DCL        VAR(&PTRN#)  TYPE(*CHAR) LEN(7)
             DCL        VAR(&PWHSE)  TYPE(*CHAR) LEN(3)
             DCL        VAR(&PWHDP)  TYPE(*CHAR) LEN(5)
             DCL        VAR(&PSTYP)  TYPE(*CHAR) LEN(1)
             DCL        VAR(&PDISP)  TYPE(*CHAR) LEN(12)
             DCL        VAR(&PPSLT)  TYPE(*CHAR) LEN(12)
             DCL        VAR(&PQTY)   TYPE(*CHAR) LEN(5)
             DCL        VAR(&PUM)    TYPE(*CHAR) LEN(2)
             DCL        VAR(&PTIE)   TYPE(*CHAR) LEN(4)
             DCL        VAR(&PHIGH)  TYPE(*CHAR) LEN(2)
             DCL        VAR(&PITEM)  TYPE(*CHAR) LEN(15)
             DCL        VAR(&PDESC)  TYPE(*CHAR) LEN(30)
             DCL        VAR(&PPDSC)  TYPE(*CHAR) LEN(15)
             DCL        VAR(&PUPC)   TYPE(*CHAR) LEN(15)
             DCL        VAR(&PVEN)   TYPE(*CHAR) LEN(11)
             DCL        VAR(&PVITM)  TYPE(*CHAR) LEN(15)
             DCL        VAR(&PPO)    TYPE(*CHAR) LEN(9)
             DCL        VAR(&PRCVD)  TYPE(*CHAR) LEN(6)
             DCL        VAR(&PEXPD)  TYPE(*CHAR) LEN(6)
             DCL        VAR(&PDEV)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&PFORM)  TYPE(*CHAR) LEN(10)

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&SPLNBR) TYPE(*DEC)  LEN(4 0)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(RLBL99) PARM(&PCMD &PTRN# &PWHSE &PWHDP +
                          &PSTYP &PDISP &PPSLT &PQTY &PUM &PTIE +
                          &PHIGH &PITEM &PDESC &PPDSC &PUPC &PVEN +
                          &PVITM &PPO &PRCVD &PEXPD &PDEV &PFORM)

             IF         COND(&PCMD *EQ '*FLUSH  ') THEN(DO)
                CHGVAR     VAR(&SPLNBR) VALUE(%SST(&PWHDP 2 4))
                DSPSPLF    FILE(RLBL01PR) SPLNBR(&SPLNBR)
             ENDDO

             ENDPGM
