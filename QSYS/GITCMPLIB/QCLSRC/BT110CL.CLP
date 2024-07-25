/*-------------------------------------------------------------------*/
/*                                                                   */
/*  BT110CL   Batch control display                                  */
/*  24 August 1994                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 BT110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

REPEAT:
             CALL       PGM(BT110A)  PARM(&UNQKEY &RETURN)
             IF         (&RETURN = '*F9') DO
                        CALL PGM(BT110B) PARM(&UNQKEY &RETURN)
                             IF (&RETURN = '*F9') GOTO CMDLBL(REPEAT)
                             ELSE
                             GOTO  CMDLBL(DONE)
                        ENDDO
             ELSE
                        GOTO       CMDLBL(DONE)

DONE:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
