             PGM        PARM(&PPRINTER)

   /*   PRINT TEST PAGE TO TEST PRINTER FOR TOLEDO SCALE STATION  */
   /*   02/26/2014    */
   /*   KENNETH ELDER  */

             DCL        VAR(&PPRINTER) TYPE(*CHAR) LEN(10)

             OVRPRTF    FILE(QSYSPRT) OUTQ(&PPRINTER)
             CALL       PGM(SC100) PARM(&PPRINTER)

ENDPGM
