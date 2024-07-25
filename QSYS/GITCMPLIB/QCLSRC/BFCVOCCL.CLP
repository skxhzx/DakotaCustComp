/*-------------------------------------------------------------------*/
/*                                                                   */
/*  BFCVOCCL BFC - Start/Stop Voice Socket Servers.                  */
/*  26 August 2015                                                   */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    08/26/15  MLB  7.00                                            */
/*      - Created                                                    */
/*    10/11/15  GJA  7.00b                                           */
/*      - Enh: Revised pgm to add support for Julius Silvert.        */
/*    12/07/15  GJA  7.00c                                           */
/*      - Enh: Revised pgm to add support for 8003 at Bertram.       */
/*    05/25/18  MLB  7.20d                                           */
/*      - Enh: Revised pgm to add CLRVODTAQ *BOTH cmd for S Bertram. */
/*        Having recurring problem starting both jobs for 8003.      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 BFCVOCCL:   PGM        PARM(&CLIENT &CMD)

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)
             DCL        VAR(&CMD)    TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

       SELECT
       WHEN       COND(&Client = 'SBERTRAM') THEN(DO)

         SELECT
         WHEN       COND(&CMD = '*START') THEN(DO)
/*7.00c    VOSTRGRP   PORTGRP(8000) START(1) GROUPS(2) TYPE(SBR) */
           VOSTRGRP   PORTGRP(8000) START(1) GROUPS(3) TYPE(SBR)
           MONMSG     MSGID(CPF0000)
         ENDDO

         WHEN       COND(&CMD = '*STOP') THEN(DO)
           VOENDGRP   OPT(*ONE) GROUP(1)
           monmsg     msgid(cpf0000)
           VOENDGRP   OPT(*ONE) GROUP(2)
           monmsg     msgid(cpf0000)
/*7.00c*/  VOENDGRP   OPT(*ONE) GROUP(3)
/*7.00c*/  monmsg     msgid(cpf0000)
           CLRVODTAQ  TYPE(*BOTH) INSTANCE(01)                    /* (720dA) */
           monmsg     msgid(cpf0000)                              /* (720dA) */
           CLRVODTAQ  TYPE(*BOTH) INSTANCE(02)                    /* (720dA) */
           monmsg     msgid(cpf0000)                              /* (720dA) */
           CLRVODTAQ  TYPE(*BOTH) INSTANCE(03)                    /* (720dA) */
           monmsg     msgid(cpf0000)                              /* (720dA) */
         ENDDO
         ENDSELECT

       ENDDO

       WHEN       COND(&Client = 'JULIUSSILV') THEN(DO)

         SELECT
         WHEN       COND(&CMD = '*START') THEN(DO)
           VOSTRGRP   PORTGRP(8000) START(11) GROUPS(2) TYPE(JSL)
           MONMSG     MSGID(CPF0000)
           VOSTRGRP   PORTGRP(8000) START(15) GROUPS(1) TYPE(JST)
           MONMSG     MSGID(CPF0000)
         ENDDO

         WHEN       COND(&CMD = '*STOP') THEN(DO)
           VOENDGRP   OPT(*ONE) GROUP(11)
           monmsg     msgid(cpf0000)
           VOENDGRP   OPT(*ONE) GROUP(12)
           monmsg     msgid(cpf0000)
           VOENDGRP   OPT(*ONE) GROUP(15)
           monmsg     msgid(cpf0000)
         ENDDO
         ENDSELECT

       ENDDO

       ENDSELECT

   /* Clean up before leaving */


ENDPGM
