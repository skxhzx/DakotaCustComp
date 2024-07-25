       PGM   PARM()

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&OUTLB)        TYPE(*CHAR) LEN(10)

             RTVDTAARA  DTAARA(JRNDTAARA (1199 10)) RTNVAR(&OUTLB)
             IF         COND(&OUTLB *EQ ' ') THEN(GOTO CMDLBL(ENDNOW))

             DSPLIB &OUTLB
  ENDNOW:
             ENDPGM
