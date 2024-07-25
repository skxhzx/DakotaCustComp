   /*  THIS PROGRAM WILL ACCEPT AN INCOMING LIBRARY AND    */
   /*  CREATE THE SCALE DATA QUEUES                        */

             PGM        PARM(&DTAQLIB)

   /*   WILL TEST FOR INCOMING LIBRARY.  IF BLANK THIS JOB WILL */
   /*   ATTEMPT TO CREATE DATA QUEUES IN BOTH PIRF AND PIRTESTF */
   /*   OTHERWISE IT WILL CREATE IN THE LIBRARY PASSED IN PARM  */
   /*   02/22/2015    */
   /*   KENNETH ELDER  */

             DCL        VAR(&DTAQLIB) TYPE(*CHAR) LEN(10)

             IF        COND(&DTAQLIB *EQ ' ') THEN(GOTO +
                          CMDLBL(CRTPIRF))

             CRTDTAQ    DTAQ(&DTAQLIB/SCALES) MAXLEN(1024) +
                          SEQ(*KEYED) KEYLEN(15) TEXT('Scales Data +
                          Queue (Client)')
             MONMSG     CPF9810
             MONMSG     MSGID(CPF9870) EXEC(GOTO CMDLBL(NXTQ1))
NXTQ1:
             CRTDTAQ    DTAQ(&DTAQLIB/SCALESERV) MAXLEN(1024) +
                          SEQ(*KEYED) KEYLEN(15) TEXT('Scales Data +
                          Queue (Client)')
             MONMSG     CPF9810
             MONMSG     MSGID(CPF9870) EXEC(GOTO CMDLBL(ENDCRT))
             GOTO       CMDLBL(ENDCRT)

CRTPIRF:
             CRTDTAQ    DTAQ(PIRF/SCALES) MAXLEN(1024) SEQ(*KEYED) +
                          KEYLEN(15) TEXT('Scales Data Queue (Client)')
             MONMSG     CPF9810
             MONMSG     MSGID(CPF9870) EXEC(GOTO CMDLBL(NXTQ2))

NXTQ2:
             CRTDTAQ    DTAQ(PIRTESTF/SCALES) MAXLEN(1024) +
                          SEQ(*KEYED) KEYLEN(15) TEXT('Scales Data +
                          Queue (Client)')
             MONMSG     CPF9810
             MONMSG     MSGID(CPF9870) EXEC(GOTO CMDLBL(NXTQ3))
NXTQ3:
             CRTDTAQ    DTAQ(PIRF/SCALESERV) MAXLEN(1024) +
                          SEQ(*KEYED) KEYLEN(15) TEXT('Scales Data +
                          Queue (Client)')
             MONMSG     CPF9810
             MONMSG     MSGID(CPF9870) EXEC(GOTO CMDLBL(NXTQ4))

NXTQ4:
             CRTDTAQ    DTAQ(PIRTESTF/SCALESERV) MAXLEN(1024) +
                          SEQ(*KEYED) KEYLEN(15) TEXT('Scales Data +
                          Queue (Client)')
             MONMSG     CPF9810
             MONMSG     MSGID(CPF9870) EXEC(GOTO CMDLBL(ENDCRT))

ENDCRT:
ENDPGM
