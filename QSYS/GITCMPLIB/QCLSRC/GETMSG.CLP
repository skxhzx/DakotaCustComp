/*-------------------------------------------------------------------*/
/*                                                                   */
/*  GETMSG    Get message from program message queue                 */
/*  29 January 1996                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 GETMSG:     PGM        PARM(&MSGKEY)


             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&MSGTYPE)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGSEV)     TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&PGMMSGQ)    TYPE(*CHAR) LEN(10)

             RCVMSG     PGMQ(*EXT) MSGQ(*PGMQ) RMV(*NO) KEYVAR(&MSGKEY)

             ENDPGM
