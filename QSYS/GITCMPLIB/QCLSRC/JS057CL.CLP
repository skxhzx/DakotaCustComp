       PGM   PARM()

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&JRN)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIB)        TYPE(*CHAR) LEN(10)

             RTVDTAARA  DTAARA(JRNDTAARA (1 10)) RTNVAR(&JRN)
             IF         COND(&JRN *EQ ' ') THEN(GOTO CMDLBL(ENDNOW))
             RTVDTAARA  DTAARA(JRNDTAARA (11 10)) RTNVAR(&LIB)
             IF         COND(&LIB *EQ ' ') THEN(CHGVAR VAR(&LIB) +
                          VALUE('*LIBL'))

             SNDJRNE    JRN(&LIB/&JRN) ENTDTA(SHUTDOWNNOW)
  ENDNOW:
             ENDPGM
