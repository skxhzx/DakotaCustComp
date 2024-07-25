/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADCASADJ  Adjust Loader/Cases Payroll info.                    */
/*  March 25, 2008                                                   */
/*  Jose Duque                                                       */
/*                                                                   */
/*  NOTE: The file 'LDRFIL2' created thru this application is        */
/*        added daily, by job 'LOADHCL2', to 'LDRFILE' file          */
/*        which is picked up everyday by a Mainframe remote job.     */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADCASADJ: PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Informational message. */

             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
             VALUE('   You are not authorized to use this option.')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)
             DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&POPT)       TYPE(*CHAR) LEN(20)
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PGMID) VALUE(LOADCASADJ)

             RTVJOBA    USER(&PUSR)

/*  Check if user is authorized to use this option */

             CALL       PGM(CHKLIST) PARM(&PGMID &POPT &PUSR &PRTN)

             IF         COND(&PRTN *EQ '*NO')  THEN(DO)

                        SNDPGMMSG  MSG(&NOAUTHRZE)   +
                        MSGTYPE(*INFO)

             RETURN
             ENDDO


/*----------------------------------------------------*/
/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*----------------------------------------------------*/
/*  Initial 'Loaded/Case adjustment' program. Other   */
/*  two pgms (Loadr38 {chg,view,add} -  Loadr39 {del} */
/*  are called within Loadr37 - An adjustment log     */
/*  file is kept by pgm: Loadr39.                     */

             CALL       PGM(LOADR37)  PARM(&UNQKEY &RETURN)


/*----------------------------------------------------*/
/*  Check if user wants to print a report.            */

             IF         (&RETURN = '*F21') THEN(DO)
             RUNQRY     QRY(CASADJQRY) OUTTYPE(*RUNOPT) PRTDEV(LP09)
             ENDDO



/*----------------------------------------------------*/
/*  Clean up before leaving                           */

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
