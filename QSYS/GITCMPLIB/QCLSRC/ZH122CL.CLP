/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ZH122CL   Activate Round Robin Printing                          */
/*  17 January  2007                                                 */
/*  Jeffrey Jahnke                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    xx/xx/xx  xxx  x.xx                                            */
/*      - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.               */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ZH122CL:    PGM        PARM(&PGM &AUT)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM) TYPE(*CHAR) LEN(10)
             DCL        VAR(&AUT) TYPE(*CHAR) LEN(1)
             DCL        VAR(&LIB) TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/
             RTVMBRD    FILE(ZONEH) RTNLIB(&LIB)
             CHKOBJ     OBJ(&LIB/PIRROBIN) OBJTYPE(*DTAARA)
             MONMSG     MSGID(CPF9801) EXEC(CRTDTAARA +
                          DTAARA(&LIB/PIRROBIN) TYPE(*CHAR) LEN(1) +
                          VALUE('N'))

             IF         COND(&PGM *EQ 'PFMT')  THEN(DO)
             CHGDTAARA  DTAARA(PIRROBIN) VALUE('Y')
             ENDDO

             IF         COND(&PGM *EQ 'ZH122')  THEN(DO)
             RTVDTAARA  DTAARA(PIRROBIN) RTNVAR(&AUT)
             ENDDO

             RETURN
             ENDPGM
