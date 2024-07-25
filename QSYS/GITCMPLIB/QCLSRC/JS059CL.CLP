       PGM   PARM()

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&JOBID)        TYPE(*CHAR) LEN(9)
             DCL        VAR(&WRKID)        TYPE(*CHAR) LEN(11)

             RTVDTAARA  DTAARA(JRNDTAARA (1209 3)) +
                          RTNVAR(&JOBID)
             IF         COND(&JOBID *EQ ' ') THEN(GOTO CMDLBL(ENDNOW))

             CHGVAR     VAR(&WRKID) VALUE(%TRIM(&JOBID) *CAT '*')
             WRKACTJOB JOB(&WRKID)
  ENDNOW:
             ENDPGM
