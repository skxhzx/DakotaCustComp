/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CPYITEMCL  Copy all item files from PIRF to PIRTESTF             */
/*  13 July 2006                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CPYITEMCL:  PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&LIB)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER)    TYPE(*CHAR) LEN(10)

 /* Variables for sending messages to calling screen */

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


             CPYF       FROMFILE(PIRF/SLOT) TOFILE(PIRTESTF/SLOT) +
                          MBROPT(*REPLACE)

             CPYF       FROMFILE(PIRF/VSLOT) TOFILE(PIRTESTF/VSLOT) +
                          MBROPT(*REPLACE)

             CPYF       FROMFILE(PIRF/ITEMQTY) +
                          TOFILE(PIRTESTF/ITEMQTY) MBROPT(*REPLACE)

             CPYF       FROMFILE(PIRF/PIRITEM) +
                          TOFILE(PIRTESTF/PIRITEM) MBROPT(*REPLACE)
             CPYF       FROMFILE(PIRF/ITEMMSC) +
                          TOFILE(PIRTESTF/ITEMMSC) MBROPT(*REPLACE)

             CPYF       FROMFILE(PIRF/ITEMDSC) +
                          TOFILE(PIRTESTF/ITEMDSC) MBROPT(*REPLACE)

             CPYF       FROMFILE(PIRF/ITEMLNK) +
                          TOFILE(PIRTESTF/ITEMLNK) MBROPT(*REPLACE)

             CPYF       FROMFILE(PIRF/ITEMDEF) +
                          TOFILE(PIRTESTF/ITEMDEF) MBROPT(*REPLACE)
OUT:

 /* Receive any messages and pass them on */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                        MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:
 BOTTOM:
