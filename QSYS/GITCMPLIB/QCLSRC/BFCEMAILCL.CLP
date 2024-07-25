/*-------------------------------------------------------------------*/
/*                                                                   */
/*  BFCEMAIL  - BFC Email Process                                    */
/*  02 November 2018                                                 */
/*  Mike Rooker                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
             PGM  (&EMAILTO &SUBJECT &BODY &PATH1 &PATH2 &PATH3)

    /* Variables */
             DCL        VAR(&EMAILTO) TYPE(*CHAR) LEN(1000)
             DCL        VAR(&SUBJECT) TYPE(*CHAR) LEN(100)
             DCL        VAR(&BODY) TYPE(*CHAR) LEN(5000)
             DCL        VAR(&PATH1) TYPE(*CHAR) LEN(100)
             DCL        VAR(&PATH2) TYPE(*CHAR) LEN(100)
             DCL        VAR(&PATH3) TYPE(*CHAR) LEN(100)

    /* Set Classpath */
             RMVENVVAR  ENVVAR(CLASSPATH)
             MONMSG     MSGID(CPF0000)
             ADDENVVAR  ENVVAR(CLASSPATH) +
                          VALUE('/PIRJAVA:/PIRJAVA/jt400.jar:/PIRJAVA+
                          /commons-lang-2.4.jar:/PIRJAVA/java-mail-1.+
                          4.4.jar')
             MONMSG     MSGID(CPF0000)

    /* Call Java Process from RPG */
           /*CALL       PGM(BFCEMAIL) */
             CALL       PGM(BFCEMAIL) PARM(&EMAILTO &SUBJECT &BODY +
                          &PATH1 &PATH2 &PATH3)

             ENDPGM
