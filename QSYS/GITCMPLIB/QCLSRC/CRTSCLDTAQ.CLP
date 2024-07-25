   /*-------------------------------------------------------------------*/
   /*                                                                   */
   /*  CRTSCLDTAQ    Create SCALES or SCALESERV data queue              */
   /*  16 November 2015                                                 */
   /*  Donnie Sanders                                                   */
   /*                                                                   */
   /*  Revisions:                                                       */
   /*                                                                   */
   /*    11/16/15  DLS  7.00                                            */
   /*      - Created.                                                   */
   /*                                                                   */
   /*-------------------------------------------------------------------*/
 CRTSCLDTAQ: PGM        PARM(&DTAQ &DTAQLIB)

   /*-------------------------------------------------------------------*/
   /*  Field declarations                                               */
   /*-------------------------------------------------------------------*/

   /* General variables */

             DCL        VAR(&DTAQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&DTAQLIB)    TYPE(*CHAR) LEN(10)

   /*-------------------------------------------------------------------*/
   /*  Main line                                                        */
   /*-------------------------------------------------------------------*/
   /*  Create SCALES Data Queue  */
             IF         COND(&DTAQ *EQ 'SCALES') THEN(DO)

             CRTDTAQ    DTAQ(&DTAQLIB/SCALES) MAXLEN(1024) +
                          SEQ(*KEYED) KEYLEN(15) TEXT('Scales Data +
                          Queue (Client)')

             MONMSG     CPF9810
             MONMSG     MSGID(CPF9870) EXEC(GOTO CMDLBL(ENDCRT))

             ENDDO


   /*  Create SCALESERV Data Queue  */
             IF         COND(&DTAQ *EQ 'SCALESERV') THEN(DO)

             CRTDTAQ    DTAQ(&DTAQLIB/SCALESERV) MAXLEN(1024) +
                          SEQ(*KEYED) KEYLEN(15) TEXT('Scales Data +
                          Queue (Demo Server)')

             MONMSG     CPF9810
             MONMSG     MSGID(CPF9870) EXEC(GOTO CMDLBL(ENDCRT))

             ENDDO

 ENDCRT:     ENDPGM
