/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADDRCL: Loader Module - Loading Door Assigment.                */
/*  November 7, 2007                                                 */
/*  Jose Duque                                                       */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADDRCL:   PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LDRDOOR)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)
             DCL        VAR(&USER)   TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             RTVJOBA    USER(&USER)

/*----------------------------------------------------*/
/*  Define file to be used for display                */
/*      - Share it with everyone that follows.        */
/*      - Open it to allow Input and Output.          */

/*           OVRDBF     FILE(&FILE) SHARE(*YES)       */
/*           OPNDBF     FILE(&FILE) OPTION(*ALL)      */

/*----------------------------------------------------*/
/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

             CALL       PGM(LOADR32)  PARM(&UNQKEY &RETURN)


/*----------------------------------------------------*/
/*  Check if user wants to print a report.            */

             IF         (&RETURN = '*F21') THEN(DO)
             RUNQRY     QRY(DOORLOGQRY) OUTTYPE(*RUNOPT) RCDSLT(*YES)
             ENDDO



/*----------------------------------------------------*/
/*  Clean up before leaving                           */

/*           CLOF       OPNID(&FILE)   */
/*           DLTOVR     FILE(&FILE)    */
             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
