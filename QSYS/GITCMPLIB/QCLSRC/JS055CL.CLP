             PGM        PARM(&TS &DTE &TIM &OUTLIB &JNAME &JRJOB &JFILES +
                          &JLIBRS &JTYPES &CMD)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&TS)        TYPE(*CHAR) LEN(26)
             DCL        VAR(&DTE)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&TIM)        TYPE(*CHAR) LEN(6)
             DCL        VAR(&OUTLIB)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&JFILES)     TYPE(*CHAR) LEN(820)
             DCL        VAR(&JLIBRS)     TYPE(*CHAR) LEN(280)
             DCL        VAR(&JTYPES)     TYPE(*CHAR) LEN(18)
             DCL        VAR(&JNAME)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&JRJOB)      TYPE(*CHAR) LEN(9)
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(1)

     /*   UPDATE TIMESTAMP, DATE AND TIME                              */
             IF         COND(&CMD *EQ 'U') THEN(DO)
             CHGDTAARA  DTAARA(JRNDTAARA (1159 26)) VALUE(&TS)
             CHGDTAARA  DTAARA(JRNDTAARA (1185 8)) VALUE(&DTE)
             CHGDTAARA  DTAARA(JRNDTAARA (1193 6)) VALUE(&TIM)
             ENDDO

     /*   RETRIEVE TIMESTAMP, DATE AND TIME                              */
             IF         COND(&CMD *EQ 'R') THEN(DO)
             RTVDTAARA  DTAARA(JRNDTAARA (1 10)) +
                          RTNVAR(&JNAME)
             RTVDTAARA  DTAARA(JRNDTAARA (1209 9)) +
                          RTNVAR(&JRJOB)
             RTVDTAARA  DTAARA(JRNDTAARA (1159 26)) RTNVAR(&TS)
             RTVDTAARA  DTAARA(JRNDTAARA (1185 8)) RTNVAR(&DTE)
             RTVDTAARA  DTAARA(JRNDTAARA (1193 6)) RTNVAR(&TIM)
             RTVDTAARA  DTAARA(JRNDTAARA (1199 10)) +
                          RTNVAR(&OUTLIB)
             RTVDTAARA  DTAARA(JRNDTAARA (41 820)) +
                          RTNVAR(&JFILES)
             RTVDTAARA  DTAARA(JRNDTAARA (861 280)) +
                          RTNVAR(&JLIBRS)
             RTVDTAARA  DTAARA(JRNDTAARA (1141 18)) +
                          RTNVAR(&JTYPES)
             ENDDO

             ENDPGM
