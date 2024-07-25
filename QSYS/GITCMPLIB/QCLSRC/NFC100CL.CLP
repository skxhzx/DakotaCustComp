/*-----------------------------------------------------------------*/
/*                                                                 */
/*  NFC100CL    PIRITEM/SLOT/TRUCK ACTIVITY/BUILD UPDATE           */
/*  23 October 2000                                                */
/*  Roxanne Harrison                                               */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &FILE     File name                                      */
/*        &RSTLIBF  File library to update                         */
/*        &RETURN   Return code                                    */
/*                                                                 */
/*-----------------------------------------------------------------*/

 NFC100CL:   PGM        PARM(&RETURN)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&FILE)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&RSTLIBF)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)   TYPE(*CHAR) LEN(8)

   /* Standard message handling variables */

             DCL        VAR(&ABORT)    TYPE(*LGL)  VALUE('0')
             DCL        VAR(&ERRFLAG)  TYPE(*LGL)  VALUE('1')
             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* If a current file doesn't exist then there is no reason to delete it. */

          /* CHKOBJ     OBJ(&RSTLIBF/&FILE) OBJTYPE(*FILE) MBR(*NONE)*/
                CHGVAR     VAR(&FILE) VALUE('PIRITEMO')
             CHKOBJ     OBJ(PIRTESTF/&FILE) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CHGVAR     VAR(&RETURN) VALUE('*NOTFND')
                GOTO SKIP1
             ENDDO

/* Delete file. */

             CHGVAR     VAR(&MSGDTA) VALUE('Deleting existing file' +
                          *BCAT &FILE)

             DLTF       FILE(PIRTESTF/&FILE)

             CHGVAR     VAR(&MSGDTA) VALUE('Delete successful')
             CHGVAR     VAR(&RETURN) VALUE('*OK')

 SKIP1:
/* If a current file doesn't exist then there is no reason to delete it. */

          /* CHKOBJ     OBJ(&RSTLIBF/&FILE) OBJTYPE(*FILE) MBR(*NONE)*/
                CHGVAR     VAR(&FILE) VALUE('SLOTO')
             CHKOBJ     OBJ(PIRTESTF/&FILE) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CHGVAR     VAR(&RETURN) VALUE('*NOTFND')
                GOTO SKIP2
             ENDDO

/* Delete file. */

             CHGVAR     VAR(&MSGDTA) VALUE('Deleting existing file' +
                          *BCAT &FILE)

             DLTF       FILE(PIRTESTF/&FILE)

             CHGVAR     VAR(&MSGDTA) VALUE('Delete successful')
             CHGVAR     VAR(&RETURN) VALUE('*OK')
 SKIP2:
/* If a current file doesn't exist then there is no reason to delete it. */

                CHGVAR     VAR(&FILE) VALUE('ZONEHO')
             CHKOBJ     OBJ(PIRTESTF/&FILE) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CHGVAR     VAR(&RETURN) VALUE('*NOTFND')
                GOTO SKIP3
             ENDDO

/* Delete file. */

             CHGVAR     VAR(&MSGDTA) VALUE('Deleting existing file' +
                          *BCAT &FILE)

             DLTF       FILE(PIRTESTF/&FILE)

             CHGVAR     VAR(&MSGDTA) VALUE('Delete successful')
             CHGVAR     VAR(&RETURN) VALUE('*OK')
 SKIP3:
/* If a current file doesn't exist then there is no reason to delete it. */

                CHGVAR     VAR(&FILE) VALUE('ZONEDO')
             CHKOBJ     OBJ(PIRTESTF/&FILE) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CHGVAR     VAR(&RETURN) VALUE('*NOTFND')
                GOTO SKIP4
             ENDDO

/* Delete file. */

             CHGVAR     VAR(&MSGDTA) VALUE('Deleting existing file' +
                          *BCAT &FILE)

             DLTF       FILE(PIRTESTF/&FILE)

             CHGVAR     VAR(&MSGDTA) VALUE('Delete successful')
             CHGVAR     VAR(&RETURN) VALUE('*OK')
 SKIP4:
             CPYF       FROMFILE(PIRTESTF.T/PIRITEM) +
                          TOFILE(PIRTESTF/PIRITEMO) MBROPT(*ADD) +
                          CRTFILE(*YES)
             CPYF       FROMFILE(PIRTESTF.T/SLOT) +
                          TOFILE(PIRTESTF/SLOTO) MBROPT(*ADD) +
                          CRTFILE(*YES)
             CPYF       FROMFILE(PIRTESTF.T/ZONEH) +
                          TOFILE(PIRTESTF/ZONEHO) MBROPT(*ADD) +
                          CRTFILE(*YES)
             CPYF       FROMFILE(PIRTESTF.T/ZONED) +
                          TOFILE(PIRTESTF/ZONEDO) MBROPT(*ADD) +
                          CRTFILE(*YES)

             CALL       PGM(NFC101)
             CALL       PGM(NFC102)
             CALL       PGM(NFC103)
             CALL       PGM(NFC104)
             CALL       PGM(NFC105)
 /*          CALL       PGM(NFC106)     */
             RETURN

/*-----------------------------------------------------------------*/
/*  Receive any error messages and pass them on before leaving.    */
/*-----------------------------------------------------------------*/

 GETOUT:
             IF         &ABORT SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE)
             CHGVAR     VAR(&ABORT) VALUE('1')

             CHGVAR     VAR(&RETURN) VALUE('*ERROR')
             CHGVAR     VAR(&MSGDTA) VALUE('Error occured.')

 NOMSG:

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
